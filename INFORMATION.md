# Information
> Everything you need to know about each ability/setting is below. Don't expect any help from the developer if you don't take the time to read everything below first.

- Maximum types: 500
- Ability count: 66
- Please don't report any bugs or issues if you're using the plugins on a listen server. No support will be provided for that kind of server.
- THIS FILE IS NOT THE CONFIG FILE! USE IT AS A REFERENCE!

## Plugin Settings

```
"Super Tanks++"
{
	// These are the general plugin settings.
	// Note: The following settings will not work in custom config files:
	// Any setting under the "Game Modes" section.
	// Any setting under the "Custom" section.
	"Plugin Settings"
	{
		"General"
		{
			// Enable Super Tanks++.
			// --
			// 0: OFF
			// 1: ON
			"Plugin Enabled"			"1"

			// Announce each Super Tank's arrival.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 5
			// --
			// 1: Announce when a Super Tank spawns.
			// 2: Announce when a Super Tank evolves. (Only works when "Spawn Mode" is set to 1.)
			// 3: Announce when a Super Tank randomizes. (Only works when "Spawn Mode" is set to 2.)
			// 4: Announce when a Super Tank transforms. (Only works when "Spawn Mode" is set to 3.)
			// 5: Announce when a Super Tank untransforms. (Only works when "Spawn Mode" is set to 3.)
			"Announce Arrival"			"12345"

			// Announce each Super Tank's death.
			// --
			// 0: OFF
			// 1: ON
			"Announce Death"			"1"

			// Display Tanks' names and health.
			// --
			// 0: OFF
			// 1: ON, show names only.
			// 2: ON, show health only.
			// 3: ON, show both names and health.
			"Display Health"			"3"

			// Enable Super Tanks++ in finales only.
			// --
			// 0: OFF
			// 1: ON
			"Finales Only"				"0"

			// Multiply the Super Tank's health.
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
			// Maximum number for each value: 500
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			"Type Range"				"1-500"
		}
		"Waves"
		{
			// Spawn this many Tanks on non-finale maps periodically.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Regular Amount"			"2"

			// Spawn Tanks on non-finale maps every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Regular Interval"			"300.0"

			// Spawn Tanks on non-finale maps periodically.
			// --
			// 0: OFF
			// 1: ON
			"Regular Wave"				"0"

			// Amount of Tanks to spawn for each finale wave.
			// --
			// Separate waves with commas.
			// --
			// Wave limit: 3
			// Character limit for each wave: 3
			// --
			// Minimum value for each wave: 1
			// Maximum value for each wave: 9999999999
			// --
			// 1st number = 1st wave
			// 2nd number = 2nd wave
			// 3rd number = 3rd wave
			"Finale Waves"				"2,3,4"
		}
		"Game Modes"
		{
			// Enable Super Tanks++ in these game mode types.
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: All game mode types.
			// 1: Co-Op modes only.
			// 2: Versus modes only.
			// 4: Survival modes only.
			// 8: Scavenge modes only. (Only available in Left 4 Dead 2.)
			"Game Mode Types"			"0"

			// Enable Super Tanks++ in these game modes.
			// --
			// Separate game modes with commas.
			// --
			// Character limit: 512 (including commas)
			// --
			// Empty: All
			// Not empty: Enabled only in these game modes.
			"Enabled Game Modes"			""

			// Disable Super Tanks++ in these game modes.
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
			// Enable Super Tanks++ custom configuration.
			// --
			// 0: OFF
			// 1: ON
			"Enable Custom Configs"			"0"

			// The type of custom config that Super Tanks++ creates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 5
			// --
			// 1: Difficulties
			// 2: Maps
			// 3: Game modes
			// 4: Days
			// 5: Player count
			"Create Config Types"			"12345"

			// The type of custom config that Super Tanks++ executes.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 5
			// --
			// 1: Difficulties
			// 2: Maps
			// 3: Game modes
			// 4: Days
			// 5: Player count
			"Execute Config Types"			"1"
		}
	}
}
```

## Tank Settings

### General, Spawn, Props, Particles, Enhancements, Immunities

```
"Super Tanks++"
{
	"Tank #1"
	{
		"General"
		{
			// Name of the Super Tank.
			// Character limit: 32
			// --
			// Empty: "Tank"
			// Not Empty: Tank's custom name
			"Tank Name"				"Tank #1"

			// Enable the Super Tank.
			// Note: This setting determines full enablement. Even if other settings are enabled while this is disabled, the Super Tank will stay disabled.
			// --
			// 0: OFF
			// 1: ON
			"Tank Enabled"				"0"

			// The Super Tank has this many chances out of 100.0% to spawn.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: Clones, respawned Super Tanks, randomized Tanks, and Super Tanks spawned through the Super Tanks++ menu are not affected. 
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Tank Chance"				"100.0"

			// Display a note for the Super Tank when it spawns.
			// Note: This note can also be displayed for clones if "Clone Mode" is set to 1, so the chat could be spammed if multiple clones spawn.
			// Note: A note must be manually created in the translation file.
			// Note: Tank notes support chat color tags in the translation file.
			// --
			// 0: OFF
			// 1: ON
			"Tank Note"				"0"

			// The game can spawn the Super Tank.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: The Super Tank will still appear on the Super Tanks++ menu and other Super Tanks can still transform into the Super Tank.
			// --
			// 0: OFF
			// 1: ON
			"Spawn Enabled"				"1"

			// The Super Tank can be spawned through the "sm_tank" command.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF
			// 1: ON
			"Menu Enabled"				"1"

			// Enable support for human-controlled Super Tanks.
			// --
			// 0: OFF
			// 1: ON
			"Human Support"				"0"

			// These are the RGBA values of the Super Tank's skin color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Skin Color"				"255 255 255 255"

			// The Super Tank will have a glow outline.
			// Only available in Left 4 Dead 2.
			// --
			// 0: OFF
			// 1: ON
			"Glow Enabled"				"1"

			// These are the RGB values of the Super Tank's glow outline color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			"Glow Color"				"255 255 255"
		}
		"Spawn"
		{
			// The number of Super Tanks with this type that can be alive at any given time.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: Clones, respawned Super Tanks, randomized Tanks, and Super Tanks spawned through the Super Tanks++ menu are not affected. 
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Type Limit"				"32"

			// The Super Tank will only spawn on finale maps.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: Clones, respawned Super Tanks, randomized Tanks, and Super Tanks spawned through the Super Tanks++ menu are not affected. 
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
			// 1st number = Amount of health of the boss to make him evolve/Amount of health given to Stage 2 boss. (The "Boss Stages" setting must be set to "1" or higher.)
			// 2nd number = Amount of health of the boss to make him evolve/Amount of health given to Stage 3 boss. (The "Boss Stages" setting must be set to "2" or higher.)
			// 3rd number = Amount of health of the boss to make him evolve/Amount of health given to Stage 4 boss. (The "Boss Stages" setting must be set to "3" or higher.)
			// 4th number = Amount of health of the boss to make him evolve/Amount of health given to Stage 5 boss. (The "Boss Stages" setting must be set to "4" or higher.)
			"Boss Health Stages"			"5000,2500,1500,1000"

			// The number of stages for Super Tank bosses.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 1.
			// --
			// Minimum: 1
			// Maximum: 4
			"Boss Stages"				"3"

			// The Super Tank types that the boss will evolve into.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 1.
			// Note: Make sure that the Super Tank types that the boss will evolve into are enabled.
			// Example: When Stage 1 boss evolves into Stage 2, it will evolve into Tank #2.
			// --
			// Character limit: 20
			// Character limit for each stage type: 4
			// --
			// Minimum: 1
			// Maximum: 500
			// --
			// 1st number = 2nd stage type
			// 2nd number = 3rd stage type
			// 3rd number = 4th stage type
			// 4th number = 5th stage type
			"Boss Types"				"2,3,4,5"

			// The Super Tank can be used by other Super Tanks who spawn with the Randomization mode feature.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF
			// 1: ON
			"Random Tank"				"1"

			// The Super Tank switches to a random type every time this many seconds passes.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 2.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Random Interval"			"5.0"

			// The Super Tank is able to transform again after this many seconds passes.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 3.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Transform Delay"			"10.0"

			// The Super Tank's transformations last this long.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 3.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Transform Duration"			"10.0"

			// The types that the Super Tank can transform into.
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
			// Maximum: 500
			"Transform Types"			"1,2,3,4,5,6,7,8,9,10"

			// The mode of the Super Tank's spawn status.
			// --
			// 0: Spawn as normal Super Tanks.
			// 1: Spawn as a Super Tank boss.
			// 2: Spawn as a Super Tank that switch randomly between each type.
			// 3: Spawn as a Super Tank that temporarily transforms into a different type and reverts back after awhile.
			"Spawn Mode"				"0"
		}
		"Props"
		{
			// Props that the Super Tank can spawn with.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 6
			// --
			// 1: Attach a blur effect only.
			// 2: Attach lights only.
			// 3: Attach oxygen tanks only.
			// 4: Attach flames to oxygen tanks.
			// 5: Attach rocks only.
			// 6: Attach tires only.
			"Props Attached"			"23456"

			// Each prop has this many chances out of 100.0% to appear when the Super Tank appears.
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

			// These are the RGBA values of the Super Tank's light prop's color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Light Color"				"255 255 255 255"

			// These are the RGBA values of the Super Tank's oxygen tank prop's color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Oxygen Tank Color"			"255 255 255 255"

			// These are the RGBA values of the Super Tank's oxygen tank prop's flame's color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Flame Color"				"255 255 255 180"

			// These are the RGBA values of the Super Tank's rock prop's color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Rock Color"				"255 255 255 255"

			// These are the RGBA values of the Super Tank's tire prop's color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Tire Color"				"255 255 255 255"
		}
		"Particles"
		{
			// The Super Tank's body will have a particle effect.
			// --
			// 0: OFF
			// 1: ON
			"Body Particle"				"0"

			// The particle effects for the Super Tank's body.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 7
			// --
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 3: Fire Trail
			// 4: Ice Steam
			// 5: Meteor Smoke
			// 6: Smoker Cloud
			// 7: Acid Trail (Only available in Left 4 Dead 2.)
			"Body Effects"				"1234567"

			// The Super Tank's rock will have a particle effect.
			// --
			// 0: OFF
			// 1: ON
			"Rock Particle"				"0"

			// The particle effects for the Super Tank's rock.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 4
			// --
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 3: Fire Trail
			// 4: Acid Trail (Only available in Left 4 Dead 2.)
			"Rock Effects"				"1234"
		}
		"Enhancements"
		{
			// The Super Tank's claw attacks do this much damage.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Claw Damage"				"-1.0"

			// Base health given to the Super Tank.
			// Note: Tank's health limit on any difficulty is 65,535.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the setting for "Multiply Health," the Super Tank's health will be multiplied based on player count.
			// --
			// Minimum: 0 (OFF)
			// Maximum: 65535
			"Base Health"				"0"

			// Extra health given to the Super Tank.
			// Note: Tank's health limit on any difficulty is 65,535.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the setting for "Multiply Health," the Super Tank's health will be multiplied based on player count.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Extra health
			// Negative numbers: Current health - Extra health
			"Extra Health"				"0"

			// The Super Tank's rock throws do this much damage.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Rock Damage"				"-1.0"

			// Set the Super Tank's run speed.
			// Note: Default run speed is 1.0.
			// --
			// OFF: -1.0
			// Minimum: 0.1
			// Maximum: 3.0
			"Run Speed"				"-1.0"

			// The Super Tank throws a rock every time this many seconds passes.
			// Note: Default throw interval is 5.0 seconds.
			// --
			// OFF: -1.0
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Throw Interval"			"-1.0"
		}
		"Immunities"
		{
			// Give the Super Tank bullet immunity.
			// --
			// 0: OFF
			// 1: ON
			"Bullet Immunity"			"0"

			// Give the Super Tank explosive immunity.
			// --
			// 0: OFF
			// 1: ON
			"Explosive Immunity"			"0"

			// Give the Super Tank fire immunity.
			// --
			// 0: OFF
			// 1: ON
			"Fire Immunity"				"0"

			// Give the Super Tank melee immunity.
			// --
			// 0: OFF
			// 1: ON
			"Melee Immunity"			"0"
		}
	}
}
```

### Abilities

#### Absorb Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank absorbs most of the damage it receives.
		// Requires "st_absorb.smx" to be installed.
		"Absorb Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The bullet damage received by the Super Tank is divided by this value.
			// Note: Damage = Bullet damage/Absorb bullet divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage/1.0 = Bullet damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Bullet Divisor"			"20.0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Absorb Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Duration"			"5.0"

			// The explosive damage received by the Super Tank is divided by this value.
			// Note: Damage = Explosive damage/Absorb explosive divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage/1.0 = Explosive damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Explosive Divisor"		"20.0"

			// The fire damage received by the Super Tank is divided by this value.
			// Note: Damage = Fire damage/Absorb fire divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Fire damage/1.0 = Fire damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Fire Divisor"			"200.0"

			// The melee damage received by the Super Tank is divided by this value.
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

#### Acid Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank creates acid puddles.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, an acid puddle is created underneath the survivor. When the Super Tank dies, an acid puddle is created underneath the Super Tank.
		// - "Acid Range"
		// - "Acid Range Chance"
		// "Acid Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, an acid puddle is created underneath the survivor.
		// - "Acid Chance"
		// - "Acid Hit Mode"
		// "Acid Rock Break" - When the Super Tank's rock breaks, it creates an acid puddle.
		// - "Acid Rock Chance"
		// Requires "st_acid.smx" to be installed.
		"Acid Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Acid Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// 3: Display message only when "Acid Rock Break" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Acid Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Acid Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Acid Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Acid Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Acid Range Chance"			"15.0"

			// The Super Tank's rock creates an acid puddle when it breaks.
			// Note: Only available in Left 4 Dead 2.
			// Note: This does not need "Ability Enabled" or "Acid Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Acid Rock Break"			"0"

			// The Super Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Acid Rock Chance"			"33.3"
		}
	}
}
```

#### Aimless Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank prevents survivors from aiming.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor cannot aim.
		// - "Aimless Range"
		// - "Aimless Range Chance"
		// "Aimless Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor cannot aim.
		// - "Aimless Chance"
		// - "Aimless Hit Mode"
		// Requires "st_aimless.smx" to be installed.
		"Aimless Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Aimless Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Aimless Chance"			"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Aimless Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Aimless Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Aimless Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Aimless Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Aimless Range Chance"			"15.0"
		}
	}
}
```

#### Ammo Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank takes away survivors' ammunition.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, their ammunition is taken away.
		// - "Ammo Range"
		// - "Ammo Range Chance"
		// "Ammo Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, their ammunition is taken away.
		// - "Ammo Chance"
		// - "Ammo Hit Mode"
		// Requires "st_ammo.smx" to be installed.
		"Ammo Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Ammo Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ammo Chance"				"33.3"

			// The Super Tank sets survivors' ammunition to this amount.
			// --
			// Minimum: 0
			// Maximum: 25
			"Ammo Count"				"0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Ammo Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Ammo Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ammo Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ammo Range Chance"			"15.0"
		}
	}
}
```

#### Blind Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank blinds survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is blinded.
		// - "Blind Range"
		// - "Blind Range Chance"
		// "Blind Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is blinded.
		// - "Blind Chance"
		// - "Blind Hit Mode"
		// Requires "st_blind.smx" to be installed.
		"Blind Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Blind Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Blind Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Blind Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Blind Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Blind Hit Mode"			"0"

			// The intensity of the Super Tank's blind effect.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully blind)
			"Blind Intensity"			"255"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Blind Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Blind Range Chance"			"15.0"
		}
	}
}
```

#### Bomb Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank creates explosions.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, an explosion is created around the survivor. When the Super Tank dies, an explosion is created around the Super Tank.
		// - "Bomb Range"
		// - "Bomb Range Chance"
		// "Bomb Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, an explosion is created around the survivor.
		// - "Bomb Chance"
		// - "Bomb Hit Mode"
		// "Bomb Rock Break" - When the Super Tank's rock breaks, it creates an explosion.
		// - "Bomb Rock Chance"
		// Requires "st_bomb.smx" to be installed.
		"Bomb Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Bomb Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// 3: Display message only when "Bomb Rock Break" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bomb Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bomb Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Bomb Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Bomb Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bomb Range Chance"			"15.0"

			// The Super Tank's rock creates an explosion when it breaks.
			// Note: This does not need "Ability Enabled" or "Bomb Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bomb Rock Break"			"0"

			// The Super Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bomb Rock Chance"			"33.3"
		}
	}
}
```

#### Bury Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank buries survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is buried.
		// - "Bury Range"
		// - "Bury Range Chance"
		// "Bury Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is buried.
		// - "Bury Chance"
		// - "Bury Hit Mode"
		// Requires "st_bury.smx" to be installed.
		"Bury Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Bury Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bury Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Bury Duration"				"5.0"

			// The Super Tank buries survivors this deep into the ground.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Bury Height"				"50.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bury Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Bury Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Bury Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Bury Range Chance"			"15.0"
		}
	}
}
```

#### Car Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank creates car showers.
		// Requires "st_car.smx" to be installed.
		"Car Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Car Chance"				"33.3"

			// The Super Tank create car showers with these cars.
			// --
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chances of being chosen.
			// Character limit: 6
			// --
			// Empty: Pick randomly between 1-3.
			// 1: Small car with a big hatchback.
			// 2: Car that looks like a Chevrolet Impala SS.
			// 3: Car that looks like a Sixth Generation Chevrolet Impala.
			"Car Options"				"123"

			// The radius of the Super Tank's car shower.
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

#### Choke Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank chokes survivors in midair.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is choked in the air.
		// - "Choke Range"
		// - "Choke Range Chance"
		// "Choke Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is choked in the air.
		// - "Choke Chance"
		// - "Choke Hit Mode"
		// Requires "st_choke.smx" to be installed.
		"Choke Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Choke Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Choke Chance"				"33.3"

			// The Super Tank's chokes do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Choke Damage"				"5.0"

			// The Super Tank chokes survivors in the air after this many seconds passes upon triggering the ability.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Choke Delay"				"1.0"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Choke Duration"			"5.0"

			// The Super Tank brings survivors this high up into the air.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Choke Height"				"300.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Choke Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Choke Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Choke Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Choke Range Chance"			"15.0"
		}
	}
}
```

#### Clone Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank creates clones of itself.
		// Requires "st_clone.smx" to be installed.
		"Clone Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// The amount of clones the Super Tank can create.
			// --
			// Minimum: 1
			// Maximum: 25
			"Clone Amount"				"2"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Clone Chance"				"33.3"

			// The Super Tank's clone's health.
			// --
			// Minimum: 1
			// Maximum: 65535
			"Clone Health"				"1000"

			// The Super Tank's clone will be treated as a real Super Tank.
			// Note: Clones cannot clone themselves for obvious safety reasons.
			// --
			// 0: OFF, the clone cannot use abilities like real Super Tanks.
			// 1: ON, the clone can use abilities like real Super Tanks.
			"Clone Mode"				"0"

			// The Super Tank's clones are replaced with new ones when they die.
			// --
			// 0: OFF
			// 1: ON
			"Clone Replace"				"1"
		}
	}
}
```

#### Cloud Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank constantly emits clouds of smoke that damage survivors caught in them.
		// Requires "st_cloud.smx" to be installed.
		"Cloud Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Cloud Chance"				"33.3"

			// The Super Tank's clouds do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Cloud Damage"				"5.0"
		}
	}
}
```

#### Drop Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank drops weapons upon death.
		// Requires "st_drop.smx" to be installed.
		"Drop Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drop Chance"				"33.3"

			// The Super Tank has this many chances out of 100.0% to drop guns with a full clip.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drop Clip Chance"			"33.3"

			// The mode of the Super Tank's drop ability.
			// --
			// 0: Both
			// 1: Guns only.
			// 2: Melee weapons only.
			"Drop Mode"				"0"

			// The Super Tank's weapon size is multiplied by this value.
			// Note: Default weapon size x Drop weapon scale
			// --
			// Minimum: 1.0
			// Maximum: 2.0
			"Drop Weapon Scale"			"1.0"
		}
	}
}
```

#### Drug Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank drugs survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is drugged.
		// - "Drug Range"
		// - "Drug Range Chance"
		// "Drug Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is drugged.
		// - "Drug Chance"
		// - "Drug Hit Mode"
		// Requires "st_drug.smx" to be installed.
		"Drug Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Drug Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drug Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drug Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Drug Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Drug Hit Mode"				"0"

			// The Super Tank drugs survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drug Interval"				"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Drug Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drug Range Chance"			"15.0"
		}
	}
}
```

#### Drunk Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank makes survivors drunk.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor gets drunk.
		// - "Drunk Range"
		// - "Drunk Range Chance"
		// "Drunk Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor gets drunk.
		// - "Drunk Chance"
		// - "Drunk Hit Mode"
		// Requires "st_drunk.smx" to be installed.
		"Drunk Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Drunk Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drunk Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drunk Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Drunk Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Drunk Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Drunk Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Drunk Range Chance"			"15.0"

			// The Super Tank causes the survivors' speed to randomly change every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drunk Speed Interval"			"1.5"

			// The Super Tank causes the survivors to turn at a random direction every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drunk Turn Interval"			"0.5"
		}
	}
}
```

#### Electric Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank electrocutes survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is electrocuted.
		// - "Electric Range"
		// - "Electric Range Chance"
		// "Electric Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is electrocuted.
		// - "Electric Chance"
		// - "Electric Hit Mode"
		// Requires "st_electric.smx" to be installed.
		"Electric Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Electric Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Electric Chance"			"33.3"

			// The Super Tank's electrocutions do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Electric Damage"			"5.0"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Electric Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Electric Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Electric Hit Mode"			"0"

			// The Super Tank electrocutes survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Electric Interval"			"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Electric Range"			"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Electric Range Chance"			"15.0"
		}
	}
}
```

#### Enforce Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank forces survivors to only use a certain weapon slot.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is forced to only use a certain weapon slot.
		// - "Enforce Range"
		// - "Enforce Range Chance"
		// "Enforce Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is forced to only use a certain weapon slot.
		// - "Enforce Chance"
		// - "Enforce Hit Mode"
		// Requires "st_enforce.smx" to be installed.
		"Enforce Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Enforce Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Enforce Chance"			"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Enforce Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Enforce Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Enforce Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Enforce Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Enforce Range Chance"			"15.0"

			// The Super Tank forces survivors to only use one of the following weapon slots.
			// Combine numbers in any order for different results.
			// Character limit: 5
			// --
			// 1: 1st slot only.
			// 2: 2nd slot only.
			// 3: 3rd slot only.
			// 4: 4th slot only.
			// 5: 5th slot only.
			"Enforce Weapon Slots"			"12345"
		}
	}
}
```

#### Fire Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank creates fires.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, a fire is created around the survivor. When the Super Tank dies, a fire is created around the Super Tank.
		// - "Fire Range"
		// - "Fire Range Chance"
		// "Fire Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, a fire is created around the survivor.
		// - "Fire Chance"
		// - "Fire Hit Mode"
		// "Fire Rock Break" - When the Super Tank's rock breaks, it creates a fire.
		// - "Fire Rock Chance"
		// Requires "st_fire.smx" to be installed.
		"Fire Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Fire Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// 3: Display message only when "Fire Rock Break" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fire Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fire Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Fire Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Fire Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fire Range Chance"			"15.0"

			// The Super Tank's rock creates a fire when it breaks.
			// Note: This does not need "Ability Enabled" or "Fire Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fire Rock Break"			"0"

			// The Super Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fire Rock Chance"			"33.3"
		}
	}
}
```

#### Flash Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank runs really fast like the Flash.
		// Requires "st_flash.smx" to be installed.
		"Flash Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Flash Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Flash Duration"			"5.0"

			// The Super Tank's special speed.
			// --
			// Minimum: 3.0
			// Maximum: 10.0
			"Flash Speed"				"5.0"
		}
	}
}
```

#### Fling Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank flings survivors high into the air.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is flung into the air.
		// - "Fling Range"
		// - "Fling Range Chance"
		// "Fling Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is flung into the air.
		// - "Fling Chance"
		// - "Fling Hit Mode"
		// Requires "st_fling.smx" to be installed.
		"Fling Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Fling Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fling Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fling Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Fling Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Fling Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fling Range Chance"			"15.0"
		}
	}
}
```

#### Fragile Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank takes more damage.
		// Requires "st_fragile.smx" to be installed.
		"Fragile Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The bullet damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Bullet damage x Fragile bullet multiplier
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage x 1.0 = Bullet damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Bullet Multiplier"		"5.0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Fragile Chance"			"33.3"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Duration"			"5.0"

			// The explosive damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Explosive damage x Fragile explosive multiplier
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage x 1.0 = Explosive damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Explosive Multiplier"		"5.0"

			// The fire damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Fire damage x Fragile fire multiplier
			// Example: Damage = 30.0 x 3.0 (90.0)
			// Note: Use the value "1.0" to disable this setting. (Fire damage x 1.0 = Fire damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Fire Multiplier"		"3.0"

			// The melee damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Melee damage x Fragile melee multiplier
			// Example: Damage = 100.0 x 1.5 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Melee damage x 1.0 = Melee damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Melee Multiplier"		"1.5"
		}
	}
}
```

#### Ghost Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank cloaks itself and disarms survivors.
		// "Ability Enabled" - When a Super Tank spawns, it becomes invisible.
		// - "Ghost Fade Alpha"
		// - "Ghost Fade Delay"
		// - "Ghost Fade Limit"
		// - "Ghost Fade Rate"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is disarmed.
		// - "Ghost Range"
		// - "Ghost Range Chance"
		// "Ghost Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is disarmed.
		// - "Ghost Chance"
		// - "Ghost Hit Mode"
		// Requires "st_ghost.smx" to be installed.
		"Ghost Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Ghost Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can disarm survivors.
			// 2: ON, the Super Tank can cloak itself.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Ghost Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 3: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ghost Chance"				"33.3"

			// The amount of alpha to take from the Super Tank's alpha every X seconds until the limit set by the "Ghost Fade Limit" is reached.
			// Note: The rate at which the Super Tank's alpha is reduced depends on the "Ghost Fade Rate" setting.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully faded)
			"Ghost Fade Alpha"			"2"

			// The Super Tank's ghost fade effect starts all over after this many seconds passes upon reaching the limit set by the "Ghost Fade Limit" setting.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ghost Fade Delay"			"5.0"

			// The limit of the Super Tank's ghost fade effect.
			// --
			// Minimum: 0 (Fully faded)
			// Maximum: 255 (No effect)
			"Ghost Fade Limit"			"0"

			// The rate of the Super Tank's ghost fade effect.
			// --
			// Minimum: 0.1 (Fastest)
			// Maximum: 9999999999.0 (Slowest)
			"Ghost Fade Rate"			"0.1"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Ghost Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Ghost Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ghost Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ghost Range Chance"			"15.0"

			// The Super Tank disarms the following weapon slots.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 5
			// --
			// 1: 1st slot only.
			// 2: 2nd slot only.
			// 3: 3rd slot only.
			// 4: 4th slot only.
			// 5: 5th slot only.
			"Ghost Weapon Slots"			"12345"
		}
	}
}
```

#### God Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank gains temporary immunity to all types of damage.
		// Requires "st_god.smx" to be installed.
		"God Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"God Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"God Duration"				"5.0"
		}
	}
}
```

#### Gravity Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.
		// "Ability Enabled" - Any nearby infected and survivors are pulled in or pushed away.
		// - "Gravity Force"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor's gravity changes.
		// - "Gravity Range"
		// - "Gravity Range Chance"
		// "Gravity Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor's gravity changes.
		// - "Gravity Chance"
		// - "Gravity Hit Mode"
		// Requires "st_gravity.smx" to be installed.
		"Gravity Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Gravity Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can change survivors' gravity value.
			// 2: ON, the Super Tank can pull in or push away survivors.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Gravity Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 3: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Gravity Chance"			"33.3"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Gravity Duration"			"5.0"

			// The Super Tank's gravity force.
			// --
			// Minimum: -100.0
			// Maximum: 100.0
			// --
			// Positive numbers = Push back
			// Negative numbers = Pull back
			"Gravity Force"				"-50.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Gravity Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Gravity Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Gravity Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Gravity Range Chance"			"15.0"

			// The Super Tank sets the survivors' gravity to this value.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Gravity Value"				"0.3"
		}
	}
}
```

#### Heal Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.
		// "Ability Enabled" - Any nearby infected can give the Super Tank some health.
		// - "Heal Absorb Range"
		// - "Heal Interval"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is set to temporary health and will die when they reach 0 HP.
		// - "Heal Range"
		// - "Heal Range Chance"
		// "Heal Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is set to temporary health and will die when they reach 0 HP.
		// - "Heal Chance"
		// - "Heal Hit Mode"
		// Requires "st_heal.smx" to be installed.
		"Heal Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Heal Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can give survivors temporary health.
			// 2: ON, the Super Tank can absorb health from nearby infected.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Heal Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 3: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The distance between an infected and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Heal Absorb Range"			"500.0"

			// The amount of temporary health given to survivors.
			// --
			// Minimum: 1.0
			// Maximum: 65535.0
			"Heal Buffer"				"25.0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Heal Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Heal Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Heal Hit Mode"				"0"

			// The Super Tank receives health from nearby infected every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Heal Interval"				"5.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Heal Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Heal Range Chance"			"15.0"

			// The Super Tank receives this much health from nearby common infected.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Health from commons
			// Negative numbers: Current health - Health from commons
			"Health From Commons"			"50"

			// The Super Tank receives this much health from other nearby special infected.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Health from specials
			// Negative numbers: Current health - Health from specials
			"Health From Specials"			"100"

			// The Super Tank receives this much health from other nearby Tanks.
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

#### Hurt Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank repeatedly hurts survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor gets hurt repeatedly.
		// - "Hurt Range"
		// - "Hurt Range Chance"
		// "Hurt Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor gets hurt repeatedly.
		// - "Hurt Chance"
		// - "Hurt Hit Mode"
		// Requires "st_hurt.smx" to be installed.
		"Hurt Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Hurt Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Hurt Chance"				"33.3"

			// The Super Tank's pain inflictions do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Hurt Damage"				"5.0"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hurt Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Hurt Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Hurt Hit Mode"				"0"

			// The Super Tank hurts survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hurt Interval"				"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Hurt Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Hurt Range Chance"			"15.0"
		}
	}
}
```

#### Hypno Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank hypnotizes survivors to damage themselves or their teammates.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is hypnotized.
		// - "Hypno Range"
		// - "Hypno Range Chance"
		// "Hypno Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is hypnotized.
		// - "Hypno Chance"
		// - "Hypno Hit Mode"
		// Requires "st_hypno.smx" to be installed.
		"Hypno Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Hypno Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The bullet damage reflected towards survivors by the Super Tank is divided by this value.
			// Note: Damage = Bullet damage/Hypno bullet divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage/1.0 = Bullet damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Bullet Divisor"			"20.0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Hypno Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Duration"			"5.0"

			// The explosive damage reflected towards survivors by the Super Tank is divided by this value.
			// Note: Damage = Explosive damage/Hypno explosive divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage/1.0 = Explosive damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Explosive Divisor"		"20.0"

			// The fire damage reflected towards survivors by the Super Tank is divided by this value.
			// Note: Damage = Fire damage/Hypno fire divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Fire damage/1.0 = Fire damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Fire Divisor"			"200.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Hypno Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Hypno Hit Mode"			"0"

			// The melee damage reflected towards survivors by the Super Tank is divided by this value.
			// Note: Damage = Melee damage/Hypno melee divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Melee damage/1.0 = Melee damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Melee Divisor"			"200.0"

			// The mode of the Super Tank's hypno ability.
			// --
			// 0: Hypnotized survivors hurt themselves.
			// 1: Hypnotized survivors can hurt their teammates.
			"Hypno Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Hypno Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Hypno Range Chance"			"15.0"
		}
	}
}
```

#### Ice Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank freezes survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is frozen in place.
		// - "Ice Range"
		// - "Ice Range Chance"
		// "Ice Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is frozen in place.
		// - "Ice Chance"
		// - "Ice Hit Mode"
		// Requires "st_ice.smx" to be installed.
		"Ice Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Ice Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ice Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ice Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Ice Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Ice Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ice Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Ice Range Chance"			"15.0"
		}
	}
}
```

#### Idle Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank forces survivors to go idle.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor goes idle.
		// - "Idle Range"
		// - "Idle Range Chance"
		// "Idle Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor goes idle.
		// - "Idle Chance"
		// - "Idle Hit Mode"
		// Requires "st_idle.smx" to be installed.
		"Idle Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Idle Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Idle Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Idle Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Idle Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Idle Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Idle Range Chance"			"15.0"
		}
	}
}
```

#### Invert Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank inverts the survivors' movement keys.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor's movement keys are inverted.
		// - "Invert Range"
		// - "Invert Range Chance"
		// "Invert Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor's movement keys are inverted.
		// - "Invert Chance"
		// - "Invert Hit Mode"
		// Requires "st_invert.smx" to be installed.
		"Invert Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Invert Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Invert Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Invert Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Invert Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Invert Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Invert Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Invert Range Chance"			"15.0"
		}
	}
}
```

#### Item Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank gives survivors items upon death.
		// Requires "st_item.smx" to be installed.
		"Item Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Item Chance"				"33.3"

			// The Super Tank gives survivors this loadout.
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "rifle_m60,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "first_aid_kit,defibrillator,knife,adrenaline"
			"Item Loadout"				"rifle,pistol,first_aid_kit,pain_pills"

			// The mode of the Super Tank's item ability.
			// --
			// 0: Survivors get a random item.
			// 1: Survivors get all items.
			"Item Mode"				"0"
		}
	}
}
```

#### Jump Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank jumps periodically or sporadically and makes survivors jump uncontrollably.
		// "Ability Enabled" - The Super Tank jumps periodically or sporadically.
		// - "Jump Interval"
		// - "Jump Mode"
		// - "Jump Sporadic Chance"
		// - "Jump Sporadic Height"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor jumps uncontrollably.
		// - "Jump Range"
		// - "Jump Range Chance"
		// "Jump Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor jumps uncontrollably.
		// - "Jump Chance"
		// - "Jump Hit Mode"
		// Requires "st_jump.smx" to be installed.
		"Jump Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Jump Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can force survivors to jump uncontrollably.
			// 2: ON, the Super Tank can jump periodically.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Jump Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 3: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Jump Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Duration"				"5.0"

			// The Super Tank and survivors jump this high off a surface.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Height"				"300.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Jump Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Jump Hit Mode"				"0"

			// The Super Tank jumps every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Interval"				"1.0"

			// The mode of the Super Tank's jumping ability.
			// --
			// 0: The Super Tank jumps periodically.
			// 1: The Super Tank jumps sporadically.
			"Jump Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Jump Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Jump Range Chance"			"15.0"

			// The Super Tank has this many chances out of 100.0% to jump sporadically.
			// Note: This setting only applies if the "Jump Mode" setting is set to 1.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Jump Sporadic Chance"			"33.3"

			// The Super Tank jumps this high up into the air.
			// Note: This setting only applies if the "Jump Mode" setting is set to 1.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Sporadic Height"			"750.0"
		}
	}
}
```

#### Kamikaze Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank kills itself along with a survivor victim.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor dies along with the Super Tank.
		// - "Kamikaze Range"
		// - "Kamikaze Range Chance"
		// "Kamikaze Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor dies along with the Super Tank.
		// - "Kamikaze Chance"
		// - "Kamikaze Hit Mode"
		// Requires "st_kamikaze.smx" to be installed.
		"Kamikaze Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Kamikaze Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Kamikaze Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Kamikaze Chance"			"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Kamikaze Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Kamikaze Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Kamikaze Range"			"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Kamikaze Range Chance"			"15.0"
		}
	}
}
```

#### Lag Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank makes survivors lag.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor lags.
		// - "Lag Range"
		// - "Lag Range Chance"
		// "Lag Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor lags.
		// - "Lag Chance"
		// - "Lag Hit Mode"
		// Requires "st_lag.smx" to be installed.
		"Lag Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Lag Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Lag Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Lag Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Lag Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Lag Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Lag Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Lag Range Chance"			"15.0"
		}
	}
}
```

#### Leech Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank leeches health off of survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the Super Tank leeches health off of the survivor.
		// - "Leech Range"
		// - "Leech Range Chance"
		// "Leech Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the Super Tank leeches health off of the survivor.
		// - "Leech Chance"
		// - "Leech Hit Mode"
		// Requires "st_leech.smx" to be installed.
		"Leech Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Leech Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Leech Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Leech Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Leech Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Leech Hit Mode"			"0"

			// The Super Tank leeches health off of survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Leech Interval"			"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Leech Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Leech Range Chance"			"15.0"
		}
	}
}
```

#### Medic Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank heals special infected upon death.
		// Requires "st_medic.smx" to be installed.
		"Medic Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
			// Note: This setting does not apply to the upon-death ability.
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
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Ability Enabled" is set to 1 or 3.
			// 2: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Medic Chance"				"33.3"

			// The Super Tank gives special infected this much health each time.
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
			"Medic Health"				"25,25,25,25,25,25"

			// The Super Tank heals nearby special infected every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Medic Interval"			"5.0"

			// The special infected's max health.
			// The Super Tank will not heal special infected if they already have this much health.
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
			"Medic Max Health"			"250,50,250,100,325,600"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Medic Range"				"500.0"
		}
	}
}
```

#### Meteor Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank creates meteor showers.
		// Requires "st_meteor.smx" to be installed.
		"Meteor Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Meteor Chance"				"33.3"

			// The Super Tank's meteorites do this much damage.
			// Note: This setting only applies if the "Meteor Mode" setting is set to 1.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Meteor Damage"				"5.0"

			// The mode of the Super Tank's meteor shower ability.
			// --
			// 0: The Super Tank's meteorites will explode and start fires.
			// 1: The Super Tank's meteorites will explode and damage and push back nearby survivors.
			"Meteor Mode"				"0"

			// The radius of the Super Tank's meteor shower.
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

#### Minion Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank spawns minions.
		// Requires "st_minion.smx" to be installed.
		"Minion Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// The amount of minions the Super Tank can spawn.
			// --
			// Minimum: 1
			// Maximum: 25
			"Minion Amount"				"5"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Minion Chance"				"33.3"

			// The Super Tank's minions are replaced with new ones when they die.
			// --
			// 0: OFF
			// 1: ON
			"Minion Replace"			"1"

			// The Super Tank spawns these minions.
			// --
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chances of being chosen.
			// Character limit: 12
			// --
			// 1: Smoker
			// 2: Boomer
			// 3: Hunter
			// 4: Spitter (Switches to Boomer in L4D1.)
			// 5: Jockey (Switches to Hunter in L4D1.)
			// 6: Charger (Switches to Smoker in L4D1.)
			"Minion Types"				"123456"
		}
	}
}
```

#### Necro Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank resurrects nearby special infected that die.
		// Requires "st_necro.smx" to be installed.
		"Necro Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Necro Chance"				"33.3"

			// The distance between a special infected and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Necro Range"				"500.0"
		}
	}
}
```

#### Nullify Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank nullifies all of the survivors' damage.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor does not do any damage to the Super Tank.
		// - "Nullify Range"
		// - "Nullify Range Chance"
		// "Nullify Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor does not do any damage to the Super Tank.
		// - "Nullify Chance"
		// - "Nullify Hit Mode"
		// Requires "st_nullify.smx" to be installed.
		"Nullify Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Nullify Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Nullify Chance"			"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Nullify Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Nullify Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Nullify Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Nullify Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Nullify Range Chance"			"15.0"
		}
	}
}
```

#### Panic Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank starts panic events.
		// Requires "st_panic.smx" to be installed.
		"Panic Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Panic Chance"				"33.3"

			// The Super Tank starts a panic event every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Panic Interval"			"5.0"
		}
	}
}
```

#### Pimp Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank pimp slaps survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is repeatedly pimp slapped.
		// - "Pimp Range"
		// - "Pimp Range Chance"
		// "Pimp Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is repeatedly pimp slapped.
		// - "Pimp Chance"
		// - "Pimp Hit Mode"
		// Requires "st_pimp.smx" to be installed.
		"Pimp Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Pimp Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Pimp Chance"				"33.3"

			// The Super Tank's pimp slaps do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Pimp Damage"				"5"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Pimp Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Pimp Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Pimp Hit Mode"				"0"

			// The Super Tank pimp slaps survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Pimp Interval"				"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Pimp Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Pimp Range Chance"			"15.0"
		}
	}
}
```

#### Puke Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank pukes on survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the Super Tank pukes on the survivor.
		// - "Puke Range"
		// - "Puke Range Chance"
		// "Puke Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the Super Tank pukes on the survivor.
		// - "Puke Chance"
		// - "Puke Hit Mode"
		// Requires "st_puke.smx" to be installed.
		"Puke Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Puke Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Puke Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Puke Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Puke Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Puke Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Puke Range Chance"			"15.0"
		}
	}
}
```

#### Pyro Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank ignites itself and gains a speed boost when on fire.
		// Requires "st_pyro.smx" to be installed.
		"Pyro Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank's speed boost value when on fire.
			// --
			// Minimum: 0.1
			// Maximum: 3.0
			"Pyro Boost"				"1.0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Pyro Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Pyro Duration"				"5.0"

			// The mode of the Super Tank's speed boost.
			// --
			// 0: Super Tank's speed = Run speed + Pyro boost
			// 1: Super Tank's speed = Pyro boost
			"Pyro Mode"				"0"
		}
	}
}
```

#### Quiet Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank silences itself around survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor cannot hear the Super Tank's sounds.
		// - "Quiet Range"
		// - "Quiet Range Chance"
		// "Quiet Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor cannot hear the Super Tank's sounds.
		// - "Quiet Chance"
		// - "Quiet Hit Mode"
		// Requires "st_quiet.smx" to be installed.
		"Quiet Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Quiet Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Quiet Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Quiet Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Quiet Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Quiet Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Quiet Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Quiet Range Chance"			"15.0"
		}
	}
}
```

#### Recoil Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank gives survivors strong gun recoil.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor experiences strong recoil.
		// - "Recoil Range"
		// - "Recoil Range Chance"
		// "Recoil Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor experiences strong recoil.
		// - "Recoil Chance"
		// - "Recoil Hit Mode"
		// Requires "st_recoil.smx" to be installed.
		"Recoil Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Recoil Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Recoil Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Recoil Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Recoil Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Recoil Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Recoil Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Recoil Range Chance"			"15.0"
		}
	}
}
```

#### Regen Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank regenerates health.
		// Requires "st_regen.smx" to be installed.
		"Regen Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Regen Chance"				"33.3"

			// The Super Tank regenerates this much health each time.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Regen health
			// Negative numbers: Current health - Regen health
			"Regen Health"				"1"

			// The Super Tank regenerates health every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Regen Interval"			"1.0"

			// The Super Tank stops regenerating health at this value.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: The Super Tank will stop regenerating health when it reaches this number.
			// Negative numbers: The Super Tank will stop losing health when it reaches this number.
			"Regen Limit"				"65535"
		}
	}
}
```

#### Respawn Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank respawns upon death.
		// Requires "st_respawn.smx" to be installed.
		"Respawn Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
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

			// The Super Tank respawns up to this many times.
			// Note: This setting only applies if the "Respawn Random" setting is set to 0.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Respawn Amount"			"1"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Respawn Chance"			"33.3"

			// The mode of the Super Tank's respawns.
			// --
			// 0: The Super Tank respawns as the same type.
			// 1: The Super Tank respawns as the type used in the "Respawn Type" setting.
			// 2: The Super Tank respawns as a random type.
			"Respawn Mode"				"0"

			// The type that the Super Tank will respawn as.
			// --
			// 0: OFF, use the randomization feature.
			// 1-500: ON, the type to respawn as.
			"Respawn Type"				"0"
		}
	}
}
```

#### Restart Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor respawns at the start of the map or near a teammate.
		// - "Restart Range"
		// - "Restart Range Chance"
		// "Restart Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor respawns at the start of the map or near a teammate.
		// - "Restart Chance"
		// - "Restart Hit Mode"
		// Requires "st_restart.smx" to be installed.
		"Restart Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Restart Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Restart Chance"			"33.3"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Restart Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Restart Hit Mode"			"0"

			// The Super Tank makes survivors restart with this loadout.
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "smg_silenced,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "first_aid_kit,defibrillator,knife,adrenaline"
			"Restart Loadout"			"smg,pistol,pain_pills"

			// The mode of the Super Tank's restart ability.
			// --
			// 0: Survivors are teleported to the spawn area.
			// 1: Survivors are teleported to another teammate.
			"Restart Mode"				"1"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Restart Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Restart Range Chance"			"15.0"
		}
	}
}
```

#### Rock Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank creates rock showers.
		// Requires "st_rock.smx" to be installed.
		"Rock Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Rock Chance"				"33.3"

			// The Super Tank's rocks do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Rock Damage"				"5"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Rock Duration"				"5.0"

			// The radius of the Super Tank's rock shower.
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

#### Rocket Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank sends survivors into space.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is sent into space.
		// - "Rocket Range"
		// - "Rocket Range Chance"
		// "Rocket Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is sent into space.
		// - "Rocket Chance"
		// - "Rocket Hit Mode"
		// Requires "st_rocket.smx" to be installed.
		"Rocket Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Rocket Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Rocket Chance"				"33.3"

			// The Super Tank sends survivors into space after this many seconds passes upon triggering the ability.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Rocket Delay"				"1.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Rocket Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Rocket Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Rocket Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Rocket Range Chance"			"15.0"
		}
	}
}
```

#### Shake Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank shakes the survivors' screens.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor's screen is shaken.
		// - "Shake Range"
		// - "Shake Range Chance"
		// "Shake Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor's screen is shaken.
		// - "Shake Chance"
		// - "Shake Hit Mode"
		// Requires "st_shake.smx" to be installed.
		"Shake Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Shake Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shake Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shake Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Shake Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Shake Hit Mode"			"0"

			// The Super Tank shakes survivors' screems every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shake Interval"			"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Shake Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shake Range Chance"			"15.0"
		}
	}
}
```

#### Shield Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank protects itself with a shield and throws propane tanks or gas cans.
		// Requires "st_shield.smx" to be installed.
		"Shield Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shield Chance"				"33.3"

			// These are the RGBA values of the Super Tank's shield prop's color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Shield Color"				"255 255 255 50"

			// The Super Tank's shield reactivates after this many seconds passes upon destroying the shield.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shield Delay"				"5.0"

			// The type of the Super Tank's shield'.
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

#### Shove Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank repeatedly shoves survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is shoved repeatedly.
		// - "Shove Range"
		// - "Shove Range Chance"
		// "Shove Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is shoved repeatedly.
		// - "Shove Chance"
		// - "Shove Hit Mode"
		// Requires "st_shove.smx" to be installed.
		"Shove Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Shove Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shove Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shove Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Shove Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Shove Hit Mode"			"0"

			// The Super Tank shoves survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shove Interval"			"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Shove Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Shove Range Chance"			"15.0"
		}
	}
}
```

#### Smash Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank smashes survivors to death.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is smashed to death.
		// - "Smash Range"
		// - "Smash Range Chance"
		// "Smash Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is smashed to death.
		// - "Smash Chance"
		// - "Smash Hit Mode"
		// Requires "st_smash.smx" to be installed.
		"Smash Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Smash Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Smash Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Smash Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Smash Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Smash Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Smash Range Chance"			"15.0"
		}
	}
}
```

#### Smite Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank smites survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is smitten.
		// - "Smite Range"
		// - "Smite Range Chance"
		// "Smite Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is smitten.
		// - "Smite Chance"
		// - "Smite Hit Mode"
		// Requires "st_smite.smx" to be installed.
		"Smite Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Smite Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Smite Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Smite Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Smite Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Smite Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Smite Range Chance"			"15.0"
		}
	}
}
```

#### Spam Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank spams rocks at survivors.
		// Requires "st_spam.smx" to be installed.
		"Spam Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Spam Chance"				"33.3"

			// The Super Tank's rocks do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Spam Damage"				"5"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Spam Duration"				"5.0"
		}
	}
}
```

#### Splash Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank constantly deals splash damage to nearby survivors.
		// Requires "st_splash.smx" to be installed.
		"Splash Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Splash Chance"				"33.3"

			// The Super Tank's splashes do this much damage.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Splash Damage"				"5.0"

			// The Super Tank deals splash damage to nearby survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Splash Interval"			"5.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Splash Range"				"500.0"
		}
	}
}
```

#### Stun Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank stuns and slows survivors down.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is slowed down.
		// - "Stun Range"
		// - "Stun Range Chance"
		// "Stun Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is slowed down.
		// - "Stun Chance"
		// - "Stun Hit Mode"
		// Requires "st_stun.smx" to be installed.
		"Stun Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// Note: This setting does not affect the "Stun Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Stun Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Stun Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Stun Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Stun Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Stun Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Stun Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Stun Range Chance"			"15.0"

			// The Super Tank sets the survivors' run speed to this value.
			// --
			// Minimum: 0.1
			// Maximum: 0.99
			"Stun Speed"				"0.25"
		}
	}
}
```

#### Throw Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank throws cars, special infected, Witches, or itself.
		// Requires "st_throw.smx" to be installed.
		"Throw Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// Enable this ability.
			// --
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chances of being chosen.
			// Character limit: 8
			// --
			// Empty: Pick randomly between 1-4.
			// 1: The Super Tank throws cars.
			// 2: The Super Tank throws special infected.
			// 3: The Super Tank throws itself.
			// 4: The Super Tank throws Witches.
			"Ability Enabled"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 4
			// --
			// Empty: OFF
			// 1: Display message only when "Ability Enabled" is set to 1.
			// 2: Display message only when "Ability Enabled" is set to 2.
			// 3: Display message only when "Ability Enabled" is set to 3.
			// 4: Display message only when "Ability Enabled" is set to 4.
			"Ability Message"			"0"

			// The Super Tank throws these cars.
			// --
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chances of being chosen.
			// Character limit: 6
			// --
			// Empty: Pick randomly between 1-3.
			// 1: Small car with a big hatchback.
			// 2: Car that looks like a Chevrolet Impala SS.
			// 3: Car that looks like a Sixth Generation Chevrolet Impala.
			"Throw Car Options"			"123"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Throw Chance"				"33.3"

			// The Super Tank throws these special infected.
			// --
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chances of being chosen.
			// Character limit: 14
			// --
			// 1: Smoker
			// 2: Boomer
			// 3: Hunter
			// 4: Spitter (Switches to Boomer in L4D1.)
			// 5: Jockey (Switches to Hunter in L4D1.)
			// 6: Charger (Switches to Smoker in L4D1.)
			// 7: Tank
			"Throw Infected Options"		"1234567"
		}
	}
}
```

#### Track Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank throws heat-seeking rocks that will track down the nearest survivors.
		// Requires "st_track.smx" to be installed.
		"Track Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Track Chance"				"33.3"

			// The mode of the Super Tank's track ability.
			// --
			// 0: The Super Tank's rock will only start tracking when it is near a survivor.
			// 1: The Super Tank's rock will track the nearest survivor.
			"Track Mode"				"1"

			// The Super Tank's track ability is this fast.
			// Note: This setting only applies if the "Track Mode" setting is set to 1.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Track Speed"				"500.0"
		}
	}
}
```

#### Vampire Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank gains health from hurting survivors.
		// Requires "st_vampire.smx" to be installed.
		"Vampire Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
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

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Vampire Chance"			"33.3"
		}
	}
}
```

#### Vision Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank changes the survivors' field of view.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor's vision changes.
		// - "Vision Range"
		// - "Vision Range Chance"
		// "Vision Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor's vision changes.
		// - "Vision Chance"
		// - "Vision Hit Mode"
		// Requires "st_vision.smx" to be installed.
		"Vision Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Vision Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Vision Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Vision Duration"			"5.0"

			// The Super Tank sets survivors' fields of view to this value.
			// --
			// Minimum: 1
			// Maximum: 160
			"Vision FOV"				"160"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Vision Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Vision Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Vision Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Vision Range Chance"			"15.0"
		}
	}
}
```

#### Warp Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank warps to survivors and warps survivors to random teammates.
		// "Ability Enabled" - The Tank warps to a random survivor.
		// - "Warp Interval"
		// - "Warp Mode"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is warped to a random teammate.
		// - "Warp Range"
		// - "Warp Range Chance"
		// "Warp Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor is warped to a random teammate.
		// - "Warp Chance"
		// - "Warp Hit Mode"
		// Requires "st_warp.smx" to be installed.
		"Warp Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// Enable this ability.
			// Note: This setting does not affect the "Warp Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can warp a survivor to a random teammate.
			// 2: ON, the Super Tank can warp itself to a survivor.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Display message only when "Warp Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to 1 or 3.
			// 3: Display message only when "Ability Enabled" is set to 2 or 3.
			"Ability Message"			"0"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Warp Chance"				"33.3"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Warp Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Warp Hit Mode"				"0"

			// The Super Tank warps to a random survivor every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Warp Interval"				"5.0"

			// The mode of the Super Tank's warp ability.
			// --
			// 0: The Super Tank warps to a random survivor.
			// 1: The Super Tank switches places with a random survivor.
			"Warp Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Warp Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Warp Range Chance"			"15.0"
		}
	}
}
```

#### Whirl Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank makes survivors' screens whirl.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor's screen whirls.
		// - "Whirl Range"
		// - "Whirl Range Chance"
		// "Whirl Hit" - When a survivor is hit by the Super Tank's claw or rock, or a survivor hits the Super Tank with a melee weapon, the survivor's screen whirls.
		// - "Whirl Chance"
		// - "Whirl Hit Mode"
		// Requires "st_whirl.smx" to be installed.
		"Whirl Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// Show a screen fade effect when the Super Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 3
			// --
			// Empty: OFF
			// 1: Show effect when the Super Tank uses its claw/rock attack.
			// 2: Show effect when the Super Tank is hit by a melee weapon.
			// 3: Show effect when the Super Tank uses its range ability.
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// Combine numbers in any order for different results.
			// Character limit: 2
			// --
			// Empty: OFF
			// 1: Display message only when "Whirl Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			"Ability Message"			"0"

			// The axis of the Super Tank's whirl effect.
			// --
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chances of being chosen.
			// Character limit: 6
			// --
			// Empty: Pick randomly between 1-3.
			// 1: X-Axis
			// 2: Y-Axis
			// 3: Z-Axis
			"Whirl Axis"				"123"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Whirl Chance"				"33.3"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Whirl Duration"			"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Whirl Hit"				"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Whirl Hit Mode"			"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Whirl Range"				"150.0"

			// The Super Tank has this many chances out of 100.0% to trigger the range ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Whirl Range Chance"			"15.0"

			// The Super Tank makes survivors whirl at this speed.
			// --
			// Minimum: 1.0
			// Maximum: 9999999999.0
			"Whirl Speed"				"500.0"
		}
	}
}
```

#### Witch Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank converts nearby common infected into Witch minions.
		// Requires "st_witch.smx" to be installed.
		"Witch Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
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

			// The Super Tank converts this many common infected into Witch minions at once.
			// --
			// Minimum: 1
			// Maximum: 25
			"Witch Amount"				"3"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Witch Chance"				"33.3"

			// The Super Tank's Witch minion causes this much damage per hit.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Witch Damage"				"5"

			// The distance between a common infected and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Witch Range"				"500.0"
		}
	}
}
```

#### Zombie Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank spawns zombies.
		// Requires "st_zombie.smx" to be installed.
		"Zombie Ability"
		{
			// Allow human-controlled Super Tanks to use this ability.
			// --
			// 0: OFF
			// 1: ON
			"Human Ability"				"0"

			// Determines how many times human-controlled Super Tanks can use their abilities in one life.
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Human Ammo"				"5"

			// Human-controlled Super Tanks must wait this long before using their abilities again.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Human Cooldown"			"30.0"

			// The Super Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Super Tanks unless the "Human Mode" setting is set to 0.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Human Duration"			"5.0"

			// The mode of how human-controlled Super Tanks activate their abilities.
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

			// The Super Tank spawns this many common infected at once.
			// --
			// Minimum: 1
			// Maximum: 100
			"Zombie Amount"				"10"

			// The Super Tank has this many chances out of 100.0% to trigger the ability.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			"Zombie Chance"				"33.3"

			// The Super Tank spawns a zombie mob every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Zombie Interval"			"5.0"
		}
	}
}
```