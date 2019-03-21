# Mutant Tanks
## Information
> Everything you need to know about each ability/setting is below. Do not expect any help from the developer if you do not take the time to read everything below first. This file uses the first (original) config format for examples.

- Maximum types: 1000 (Increase the value in the `mutant_tanks.inc` file and recompile at your own risk.)
- Ability count: 72 (Suggest more if you want; we always needs more.)

## Sections
- Plugin Settings
- Tank Settings
- Abilities
- Administration System

### Plugin Settings

```
"Mutant Tanks"
{
	// These are the general plugin settings.
	// Note: The following settings will not work in custom config files:
	// Any setting under the "Game Modes" section.
	// Any setting under the "Custom" section.
	"Plugin Settings"
	{
		"General"
		{
			// Enable Mutant Tanks.
			// --
			// 0: OFF
			// 1: ON
			"Plugin Enabled"			"1"

			// Announce each Mutant Tank's arrival.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: Announce when a Mutant Tank spawns.
			// 2: Announce when a Mutant Tank evolves. (Only works when "Spawn Mode" is set to 1.)
			// 4: Announce when a Mutant Tank randomizes. (Only works when "Spawn Mode" is set to 2.)
			// 8: Announce when a Mutant Tank transforms. (Only works when "Spawn Mode" is set to 3.)
			// 16: Announce when a Mutant Tank untransforms. (Only works when "Spawn Mode" is set to 3.)
			"Announce Arrival"			"31"

			// Announce each Mutant Tank's death.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// 0: OFF
			// 1: ON
			"Announce Death"			"1"

			// Base health given to all Mutant Tanks.
			// Note: Tank's health limit on any difficulty is 65,535.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the setting for "Multiply Health," the Mutant Tank's health will be multiplied based on player count.
			// --
			// Minimum: 0 (OFF)
			// Maximum: 65535
			"Base Health"				"0"

			// Mutant Tanks revert back to default Tanks upon death.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// Note: This feature is simply for cosmetic purposes. You do not need to worry about this setting.
			// --
			// 0: OFF
			// 1: ON
			"Death Revert"				"0"

			// The plugin will automatically disable any Mutant Tank whose abilities are not installed.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// Note: This does not disable Mutant Tanks that do not have any abilities.
			// --
			// 0: OFF
			// 1: ON
			"Detect Plugins"			"0"

			// Display Mutant Tanks' names and health.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: ON, show names only.
			// 2: ON, show health only.
			// 4: ON, show both names and health.
			"Display Health"			"7"

			// Display type of Mutant Tanks' names and health.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// 0: OFF
			// 1: ON, show in hint text.
			// 2: ON, show in center text.
			"Display Health Type"			"1"

			// Enable Mutant Tanks in finales only.
			// --
			// 0: OFF
			// 1: ON
			"Finales Only"				"0"

			// The characters used to represent the health bar of Mutant Tanks.
			// Note: This setting only takes affect when the "Display Health" setting is enabled.
			// --
			// Separate characters with commas.
			// --
			// Character limit: 2
			// Character limit for each character: 1
			// --
			// 1st character = Health indicator
			// 2nd character = Damage indicator
			"Health Characters"			"|,-"

			// Multiply Mutant Tanks' health.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// Note: Health changes only occur when there are at least 2 alive non-idle human survivors.
			// --
			// 0: No changes to health.
			// 1: Multiply original health only.
			// 2: Multiply extra health only.
			// 3: Multiply both.
			"Multiply Health"			"0"

			// The range of types to check for.
			// --
			// Separate values with "-".
			// --
			// Value limit: 2
			// Character limit for each value: 3
			// --
			// Minimum number for each value: 1
			// Maximum number for each value: 1000
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			"Type Range"				"1-1000"
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
			// 0: OFF
			// 1: ON
			"Allow Developer"			"1"

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
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Cooldown"			"600"

			// Human-controlled Mutant Tanks are exempted from cooldowns when using the "sm_mutanttank" command to switch their current Mutant Tank type.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF
			// 1: ON
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
			// Spawn this many Tanks on non-finale maps periodically.
			// --
			// Minimum: 1
			// Maximum: 64
			"Regular Amount"			"2"

			// Spawn Tanks on non-finale maps every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Regular Interval"			"300.0"

			// The type of Mutant Tank that will spawn.
			// --
			// 0: OFF, use the randomization feature.
			// 1-1000: ON, the type that will spawn.
			"Regular Type"				"0"

			// Spawn Tanks on non-finale maps periodically.
			// --
			// 0: OFF
			// 1: ON
			"Regular Wave"				"0"

			// The type of Mutant Tank that will spawn in each wave.
			// --
			// Separate types with commas.
			// --
			// Wave limit: 3
			// Character limit for each wave: 4
			// --
			// Minimum value for each wave: 0
			// Maximum value for each wave: 1000
			// --
			// 1st number = 1st wave
			// 2nd number = 2nd wave
			// 3rd number = 3rd wave
			// --
			// 0: OFF, use the randomization feature.
			// 1-1000: ON, the type that will spawn.
			"Finale Types"				"0,0,0"

			// Number of Tanks to spawn for each finale wave.
			// Note: This setting does not seem to work on the official L4D1 campaigns' finale maps. They have their own finale scripts which limit the number of Tanks to 1 for each wave.
			// --
			// Separate waves with commas.
			// --
			// Wave limit: 3
			// Character limit for each wave: 3
			// --
			// Minimum value for each wave: 1
			// Maximum value for each wave: 64
			// --
			// 1st number = 1st wave
			// 2nd number = 2nd wave
			// 3rd number = 3rd wave
			"Finale Waves"				"2,3,4"
		}
		"Game Modes"
		{
			// Enable Mutant Tanks in these game mode types.
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
			// --
			// Separate game modes with commas.
			// --
			// Character limit: 512 (including commas)
			// --
			// Empty: All
			// Not empty: Enabled only in these game modes.
			"Enabled Game Modes"			""

			// Disable Mutant Tanks in these game modes.
			// --
			// Separate game modes with commas.
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
			// --
			// 0: OFF
			// 1: ON
			"Enable Custom Configs"			"0"

			// The type of custom config that Mutant Tanks creates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: Difficulties
			// 2: Maps
			// 4: Game modes
			// 8: Days
			// 16: Player count
			"Create Config Types"			"0"

			// The type of custom config that Mutant Tanks executes.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: Difficulties
			// 2: Maps
			// 4: Game modes
			// 8: Days
			// 16: Player count
			"Execute Config Types"			"0"
		}
	}
}
```

### Tank Settings

#### General, Administration, Spawn, Props, Particles, Enhancements, Immunities

```
"Mutant Tanks"
{
	"Tank #1"
	{
		"General"
		{
			// Name of the Mutant Tank.
			// --
			// Character limit: 32
			// --
			// Empty: "Tank"
			// Not Empty: Tank's custom name
			"Tank Name"				"Tank #1"

			// Enable the Mutant Tank.
			// Note: This setting determines full enablement. Even if other settings are enabled while this is disabled, the Mutant Tank will stay disabled.
			// --
			// 0: OFF
			// 1: ON
			"Tank Enabled"				"0"

			// The Mutant Tank has this many chances out of 100.0% to spawn.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: Clones, respawned Mutant Tanks, randomized Tanks, and Mutant Tanks spawned through the Mutant Tanks menu are not affected. 
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Tank Chance"				"100.0"

			// Display a note for the Mutant Tank when it spawns.
			// Note: This note can also be displayed for clones if "Clone Mode" is set to 1, so the chat could be spammed if multiple clones spawn.
			// Note: A note must be manually created in the translation file.
			// Note: Tank notes support chat color tags in the translation file.
			// --
			// 0: OFF
			// 1: ON
			"Tank Note"				"0"

			// The game can spawn the Mutant Tank.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: The Mutant Tank will still appear on the Mutant Tanks menu and other Mutant Tanks can still transform into the Mutant Tank.
			// --
			// 0: OFF
			// 1: ON
			"Spawn Enabled"				"1"

			// The Mutant Tank can be spawned through the "sm_tank" command.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF
			// 1: ON
			"Menu Enabled"				"1"

			// Announce the Mutant Tank's arrival.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: Announce when a Mutant Tank spawns.
			// 2: Announce when a Mutant Tank evolves. (Only works when "Spawn Mode" is set to 1.)
			// 4: Announce when a Mutant Tank randomizes. (Only works when "Spawn Mode" is set to 2.)
			// 8: Announce when a Mutant Tank transforms. (Only works when "Spawn Mode" is set to 3.)
			// 16: Announce when a Mutant Tank untransforms. (Only works when "Spawn Mode" is set to 3.)
			"Announce Arrival"			"31"

			// Announce the Mutant Tank's death.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// --
			// 0: OFF
			// 1: ON
			"Announce Death"			"1"

			// The Mutant Tank reverts back to default a Tank upon death.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This feature is simply for cosmetic purposes.
			// You do not need to worry about this setting.
			// --
			// 0: OFF
			// 1: ON
			"Death Revert"				"0"

			// The plugin will automatically disable the Mutant Tank if none of its abilities are installed.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This does not disable the Mutant Tank if it does not have any abilities.
			// --
			// 0: OFF
			// 1: ON
			"Detect Plugins"			"0"

			// Display the Mutant Tank's name and health.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: ON, show names only.
			// 2: ON, show health only.
			// 4: ON, show health bar only.
			"Display Health"			"7"

			// Display type of the Mutant Tank's names and health.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// --
			// 0: OFF
			// 1: ON, show in hint text.
			// 2: ON, show in center text.
			"Display Health Type"			"1"

			// The characters used to represent the health bar of the Mutant Tank.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This setting only takes affect when the "Display Health" setting is enabled.
			// --
			// Separate characters with commas.
			// --
			// Character limit: 2
			// Character limit for each character: 1
			// --
			// 1st character = Health indicator
			// 2nd character = Damage indicator
			"Health Characters"			"|,-"

			// Multiply the Mutant Tank's health.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: Health changes only occur when there are at least 2 alive non-idle human survivors.
			// --
			// 0: No changes to health.
			// 1: Multiply original health only.
			// 2: Multiply extra health only.
			// 3: Multiply both.
			"Multiply Health"			"0"

			// Allow players to play as the Mutant Tank.
			// --
			// 0: OFF
			// 1: ON
			"Human Support"				"0"

			// These are the RGBA values of the Mutant Tank's skin color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Skin Color"				"255,255,255,255"

			// The Mutant Tank will have a glow outline.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0: OFF
			// 1: ON
			"Glow Enabled"				"0"

			// These are the RGB values of the Mutant Tank's glow outline color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			"Glow Color"				"255,255,255"
		}
		"Administration"
		{
			// Admins with one or more of these access flags has access to the Mutant Tank type.
			// Note: This setting overrides the same setting under the "Plugin Settings/Administration" section.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to all of the Mutant Tank's attacks.
			// Note: This setting overrides the same setting under the "Plugin Settings/Administration" section.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""
		}
		"Spawn"
		{
			// The number of Mutant Tanks with this type that can be alive at any given time.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: Clones, respawned Mutant Tanks, randomized Tanks, and Mutant Tanks spawned through the Mutant Tanks menu are not affected. 
			// --
			// Minimum: 0
			// Maximum: 64
			"Type Limit"				"32"

			// The Mutant Tank will only spawn on finale maps.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: Clones, respawned Mutant Tanks, randomized Tanks, and Mutant Tanks spawned through the Mutant Tanks menu are not affected. 
			// --
			// 0: OFF
			// 1: ON
			"Finale Tank"				"0"

			// The health of bosses needed for each stage.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 1.
			// Note: The values will be added to the boss's new health on every new stage.
			// Note: The values will determine when the boss evolves to the next stage.
			// Example: When Stage 2 boss with 8000 base HP has 2500 HP or less, he will evolve into Stage 3 boss with 10500 HP (8000 + 2500 HP).
			// --
			// Character limit: 25
			// Character limit for each health stage: 5
			// --
			// Minimum value for each health stage: 1
			// Maximum value for each health stage: 65535
			// --
			// 1st number = Amount of health of the boss to make him evolve/Amount of health given to Stage 2 boss. (The "Boss Stages" setting must be set to 1 or higher.)
			// 2nd number = Amount of health of the boss to make him evolve/Amount of health given to Stage 3 boss. (The "Boss Stages" setting must be set to 2 or higher.)
			// 3rd number = Amount of health of the boss to make him evolve/Amount of health given to Stage 4 boss. (The "Boss Stages" setting must be set to 3 or higher.)
			// 4th number = Amount of health of the boss to make him evolve/Amount of health given to Stage 5 boss. (The "Boss Stages" setting must be set to 4 or higher.)
			"Boss Health Stages"			"5000,2500,1500,1000"

			// The number of stages for Mutant Tank bosses.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 1.
			// --
			// Minimum: 1
			// Maximum: 4
			"Boss Stages"				"4"

			// The Mutant Tank types that the boss will evolve into.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 1.
			// Note: Make sure that the Mutant Tank types that the boss will evolve into are enabled.
			// Example: When Stage 1 boss evolves into Stage 2, it will evolve into Tank #2.
			// --
			// Character limit: 20
			// Character limit for each stage type: 4
			// --
			// Minimum: 1
			// Maximum: 1000
			// --
			// 1st number = 2nd stage type
			// 2nd number = 3rd stage type
			// 3rd number = 4th stage type
			// 4th number = 5th stage type
			"Boss Types"				"2,3,4,5"

			// The Mutant Tank can be used by other Mutant Tanks who spawn with the Randomization mode feature.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF
			// 1: ON
			"Random Tank"				"1"

			// The Mutant Tank switches to a random type every time this many seconds passes.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 2.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Random Interval"			"5.0"

			// The Mutant Tank is able to transform again after this many seconds passes.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 3.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Transform Delay"			"10.0"

			// The Mutant Tank's transformations last this long.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 3.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Transform Duration"			"10.0"

			// The types that the Mutant Tank can transform into.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 3.
			// --
			// Separate game modes with commas.
			// --
			// Character limit: 80 (including commas)
			// Character limit for each type: 4
			// --
			// Example: "1,35,26,4"
			// Example: "4,9,49,94,449,499"
			// Example: "97,98,99,100,101,102,103,104,105,106"
			// --
			// Minimum: 1
			// Maximum: 1000
			"Transform Types"			"1,2,3,4,5,6,7,8,9,10"

			// The mode of the Mutant Tank's spawn status.
			// --
			// 0: Spawn as normal Mutant Tanks.
			// 1: Spawn as a Mutant Tank boss.
			// 2: Spawn as a Mutant Tank that switch randomly between each type.
			// 3: Spawn as a Mutant Tank that temporarily transforms into a different type and reverts back after awhile.
			"Spawn Mode"				"0"
		}
		"Props"
		{
			// Props that the Mutant Tank can spawn with.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 63
			// --
			// 0: OFF
			// 1: Attach a blur effect only.
			// 2: Attach lights only.
			// 4: Attach oxygen tanks only.
			// 8: Attach flames to oxygen tanks.
			// 16: Attach rocks only.
			// 32: Attach tires only.
			"Props Attached"			"62"

			// Each prop has this many chances out of 100.0% to appear when the Mutant Tank appears.
			// --
			// Separate chances with commas.
			// --
			// Chances limit: 6
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
			"Props Chance"				"33.3,33.3,33.3,33.3,33.3,33.3"

			// These are the RGBA values of the Mutant Tank's light prop's color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Light Color"				"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's oxygen tank prop's color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Oxygen Tank Color"			"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's oxygen tank prop's flame's color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Flame Color"				"255,255,255,180"

			// These are the RGBA values of the Mutant Tank's rock prop's color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Rock Color"				"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's tire prop's color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Tire Color"				"255,255,255,255"
		}
		"Particles"
		{
			// The particle effects for the Mutant Tank's body.
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
		"Enhancements"
		{
			// The Mutant Tank's claw attacks do this much damage.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Claw Damage"				"-1.0"

			// Extra health given to the Mutant Tank.
			// Note: Tank's health limit on any difficulty is 65,535.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the setting for "Multiply Health," the Mutant Tank's health will be multiplied based on player count.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Extra health
			// Negative numbers: Current health - Extra health
			"Extra Health"				"0"

			// The Mutant Tank's rock throws do this much damage.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Rock Damage"				"-1.0"

			// Set the Mutant Tank's run speed.
			// Note: Default run speed is 1.0.
			// --
			// OFF: -1.0
			// Minimum: 0.1
			// Maximum: 3.0
			"Run Speed"				"-1.0"

			// The Mutant Tank throws a rock every time this many seconds passes.
			// Note: Default throw interval is 5.0 seconds.
			// --
			// OFF: -1.0
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Throw Interval"			"-1.0"
		}
		"Immunities"
		{
			// Give the Mutant Tank bullet immunity.
			// --
			// 0: OFF
			// 1: ON
			"Bullet Immunity"			"0"

			// Give the Mutant Tank explosive immunity.
			// --
			// 0: OFF
			// 1: ON
			"Explosive Immunity"			"0"

			// Give the Mutant Tank fire immunity.
			// --
			// 0: OFF
			// 1: ON
			"Fire Immunity"				"0"

			// Give the Mutant Tank melee immunity.
			// --
			// 0: OFF
			// 1: ON
			"Melee Immunity"			"0"
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
		// Requires "mt_absorb.smx" to be installed.
		"Absorb Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The bullet damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Bullet damage/Absorb bullet divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage/1.0 = Bullet damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Bullet Divisor"			"20.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Absorb Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Duration"			"5.0"

			// The explosive damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Explosive damage/Absorb explosive divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage/1.0 = Explosive damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Explosive Divisor"		"20.0"

			// The fire damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Fire damage/Absorb fire divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Fire damage/1.0 = Fire damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Fire Divisor"			"200.0"

			// The melee damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Melee damage/Absorb melee divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Melee damage/1.0 = Melee damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
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
		// The Mutant Tank creates acid puddles.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, an acid puddle is created underneath the survivor. When the Mutant Tank dies, an acid puddle is created underneath the Mutant Tank.
		// - "Acid Range"
		// - "Acid Range Chance"
		// "Acid Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, an acid puddle is created underneath the survivor.
		// - "Acid Chance"
		// - "Acid Hit Mode"
		// "Acid Rock Break" - When the Mutant Tank's rock breaks, it creates an acid puddle.
		// - "Acid Rock Chance"
		// Requires "mt_acid.smx" to be installed.
		"Acid Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Acid Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
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
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Acid Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Acid Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Acid Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Acid Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Acid Range Chance"			"15.0"

			// The Mutant Tank's rock creates an acid puddle when it breaks.
			// Note: Only available in Left 4 Dead 2.
			// Note: This does not need "Ability Enabled" or "Acid Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Acid Rock Break"			"0"

			// The Mutant Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_aimless.smx" to be installed.
		"Aimless Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Aimless Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Aimless Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Aimless Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Aimless Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Aimless Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Aimless Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Aimless Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_ammo.smx" to be installed.
		"Ammo Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Ammo Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Ammo Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ammo Chance"				"33.3"

			// The Mutant Tank sets survivors' ammunition to this amount.
			// --
			// Minimum: 0
			// Maximum: 25
			"Ammo Count"				"0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Ammo Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Ammo Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ammo Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_blind.smx" to be installed.
		"Blind Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Blind Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Blind Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Blind Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Blind Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Blind Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Blind Hit Mode"			"0"

			// The intensity of the Mutant Tank's blind effect.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully blind)
			"Blind Intensity"			"255"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Blind Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_bomb.smx" to be installed.
		"Bomb Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Bomb Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
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
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bomb Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bomb Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Bomb Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Bomb Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bomb Range Chance"			"15.0"

			// The Mutant Tank's rock creates an explosion when it breaks.
			// Note: This does not need "Ability Enabled" or "Bomb Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bomb Rock Break"			"0"

			// The Mutant Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_bury.smx" to be installed.
		"Bury Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Bury Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Bury Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bury Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Bury Duration"				"5.0"

			// The Mutant Tank buries survivors this deep into the ground.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Bury Height"				"50.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bury Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Bury Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Bury Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_car.smx" to be installed.
		"Car Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Car Chance"				"33.3"

			// The Mutant Tank create car showers with these cars.
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

			// The radius of the Mutant Tank's car shower.
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
		// Requires "mt_choke.smx" to be installed.
		"Choke Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Choke Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Choke Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Choke Chance"				"33.3"

			// The Mutant Tank's chokes do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Choke Damage"				"5.0"

			// The Mutant Tank chokes survivors in the air after this many seconds passes upon triggering the ability.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Choke Delay"				"1.0"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Choke Duration"			"5.0"

			// The Mutant Tank brings survivors this high up into the air.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Choke Height"				"300.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Choke Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Choke Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Choke Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_clone.smx" to be installed.
		"Clone Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The amount of clones the Mutant Tank can create.
			// --
			// Minimum: 1
			// Maximum: 25
			"Clone Amount"				"2"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Clone Chance"				"33.3"

			// The Mutant Tank's clone's health.
			// --
			// Minimum: 1
			// Maximum: 65535
			"Clone Health"				"1000"

			// The Mutant Tank's clone will be treated as a real Mutant Tank.
			// Note: Clones cannot clone themselves for obvious safety reasons.
			// --
			// 0: OFF, the clone cannot use abilities like real Mutant Tanks.
			// 1: ON, the clone can use abilities like real Mutant Tanks.
			"Clone Mode"				"0"

			// The Mutant Tank's clones are replaced with new ones when they die.
			// --
			// 0: OFF
			// 1: ON
			"Clone Replace"				"1"
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
		// Requires "mt_cloud.smx" to be installed.
		"Cloud Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Cloud Chance"				"33.3"

			// The Mutant Tank's clouds do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
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
		// Requires "mt_drop.smx" to be installed.
		"Drop Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drop Chance"				"33.3"

			// The Mutant Tank has this many chances out of 100.0% to drop guns with a full clip.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drop Clip Chance"			"33.3"

			// The mode of the Mutant Tank's drop ability.
			// --
			// 0: Both
			// 1: Guns only.
			// 2: Melee weapons only.
			"Drop Mode"				"0"

			// The Mutant Tank's weapon size is multiplied by this value.
			// Note: Default weapon size x Drop weapon scale
			// --
			// Minimum: 1.0
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
		// Requires "mt_drug.smx" to be installed.
		"Drug Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Drug Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Drug Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drug Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drug Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Drug Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Drug Hit Mode"				"0"

			// The Mutant Tank drugs survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drug Interval"				"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Drug Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_drunk.smx" to be installed.
		"Drunk Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Drunk Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Drunk Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drunk Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drunk Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Drunk Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Drunk Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Drunk Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drunk Range Chance"			"15.0"

			// The Mutant Tank causes the survivors' speed to randomly change every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drunk Speed Interval"			"1.5"

			// The Mutant Tank causes the survivors to turn at a random direction every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
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
		// Requires "mt_electric.smx" to be installed.
		"Electric Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Electric Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Electric Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Electric Chance"			"33.3"

			// The Mutant Tank's electrocutions do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Electric Damage"			"5.0"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Electric Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Electric Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Electric Hit Mode"			"0"

			// The Mutant Tank electrocutes survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Electric Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Electric Range"			"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_enforce.smx" to be installed.
		"Enforce Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Enforce Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Enforce Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Enforce Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Enforce Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Enforce Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Enforce Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Enforce Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Enforce Range Chance"			"15.0"

			// The Mutant Tank forces survivors to only use one of the following weapon slots.
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
		// Requires "mt_fast.smx" to be installed.
		"Fast Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fast Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fast Duration"				"5.0"

			// The Mutant Tank's special speed.
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
		// Requires "mt_fire.smx" to be installed.
		"Fire Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Fire Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
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
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fire Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fire Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Fire Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Fire Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fire Range Chance"			"15.0"

			// The Mutant Tank's rock creates a fire when it breaks.
			// Note: This does not need "Ability Enabled" or "Fire Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fire Rock Break"			"0"

			// The Mutant Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// The Mutant Tank flings survivors high into the air.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is flung into the air.
		// - "Fling Range"
		// - "Fling Range Chance"
		// "Fling Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is flung into the air.
		// - "Fling Chance"
		// - "Fling Hit Mode"
		// Requires "mt_fling.smx" to be installed.
		"Fling Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Fling Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Fling Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fling Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fling Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Fling Hit Mode"			"0"

			// The force of the Mutant Tank's ability.
			// Note: This setting determines how powerful the force is.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fling Force"				"300.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Fling Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fling Range Chance"			"15.0"
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
		// The Mutant Tank takes more damage.
		// Requires "mt_fragile.smx" to be installed.
		"Fragile Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The bullet damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Bullet damage x Fragile bullet multiplier
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage x 1.0 = Bullet damage)
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Fragile Bullet Multiplier"		"5.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fragile Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Duration"			"5.0"

			// The explosive damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Explosive damage x Fragile explosive multiplier
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage x 1.0 = Explosive damage)
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Fragile Explosive Multiplier"		"5.0"

			// The fire damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Fire damage x Fragile fire multiplier
			// Example: Damage = 30.0 x 3.0 (90.0)
			// Note: Use the value "1.0" to disable this setting. (Fire damage x 1.0 = Fire damage)
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Fragile Fire Multiplier"		"3.0"

			// The melee damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Melee damage x Fragile melee multiplier
			// Example: Damage = 100.0 x 1.5 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Melee damage x 1.0 = Melee damage)
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Fragile Melee Multiplier"		"1.5"
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
		// The Mutant Tank cloaks itself and disarms survivors.
		// "Ability Enabled" - When a Mutant Tank spawns, it becomes invisible.
		// - "Ghost Fade Alpha"
		// - "Ghost Fade Delay"
		// - "Ghost Fade Limit"
		// - "Ghost Fade Rate"
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is disarmed.
		// - "Ghost Range"
		// - "Ghost Range Chance"
		// "Ghost Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is disarmed.
		// - "Ghost Chance"
		// - "Ghost Hit Mode"
		// Requires "mt_ghost.smx" to be installed.
		"Ghost Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Ghost Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can disarm survivors.
			// 2: ON, the Mutant Tank can cloak itself.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Ghost Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 4: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ghost Chance"				"33.3"

			// The amount of alpha to take from the Mutant Tank's alpha every X seconds until the limit set by the "Ghost Fade Limit" is reached.
			// Note: The rate at which the Mutant Tank's alpha is reduced depends on the "Ghost Fade Rate" setting.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully faded)
			"Ghost Fade Alpha"			"2"

			// The Mutant Tank's ghost fade effect starts all over after this many seconds passes upon reaching the limit set by the "Ghost Fade Limit" setting.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ghost Fade Delay"			"5.0"

			// The limit of the Mutant Tank's ghost fade effect.
			// --
			// Minimum: 0 (Fully faded)
			// Maximum: 255 (No effect)
			"Ghost Fade Limit"			"0"

			// The rate of the Mutant Tank's ghost fade effect.
			// --
			// Minimum: 0.1 (Fastest)
			// Maximum: 9999999999.0 (Slowest)
			"Ghost Fade Rate"			"0.1"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Ghost Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Ghost Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ghost Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ghost Range Chance"			"15.0"

			// The Mutant Tank disarms the following weapon slots.
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
		// Requires "mt_god.smx" to be installed.
		"God Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"God Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"God Duration"				"5.0"
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
		// Requires "mt_gravity.smx" to be installed.
		"Gravity Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Gravity Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can change survivors' gravity value.
			// 2: ON, the Mutant Tank can pull in or push away survivors.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Gravity Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 4: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Gravity Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Gravity Duration"			"5.0"

			// The Mutant Tank's gravity force.
			// --
			// Minimum: -100.0
			// Maximum: 100.0
			// --
			// Positive numbers = Push back
			// Negative numbers = Pull back
			"Gravity Force"				"-50.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Gravity Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Gravity Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Gravity Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Gravity Range Chance"			"15.0"

			// The Mutant Tank sets the survivors' gravity to this value.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
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
		// Requires "mt_heal.smx" to be installed.
		"Heal Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Heal Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can give survivors temporary health.
			// 2: ON, the Mutant Tank can absorb health from nearby infected.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Heal Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 4: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The distance between an infected and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Heal Absorb Range"			"500.0"

			// The amount of temporary health given to survivors.
			// --
			// Minimum: 1.0
			// Maximum: 65535.0
			"Heal Buffer"				"25.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Heal Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Heal Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Heal Hit Mode"				"0"

			// The Mutant Tank receives health from nearby infected every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Heal Interval"				"5.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Heal Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Heal Range Chance"			"15.0"

			// The Mutant Tank receives this much health from nearby common infected.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Health from commons
			// Negative numbers: Current health - Health from commons
			"Health From Commons"			"50"

			// The Mutant Tank receives this much health from other nearby special infected.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Health from specials
			// Negative numbers: Current health - Health from specials
			"Health From Specials"			"100"

			// The Mutant Tank receives this much health from other nearby Tanks.
			// --
			// Minimum: -65535
			// Maximum: 65535
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
		// Requires "mt_hit.smx" to be installed.
		"Hit Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// The damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Damage x Hit damage multiplier
			// Example: Damage = 30.0 x 1.5 (45.0)
			// Note: Use the value "1.0" to disable this setting. (Damage x 1.0 = Damage)
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Hit Damage Multiplier"			"1.5"

			// The only part of the Mutant Tank that can be damage.
			// --
			// 1: Headshots only.
			// 2: Chest shots only.
			// 3: Stomach shots only.
			// 4: Left arm shots only.
			// 5: Right arm shots only.
			// 6: Left leg shots only.
			// 7: Right leg shots only.
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
		// Requires "mt_hurt.smx" to be installed.
		"Hurt Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Hurt Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Hurt Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Hurt Chance"				"33.3"

			// The Mutant Tank's pain inflictions do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Hurt Damage"				"5.0"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hurt Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Hurt Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Hurt Hit Mode"				"0"

			// The Mutant Tank hurts survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hurt Interval"				"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Hurt Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_hypno.smx" to be installed.
		"Hypno Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Hypno Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Hypno Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The bullet damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Bullet damage/Hypno bullet divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage/1.0 = Bullet damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Bullet Divisor"			"20.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Hypno Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Duration"			"5.0"

			// The explosive damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Explosive damage/Hypno explosive divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage/1.0 = Explosive damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Explosive Divisor"		"20.0"

			// The fire damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Fire damage/Hypno fire divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Fire damage/1.0 = Fire damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Fire Divisor"			"200.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Hypno Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Hypno Hit Mode"			"0"

			// The melee damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Melee damage/Hypno melee divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Melee damage/1.0 = Melee damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Melee Divisor"			"200.0"

			// The mode of the Mutant Tank's hypno ability.
			// --
			// 0: Hypnotized survivors hurt themselves.
			// 1: Hypnotized survivors can hurt their teammates.
			"Hypno Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Hypno Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_ice.smx" to be installed.
		"Ice Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Ice Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Ice Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ice Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ice Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Ice Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Ice Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ice Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_idle.smx" to be installed.
		"Idle Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Idle Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Idle Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Idle Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Idle Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Idle Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Idle Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_invert.smx" to be installed.
		"Invert Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Invert Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Invert Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Invert Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Invert Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Invert Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Invert Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Invert Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_item.smx" to be installed.
		"Item Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Item Chance"				"33.3"

			// The Mutant Tank gives survivors this loadout.
			// --
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "rifle_m60,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "firmt_aid_kit,defibrillator,knife,adrenaline"
			"Item Loadout"				"rifle,pistol,firmt_aid_kit,pain_pills"

			// The mode of the Mutant Tank's item ability.
			// --
			// 0: Survivors get a random item.
			// 1: Survivors get all items.
			"Item Mode"				"0"
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
		// Requires "mt_jump.smx" to be installed.
		"Jump Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Jump Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can force survivors to jump uncontrollably.
			// 2: ON, the Mutant Tank can jump periodically.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Jump Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 4: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Jump Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Duration"				"5.0"

			// The Mutant Tank and survivors jump this high off a surface.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Height"				"300.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Jump Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Jump Hit Mode"				"0"

			// The Mutant Tank jumps every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Interval"				"1.0"

			// The mode of the Mutant Tank's jumping ability.
			// --
			// 0: The Mutant Tank jumps periodically.
			// 1: The Mutant Tank jumps sporadically.
			"Jump Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Jump Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Jump Range Chance"			"15.0"

			// The Mutant Tank has this many chances out of 100.0% to jump sporadically.
			// Note: This setting only applies if the "Jump Mode" setting is set to 1.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Jump Sporadic Chance"			"33.3"

			// The Mutant Tank jumps this high up into the air.
			// Note: This setting only applies if the "Jump Mode" setting is set to 1.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
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
		// Requires "mt_kamikaze.smx" to be installed.
		"Kamikaze Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Enable this ability.
			// Note: This setting does not affect the "Kamikaze Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Kamikaze Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Kamikaze Chance"			"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Kamikaze Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Kamikaze Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Kamikaze Range"			"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_lag.smx" to be installed.
		"Lag Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Lag Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Lag Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Lag Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Lag Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Lag Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Lag Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Lag Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Lag Range Chance"			"15.0"
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
		// Requires "mt_leech.smx" to be installed.
		"Leech Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Leech Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Leech Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Leech Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Leech Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Leech Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Leech Hit Mode"			"0"

			// The Mutant Tank leeches health off of survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Leech Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Leech Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Leech Range Chance"			"15.0"
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
		// The Mutant Tank heals special infected upon death.
		// Requires "mt_medic.smx" to be installed.
		"Medic Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the upon-death ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can heal nearby special infected upon death.
			// 2: ON, the Mutant Tank can heal nearby special infected periodically.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Ability Enabled" is set to 1 or 3.
			// 2: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Medic Chance"				"33.3"

			// The Mutant Tank gives special infected this much health each time.
			// --
			// Minimum: -65535
			// Maximum: 65535
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
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Medic Interval"			"5.0"

			// The special infected's max health.
			// Note: The Mutant Tank will not heal special infected if they already have this much health.
			// --
			// Minimum: 1
			// Maximum: 65535
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
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
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
		// Requires "mt_meteor.smx" to be installed.
		"Meteor Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Meteor Chance"				"33.3"

			// The Mutant Tank's meteorites do this much damage.
			// Note: This setting only applies if the "Meteor Mode" setting is set to 1.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Meteor Damage"				"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Meteor Duration"			"5.0"

			// The mode of the Mutant Tank's meteor shower ability.
			// --
			// 0: The Mutant Tank's meteorites will explode and start fires.
			// 1: The Mutant Tank's meteorites will explode and damage and push back nearby survivors.
			"Meteor Mode"				"0"

			// The radius of the Mutant Tank's meteor shower.
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
		// Requires "mt_minion.smx" to be installed.
		"Minion Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The amount of minions the Mutant Tank can spawn.
			// --
			// Minimum: 1
			// Maximum: 25
			"Minion Amount"				"5"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Minion Chance"				"33.3"

			// The Mutant Tank's minions are replaced with new ones when they die.
			// --
			// 0: OFF
			// 1: ON
			"Minion Replace"			"1"

			// The Mutant Tank spawns these minions.
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
			// 8: Spitter (Switches to Boomer in L4D1.)
			// 16: Jockey (Switches to Hunter in L4D1.)
			// 32: Charger (Switches to Smoker in L4D1.)
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
		// Requires "mt_necro.smx" to be installed.
		"Necro Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Necro Chance"				"33.3"

			// The distance between a special infected and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
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
		// Requires "mt_nullify.smx" to be installed.
		"Nullify Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Nullify Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Nullify Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Nullify Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Nullify Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Nullify Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Nullify Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Nullify Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_omni.smx" to be installed.
		"Omni Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Omni Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Omni Duration"				"5.0"

			// The mode of the Mutant Tank's omni ability.
			// --
			// 0: The Mutant Tank's type becomes the same as the nearby Mutant Tank's type.
			// 1: The Mutant Tank physically transforms into the nearby Mutant Tank.
			"Omni Mode"				"0"

			// The distance between another Mutant Tank and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
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
		// Requires "mt_panic.smx" to be installed.
		"Panic Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Panic Chance"				"33.3"

			// The Mutant Tank starts a panic event every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
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
		// Requires "mt_pimp.smx" to be installed.
		"Pimp Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Pimp Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Pimp Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Pimp Chance"				"33.3"

			// The Mutant Tank's pimp slaps do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Pimp Damage"				"5"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Pimp Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Pimp Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Pimp Hit Mode"				"0"

			// The Mutant Tank pimp slaps survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Pimp Interval"				"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Pimp Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// "Puke Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the Mutant Tank pukes on the survivor.
		// - "Puke Chance"
		// - "Puke Hit Mode"
		// Requires "mt_puke.smx" to be installed.
		"Puke Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Puke Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Puke Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Puke Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Puke Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Puke Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Puke Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_pyro.smx" to be installed.
		"Pyro Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Pyro Chance"				"33.3"

			// The Mutant Tank's damage boost value when on fire.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Pyro Damage Boost"			"1.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Pyro Duration"				"5.0"

			// The mode of the Mutant Tank's damage and speed boosts.
			// --
			// 0:
			// Mutant Tank's damage = Claw/rock damage + Pyro damage boost
			// Mutant Tank's speed = Run speed + Pyro speed boost
			// 1:
			// Mutant Tank's damage = Pyro damage boost
			// Mutant Tank's speed = Pyro speed boost
			"Pyro Mode"				"0"

			// The Mutant Tank's speed boost value when on fire.
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
		// Requires "mt_quiet.smx" to be installed.
		"Quiet Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Quiet Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Quiet Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Quiet Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Quiet Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Quiet Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Quiet Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Quiet Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_recoil.smx" to be installed.
		"Recoil Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Recoil Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Recoil Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Recoil Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Recoil Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Recoil Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Recoil Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Recoil Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_regen.smx" to be installed.
		"Regen Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Regen Chance"				"33.3"

			// The Mutant Tank regenerates this much health each time.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Regen health
			// Negative numbers: Current health - Regen health
			"Regen Health"				"1"

			// The Mutant Tank regenerates health every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Regen Interval"			"1.0"

			// The Mutant Tank stops regenerating health at this value.
			// --
			// Minimum: 1
			// Maximum: 65535
			"Regen Limit"				"65535"
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
		// Requires "mt_respawn.smx" to be installed.
		"Respawn Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank respawns up to this many times.
			// Note: This setting only applies if the "Respawn Random" setting is set to 0.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Respawn Amount"			"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Respawn Chance"			"33.3"

			// The mode of the Mutant Tank's respawns.
			// --
			// 0: The Mutant Tank respawns as the same type.
			// 1: The Mutant Tank respawns as the type used in the "Respawn Type" setting.
			// 2: The Mutant Tank respawns as a random type.
			"Respawn Mode"				"0"

			// The type that the Mutant Tank will respawn as.
			// --
			// 0: OFF, use the randomization feature.
			// 1-1000: ON, the type to respawn as.
			"Respawn Type"				"0"
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
		// Requires "mt_restart.smx" to be installed.
		"Restart Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Restart Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Restart Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Restart Chance"			"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Restart Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Restart Hit Mode"			"0"

			// The Mutant Tank makes survivors restart with this loadout.
			// --
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "smg_silenced,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "firmt_aid_kit,defibrillator,knife,adrenaline"
			"Restart Loadout"			"smg,pistol,pain_pills"

			// The mode of the Mutant Tank's restart ability.
			// --
			// 0: Survivors are teleported to the spawn area.
			// 1: Survivors are teleported to another teammate.
			"Restart Mode"				"1"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Restart Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_rock.smx" to be installed.
		"Rock Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Rock Chance"				"33.3"

			// The Mutant Tank's rocks do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Rock Damage"				"5"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Rock Duration"				"5.0"

			// The radius of the Mutant Tank's rock shower.
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
		// Requires "mt_rocket.smx" to be installed.
		"Rocket Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Rocket Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Rocket Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Rocket Chance"				"33.3"

			// The Mutant Tank sends survivors into space after this many seconds passes upon triggering the ability.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Rocket Delay"				"1.0"

			// Enable the Mutant Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Rocket Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Rocket Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Rocket Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// "Shake Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor's screen is shaken.
		// - "Shake Chance"
		// - "Shake Hit Mode"
		// Requires "mt_shake.smx" to be installed.
		"Shake Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Shake Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Shake Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shake Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shake Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Shake Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Shake Hit Mode"			"0"

			// The Mutant Tank shakes survivors' screems every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shake Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Shake Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_shield.smx" to be installed.
		"Shield Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shield Chance"				"33.3"

			// These are the RGBA values of the Mutant Tank's shield prop's color.
			// Note: Any value less than 0 will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Shield Color"				"255 255 255 50"

			// The Mutant Tank's shield reactivates after this many seconds passes upon destroying the shield.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shield Delay"				"5.0"

			// The type of the Mutant Tank's shield'.
			// --
			// 0: Bullet-based (Requires bullets to break shield.)
			// 1: Blast-based (Requires explosives to break shield.)
			// 2: Fire-based (Requires fires to break shield.)
			// 3: Melee-based (Requires melee weapons to break shield.)
			"Shield Type"				"1"
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
		// "Shove Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is shoved repeatedly.
		// - "Shove Chance"
		// - "Shove Hit Mode"
		// Requires "mt_shove.smx" to be installed.
		"Shove Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Shove Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Shove Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shove Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shove Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Shove Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Shove Hit Mode"			"0"

			// The Mutant Tank shoves survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shove Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Shove Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_slow.smx" to be installed.
		"Slow Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Slow Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Slow Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Slow Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Slow Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Slow Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Slow Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Slow Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Slow Range Chance"			"15.0"

			// The Mutant Tank sets the survivors' run speed to this value.
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
		// Requires "mt_smash.smx" to be installed.
		"Smash Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Smash Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Smash Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Smash Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Smash Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Smash Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Smash Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_smite.smx" to be installed.
		"Smite Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Smite Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Smite Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Smite Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Smite Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Smite Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Smite Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_spam.smx" to be installed.
		"Spam Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Spam Chance"				"33.3"

			// The Mutant Tank's rocks do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Spam Damage"				"5"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Spam Duration"				"5.0"
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
		// Requires "mt_splash.smx" to be installed.
		"Splash Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Splash Chance"				"33.3"

			// The Mutant Tank's splashes do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Splash Damage"				"5.0"

			// The Mutant Tank deals splash damage to nearby survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Splash Interval"			"5.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Splash Range"				"500.0"
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
		// Requires "mt_throw.smx" to be installed.
		"Throw Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
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

			// Display a message whenever the ability activate/deactivate.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: OFF
			// 1: Display message only when "Ability Enabled" is set to 1.
			// 2: Display message only when "Ability Enabled" is set to 2.
			// 4: Display message only when "Ability Enabled" is set to 3.
			// 8: Display message only when "Ability Enabled" is set to 4.
			"Ability Message"			"0"

			// The Mutant Tank throws these cars.
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

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Throw Chance"				"33.3"

			// The Mutant Tank throws these special infected.
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
			// 8: Spitter (Switches to Boomer in L4D1.)
			// 16: Jockey (Switches to Hunter in L4D1.)
			// 32: Charger (Switches to Smoker in L4D1.)
			// 64: Tank
			"Throw Infected Options"		"0"
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
		// Requires "mt_track.smx" to be installed.
		"Track Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Track Chance"				"33.3"

			// The mode of the Mutant Tank's track ability.
			// --
			// 0: The Mutant Tank's rock will only start tracking when it is near a survivor.
			// 1: The Mutant Tank's rock will track the nearest survivor.
			"Track Mode"				"1"

			// The Mutant Tank's track ability is this fast.
			// Note: This setting only applies if the "Track Mode" setting is set to 1.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
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
		// Requires "mt_ultimate.smx" to be installed.
		"Ultimate Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank can activate ultimate mode up to this many times.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Ultimate Amount"			"1"

			// The Mutant Tank's damage boost value during ultimate mode.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ultimate Damage Boost"			"1.2"

			// The Mutant Tank must deal this much damage to survivors to activate ultimate mode.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ultimate Damage Required"		"200.0"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ultimate Duration"			"5.0"

			// The Mutant Tank can activate ultimate mode when its health is equal to or below this value.
			// --
			// Minimum: 1
			// Maximum: 65535
			"Ultimate Health Limit"			"100"

			// The Mutant Tank regenerates up to this much percentage of its original health upon activating ultimate mode.
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
		// Requires "mt_undead.smx" to be installed.
		"Undead Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank stays alive up to this many times.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Undead Amount"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_vampire.smx" to be installed.
		"Vampire Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// 0: OFF
			// 1: ON
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_vision.smx" to be installed.
		"Vision Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Vision Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Vision Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Vision Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Vision Duration"			"5.0"

			// The Mutant Tank sets survivors' fields of view to this value.
			// --
			// Minimum: 1
			// Maximum: 160
			"Vision FOV"				"160"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Vision Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Vision Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Vision Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// "Ability Enabled" - The Tank warps to a random survivor.
		// - "Warp Interval"
		// - "Warp Mode"
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is warped to a random teammate.
		// - "Warp Range"
		// - "Warp Range Chance"
		// "Warp Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is warped to a random teammate.
		// - "Warp Chance"
		// - "Warp Hit Mode"
		// Requires "mt_warp.smx" to be installed.
		"Warp Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Warp Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can warp a survivor to a random teammate.
			// 2: ON, the Mutant Tank can warp itself to a survivor.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Warp Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 4: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Warp Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Warp Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Warp Hit Mode"				"0"

			// The Mutant Tank warps to a random survivor every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Warp Interval"				"5.0"

			// The mode of the Mutant Tank's warp ability.
			// --
			// 0: The Mutant Tank warps to a random survivor.
			// 1: The Mutant Tank switches places with a random survivor.
			"Warp Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Warp Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
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
		// Requires "mt_whirl.smx" to be installed.
		"Whirl Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Whirl Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
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
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Whirl Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The axis of the Mutant Tank's whirl effect.
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
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Whirl Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Whirl Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Whirl Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			"Whirl Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Whirl Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Whirl Range Chance"			"15.0"

			// The Mutant Tank makes survivors whirl at this speed.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
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
		// Requires "mt_witch.smx" to be installed.
		"Witch Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank converts this many common infected into Witch minions at once.
			// --
			// Minimum: 1
			// Maximum: 25
			"Witch Amount"				"3"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Witch Chance"				"33.3"

			// The Mutant Tank's Witch minion causes this much damage per hit.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Witch Damage"				"5"

			// The distance between a common infected and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Witch Range"				"500.0"
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
		// Requires "mt_xiphos.smx" to be installed.
		"Xiphos Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// 0: OFF
			// 1: ON
			"Ability Effect"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Xiphos Chance"				"33.3"

			// The survivors' max health.
			// Note: Survivors will not gain health if they already have this much health.
			// --
			// Minimum: 1
			// Maximum: 65535
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
		// Requires "mt_yell.smx" to be installed.
		"Yell Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Yell Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Yell Duration"				"5.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
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
		// Requires "mt_zombie.smx" to be installed.
		"Zombie Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// --
			// Empty: No access flags are immune.
			// Not empty: These access flags are immune.
			"Access Flags"				""

			// Allow human-controlled Mutant Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"			"0"

			// The Mutant Tank spawns this many common infected at once.
			// --
			// Minimum: 1
			// Maximum: 100
			"Zombie Amount"				"10"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Zombie Chance"				"33.3"

			// The Mutant Tank spawns a zombie mob every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Zombie Interval"			"5.0"
		}
	}
}
```

### Administration System

```
"Mutant Tanks"
{
	// Use the admin's Steam32ID or Steam3ID when making an entry.
	"STEAM_0:1:23456789" // [U:1:23456789]
	{
		"Administration"
		{
			// This is the Mutant Tank type that the admin will spawn with.
			// Note: If the "Spawn Mode" setting under the "Plugin Settings/Human Support" section is set to 1, the admin will be prompted a menu asking if the admin wants to use this type.
			// --
			// 0: OFF, use the randomization feature.
			// 1-1000: ON, the type that will be favorited.
			"Favorite Type"				"0"

			// Admins with one or more of these access flags have access to all Mutant Tank types.
			// Note: This setting overrides all other "Access Flags" settings above.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to all Mutant Tanks' attacks.
			// Note: This setting overrides all other "Immunity Flags" settings above.
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
		// Note: Admins can each have their own personalized/custom Mutant Tanks by using the same settings above in the "Tank Settings" sections.
	}
}
```