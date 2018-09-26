# Information
> There is information about each setting and ability below. All of these settings use default values if they are left incomplete or empty.

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
			"Plugin Enabled"				"1"

			// Announce each Super Tank's arrival.
			// --
			// 0: OFF
			// 1: ON
			"Announce Arrival"				"1"

			// Announce each Super Tank's death.
			// --
			// 0: OFF
			// 1: ON
			"Announce Death"				"1"

			// Display Tanks' names and health.
			// --
			// 0: OFF
			// 1: ON, show names only.
			// 2: ON, show health only.
			// 3: ON, show both names and health.
			"Display Health"				"3"

			// Enable Super Tanks++ in finales only.
			// --
			// 0: OFF
			// 1: ON
			"Finales Only"					"0"

			// Multiply the Super Tank's health.
			// Note: Health changes only occur when there are at least 2 alive non-idle human survivors.
			// --
			// 0: No changes to health.
			// 1: Multiply original health only.
			// 2: Multiply extra health only.
			// 3: Multiply both.
			"Multiply Health"				"0"

			// The range of types to check for.
			// Separate values with "-".
			// Value limit: 2
			// Character limit for each value: 4
			// --
			// Minimum number for each value: 1
			// Maximum number for each value: 5000
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			"Type Range"					"1-5000"
		}
		"Waves"
		{
			// Spawn this many Tanks on non-finale maps periodically.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Regular Amount"				"2"

			// Spawn Tanks on non-finale maps every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Regular Interval"				"300.0"

			// Spawn Tanks on non-finale maps periodically.
			// --
			// 0: OFF
			// 1: ON
			"Regular Wave"					"0"

			// Amount of Tanks to spawn for each finale wave.
			// Separate waves with commas.
			// Wave limit: 3
			// Character limit for each wave: 3
			// --
			// Minimum value for each wave: 1
			// Maximum value for each wave: 9999999999
			// --
			// 1st number = 1st wave
			// 2nd number = 2nd wave
			// 3rd number = 3rd wave
			"Finale Waves"					"2,3,4"
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
			"Game Mode Types"				"5"

			// Enable Super Tanks++ in these game modes.
			// Separate game modes with commas.
			// Character limit: 512 (including commas)
			// --
			// Empty: All
			// Not empty: Enabled only in these game modes.
			"Enabled Game Modes"			"coop,survival"

			// Disable Super Tanks++ in these game modes.
			// Separate game modes with commas.
			// Character limit: 512 (including commas)
			// --
			// Empty: None
			// Not empty: Disabled only in these game modes.
			"Disabled Game Modes"			"versus,scavenge"
		}
		"Custom"
		{
			// Enable Super Tanks++ custom configuration.
			// --
			// 0: OFF
			// 1: ON
			"Enable Custom Configs"			"0"

			// The type of custom config that Super Tanks++ creates.
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
			// Character limit: 128
			// --
			// Empty: "Tank"
			// Not Empty: Tank's custom name
			"Tank Name"						"Tank #1"

			// Enable the Super Tank.
			// --
			// 0: OFF
			// 1: ON
			"Tank Enabled"					"0"

			// Display a note for the Super Tank when it spawns.
			// Note: This note can also be displayed for clones if "Clone Mode" is set to 1, so the chat could be spammed if multiple clones spawn.
			// --
			// 0: OFF
			// 1: ON
			"Tank Note"						"0"

			// These are the Super Tank's skin and glow outline colors.
			// --
			// Character limit: 28
			// Character limit for each color: 3
			// --
			// Separate colors with "|".
			// Separate RGBAs with commas.
			// --
			// Minimum value for each color: 0
			// Maximum value for each color: 255
			// --
			// 1st set = skin color (RGBA)
			// 2nd set = glow color (RGB)
			"Skin-Glow Colors"				"255,255,255,255|255,255,255"

			// The Super Tank will have a glow outline.
			// Only available in Left 4 Dead 2.
			// --
			// 0: OFF
			// 1: ON
			"Glow Outline"					"1"
		}
		"Spawn"
		{
			// The number of Super Tanks with this type that can be alive at any given time.
			// Note: Clones, respawned Super Tanks, and Super Tanks spawned through the Super Tanks++ menu are not affected. 
			// --
			// Minimum: 0
			// Maximum: 9999999999
			"Type Limit"					"32"

			// The Super Tank will only spawn on finale maps.
			// --
			// 0: OFF
			// 1: ON
			"Finale Tank"					"0"

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
			"Boss Stages"					"3"

			// The Super Tank types that the boss will evolve into.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 1.
			// Note: Make sure that the Super Tank types that the boss will evolve into are enabled.
			// Example: When Stage 1 boss evolves into Stage 2, it will evolve into Tank #2.
			// --
			// Character limit: 20
			// Character limit for each stage type: 4
			// --
			// Minimum: 1
			// Maximum: 5000
			// --
			// 1st number = 2nd stage type
			// 2nd number = 3rd stage type
			// 3rd number = 4th stage type
			// 4th number = 5th stage type
			"Boss Types"					"2,3,4,5"

			// The interval between each random switch.
			// Note: This setting only takes affect when the "Spawn Mode" setting is set to 2.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Random Interval"				"5.0"

			// The mode of the Super Tanks' spawn status.
			// --
			// 0: Spawn as normal Super Tanks.
			// 1: Spawn as Super Tank bosses.
			// 2: Spawn as Super Tanks that switch randomly between each type.
			"Spawn Mode"					"0"
		}
		"Props"
		{
			// Props that the Super Tank can spawn with.
			// Combine numbers in any order for different results.
			// Character limit: 6
			// --
			// 1: Attach a blur effect only.
			// 2: Attach lights only.
			// 3: Attach oxygen tanks only.
			// 4: Attach flames to oxygen tanks.
			// 5: Attach rocks only.
			// 6: Attach tires only.
			"Props Attached"				"23456"

			// Each prop has 1 of this many chances to appear when the Super Tank appears.
			// Separate chances with commas.
			// Chances limit: 6
			// Character limit for each chance: 3
			// --
			// Minimum value for each chance: 1
			// Maximum value for each chance: 9999999999
			// --
			// 1st number = Chance for a blur effect to appear.
			// 2nd number = Chance for lights to appear.
			// 3rd number = Chance for oxygen tanks to appear.
			// 4th number = Chance for oxygen tank flames to appear.
			// 5th number = Chance for rocks to appear.
			// 6th number = Chance for tires to appear.
			"Props Chance"					"3,3,3,3,3,3"

			// The Super Tank's prop colors.
			// Separate colors with "|".
			// Separate RGBAs with commas.
			// --
			// Minimum value for each color: 0
			// Maximum value for each color: 255
			// --
			// 1st set = lights color (RGBA)
			// 2nd set = oxygen tanks color (RGBA)
			// 3rd set = oxygen tank flames color (RGBA)
			// 4th set = rocks color (RGBA)
			// 5th set = tires color (RGBA)
			"Props Colors"					"255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255"
		}
		"Particles"
		{
			// The Super Tank's body will have a particle effect.
			// --
			// 0: OFF
			// 1: ON
			"Body Particle"					"0"

			// The particle effects for the Super Tank's body.
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
			"Body Effects"					"1234567"

			// The Super Tank's rock will have a particle effect.
			// --
			// 0: OFF
			// 1: ON
			"Rock Particle"					"0"

			// The particle effects for the Super Tank's rock.
			// Combine numbers in any order for different results.
			// Character limit: 4
			// --
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 3: Fire Trail
			// 4: Acid Trail (Only available in Left 4 Dead 2.)
			"Rock Effects"					"1234"
		}
		"Enhancements"
		{
			// The Super Tank's claw attacks do this much damage.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Claw Damage"					"5.0"

			// Extra health given to the Super Tank.
			// Note: Tank's health limit on any difficulty is 65,535.
			// Note: Depending on the setting for "Multiply Health," the Super Tank's health will be multiplied based on player count.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Extra health
			// Negative numbers: Current health - Extra health
			"Extra Health"					"0"

			// The Super Tank's rock throws do this much damage.
			// --
			// Minimum: 0.0
			// Maximum: 9999999999.0
			"Rock Damage"					"5.0"

			// Set the Super Tank's run speed.
			// Note: Default run speed is 1.0.
			// --
			// Minimum: 0.1
			// Maximum: 3.0
			"Run Speed"						"1.0"

			// The Super Tank throws a rock every time this many seconds passes.
			// Note: Default throw interval is 5.0 seconds.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Throw Interval"				"5.0"
		}
		"Immunities"
		{
			// Give the Super Tank bullet immunity.
			// --
			// 0: OFF
			// 1: ON
			"Bullet Immunity"				"0"

			// Give the Super Tank explosive immunity.
			// --
			// 0: OFF
			// 1: ON
			"Explosive Immunity"			"0"

			// Give the Super Tank fire immunity.
			// --
			// 0: OFF
			// 1: ON
			"Fire Immunity"					"0"

			// Give the Super Tank melee immunity.
			// --
			// 0: OFF
			// 1: ON
			"Melee Immunity"				"0"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The bullet damage received by the Super Tank is divided by this value.
			// Note: Damage = Bullet damage/Absorb bullet damage
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage/1.0 = Bullet damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Bullet Damage"			"20.0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Absorb Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Duration"				"5.0"

			// The explosive damage received by the Super Tank is divided by this value.
			// Note: Damage = Explosive damage/Absorb explosive damage
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage/1.0 = Explosive damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Explosive Damage"		"20.0"

			// The fire damage received by the Super Tank is divided by this value.
			// Note: Damage = Fire damage/Absorb fire damage
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Fire damage/1.0 = Fire damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Fire Damage"			"200.0"

			// The melee damage received by the Super Tank is divided by this value.
			// Note: Damage = Melee damage/Absorb melee damage
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Melee damage/1.0 = Melee damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Absorb Melee Damage"			"200.0"
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
		// "Acid Hit" - When a survivor is hit by the Super Tank's claw or rock, an acid puddle is created underneath the survivor.
		// - "Acid Chance"
		// - "Acid Hit Mode"
		// Requires "st_acid.smx" to be installed.
		"Acid Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Acid Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Acid Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message only when "Acid Rock Break" is on.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Acid Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Acid Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Acid Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Acid Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Acid Range Chance"				"16"

			// The Super Tank's rock creates an acid puddle when it breaks.
			// Note: Only available in Left 4 Dead 2.
			// Note: This does not need "Ability Enabled" or "Acid Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Acid Rock Break"				"0"
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
		// "Ammo Hit" - When a survivor is hit by the Super Tank's claw or rock, their ammunition is taken away.
		// - "Ammo Chance"
		// - "Ammo Hit Mode"
		// Requires "st_ammo.smx" to be installed.
		"Ammo Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Ammo Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Ammo Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Ammo Chance"					"4"

			// The Super Tank sets survivors' ammunition to this amount.
			// --
			// Minimum: 0
			// Maximum: 25
			"Ammo Count"					"0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Ammo Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Ammo Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ammo Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Ammo Range Chance"				"16"
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
		// "Blind Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is blinded.
		// - "Blind Chance"
		// - "Blind Hit Mode"
		// Requires "st_blind.smx" to be installed.
		"Blind Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Blind Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Blind Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Blind Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Blind Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Blind Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Blind Hit Mode"				"0"

			// The intensity of the Super Tank's blind effect.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully blind)
			"Blind Intensity"				"255"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Blind Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Blind Range Chance"			"16"
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
		// "Ability Enabled" - When a survivor is within range of the Super Tank, an explosion is created around the survivor.  When the Super Tank dies, an explosion is created around the Super Tank.
		// - "Bomb Range"
		// - "Bomb Range Chance"
		// "Bomb Hit" - When a survivor is hit by the Super Tank's claw or rock, an explosion is created around the survivor.
		// - "Bomb Chance"
		// - "Bomb Hit Mode"
		// Requires "st_bomb.smx" to be installed.
		"Bomb Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Bomb Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Bomb Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message only when "Bomb Rock Break" is on.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Bomb Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bomb Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Bomb Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Bomb Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Bomb Range Chance"				"16"

			// The Super Tank's rock creates an explosion when it breaks.
			// Note: This does not need "Ability Enabled" or "Bomb Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bomb Rock Break"				"0"
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
		// "Bury Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is buried.
		// - "Bury Chance"
		// - "Bury Hit Mode"
		// Requires "st_bury.smx" to be installed.
		"Bury Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Bury Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Bury Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Bury Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Bury Duration"					"5.0"

			// The Super Tank buries survivors this deep into the ground.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Bury Height"					"50.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Bury Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Bury Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Bury Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Bury Range Chance"				"16"
		}
	}
}
```

#### Cancer Ability

```
"Super Tanks++"
{
	"Tank #1"
	{
		// The Super Tank gives survivors cancer.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is given cancer.
		// - "Cancer Range"
		// - "Cancer Range Chance"
		// "Cancer Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is given cancer.
		// - "Cancer Chance"
		// - "Cancer Hit Mode"
		// Requires "st_cancer.smx" to be installed.
		"Cancer Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Cancer Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Cancer Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Cancer Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Cancer Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Cancer Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Cancer Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Cancer Range Chance"			"16"
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
		// The Super Tank creates a clone of itself.
		// Requires "st_clone.smx" to be installed.
		"Clone Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The amount of clones the Super Tank can create.
			// --
			// Minimum: 1
			// Maximum: 25
			"Clone Amount"					"2"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Clone Chance"					"4"

			// The Super Tank's clone's health.
			// --
			// Minimum: 1
			// Maximum: 65535
			"Clone Health"					"1000"

			// The Super Tank's clone will be treated as a real Super Tank.
			// Note: Clones cannot clone themselves for obvious safety reasons.
			// --
			// 0: OFF, the clone cannot use abilities like real Super Tanks.
			// 1: ON, the clone can use abilities like real Super Tanks.
			"Clone Mode"					"0"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Drop Chance"					"4"

			// The Super Tank has 1 out of this many chances to drop guns with a full clip.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Drop Clip Chance"				"4"

			// The mode of the Super Tank's drop ability.
			// --
			// 0: Both
			// 1: Guns only.
			// 2: Melee weapons only.
			"Drop Mode"						"0"

			// The Super Tank's weapon size is multiplied by this value.
			// Note: Default weapon size x Drop weapon scale
			// --
			// Minimum: 1.0
			// Maximum: 2.0
			"Drop Weapon Scale"				"1.0"
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
		// "Drug Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is drugged.
		// - "Drug Chance"
		// - "Drug Hit Mode"
		// Requires "st_drug.smx" to be installed.
		"Drug Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Drug Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Drug Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Drug Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Drug Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Drug Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Drug Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Drug Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Drug Range Chance"				"16"
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
		// "Electric Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is electrocuted.
		// - "Electric Chance"
		// - "Electric Hit Mode"
		// Requires "st_electric.smx" to be installed.
		"Electric Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Electric Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Electric Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Electric Chance"				"4"

			// The Super Tank's electrocutions do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Electric Damage"				"5"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Electric Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Electric Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Electric Hit Mode"				"0"

			// The Super Tank electrocutes survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Electric Interval"				"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Electric Range"				"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Electric Range Chance"			"16"

			// The Super Tank sets the survivors' run speed to this value when they are electrocuted.
			// --
			// Minimum: 0.1
			// Maximum: 0.99
			"Electric Speed"				"0.75"
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
		// "Enforce Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is forced to only use a certain weapon slot.
		// - "Enforce Chance"
		// - "Enforce Hit Mode"
		// Requires "st_enforce.smx" to be installed.
		"Enforce Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Enforce Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Enforce Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Enforce Chance"				"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Enforce Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Enforce Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Enforce Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Enforce Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Enforce Range Chance"			"16"

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
		// "Fire Hit" - When a survivor is hit by the Super Tank's claw or rock, a fire is created around the survivor.
		// - "Fire Chance"
		// - "Fire Hit Mode"
		// Requires "st_fire.smx" to be installed.
		"Fire Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Fire Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Fire Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message only when "Fire Rock Break" is on.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Fire Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fire Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Fire Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Fire Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Fire Range Chance"				"16"

			// The Super Tank's rock creates a fire when it breaks.
			// Note: This does not need "Ability Enabled" or "Fire Hit" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fire Rock Break"				"0"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Flash Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Flash Duration"				"5.0"

			// The Super Tank can run fast every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Flash Interval"				"1.0"

			// The Super Tank's special speed.
			// --
			// Minimum: 3.0
			// Maximum: 10.0
			"Flash Speed"					"5.0"
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
		// "Fling Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is flung into the air.
		// - "Fling Chance"
		// - "Fling Hit Mode"
		// Requires "st_fling.smx" to be installed.
		"Fling Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Fling Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Fling Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Fling Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Fling Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Fling Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Fling Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Fling Range Chance"			"16"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The bullet damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Bullet damage x Fragile bullet damage
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage x 1.0 = Bullet damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Bullet Damage"			"5.0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Fragile Chance"				"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Duration"				"5.0"

			// The explosive damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Explosive damage x Fragile explosive damage
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage x 1.0 = Explosive damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Explosive Damage"		"5.0"

			// The fire damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Fire damage x Fragile fire damage
			// Example: Damage = 30.0 x 3.0 (90.0)
			// Note: Use the value "1.0" to disable this setting. (Fire damage x 1.0 = Fire damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Fire Damage"			"3.0"

			// The melee damage received by the Super Tank is multiplied by this value.
			// Note: Damage = Melee damage x Fragile melee damage
			// Example: Damage = 100.0 x 1.5 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Melee damage x 1.0 = Melee damage)
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Fragile Melee Damage"			"1.5"
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
		// "Ghost Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is disarmed.
		// - "Ghost Chance"
		// - "Ghost Hit Mode"
		// Requires "st_ghost.smx" to be installed.
		"Ghost Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Ghost Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can disarm survivors.
			// 2: ON, the Super Tank can cloak itself.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"				"0"

			// Display a message whenever the abilities activate/deactivate.
			// --
			// 0: OFF
			// 1: ON, display message only when "Ghost Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is set to 1 or 3.
			// 3: ON, display message only when "Ability Enabled" is set to 2 or 3.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Ghost Chance"					"4"

			// The amount of alpha to take from the Super Tank's alpha every X seconds until the limit set by the "Ghost Fade Limit" is reached.
			// Note: The rate at which the Super Tank's alpha is reduced depends on the "Ghost Fade Rate" setting.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully faded)
			"Ghost Fade Alpha"				"2"

			// The Super Tank's ghost fade effect starts all over after this many seconds passes upon reaching the limit set by the "Ghost Fade Limit" setting.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ghost Fade Delay"				"5.0"

			// The limit of the Super Tank's ghost fade effect.
			// --
			// Minimum: 0 (Fully faded)
			// Maximum: 255 (No effect)
			"Ghost Fade Limit"				"0"

			// The rate of the Super Tank's ghost fade effect.
			// --
			// Minimum: 0.1 (Fastest)
			// Maximum: 9999999999.0 (Slowest)
			"Ghost Fade Rate"				"0.1"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Ghost Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Ghost Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ghost Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Ghost Range Chance"			"16"

			// The Super Tank disarms the following weapon slots.
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
		// The Super Tank gains temporary immunity to all damage.
		// Requires "st_god.smx" to be installed.
		"God Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"God Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"God Duration"					"5.0"
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
		// "Gravity Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor's gravity changes.
		// - "Gravity Chance"
		// - "Gravity Hit Mode"
		// Requires "st_gravity.smx" to be installed.
		"Gravity Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Gravity Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can change survivors' gravity value.
			// 2: ON, the Super Tank can pull in or push away survivors.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Gravity Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is set to 1 or 3.
			// 3: ON, display message only when "Ability Enabled" is set to 2 or 3.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Gravity Chance"				"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Gravity Duration"				"5.0"

			// The Super Tank's gravity force.
			// --
			// Minimum: -100.0
			// Maximum: 100.0
			// --
			// Positive numbers = Push back
			// Negative numbers = Pull back
			"Gravity Force"					"-50.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Gravity Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Gravity Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Gravity Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Gravity Range Chance"			"16"

			// The Super Tank sets the survivors' gravity to this value.
			// --
			// Minimum: 0.1
			// Maximum: 0.99
			"Gravity Value"					"0.3"
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
		// The Super Tank gains health from other nearby infected and gives survivors temporary health.
		// "Ability Enabled" - Any nearby infected can give the Super Tank some health.
		// - "Heal Absorb Range"
		// - "Heal Interval"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor can have temporary health.
		// - "Heal Range"
		// - "Heal Range Chance"
		// "Heal Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor can have temporary health.
		// - "Heal Chance"
		// - "Heal Hit Mode"
		// Requires "st_heal.smx" to be installed.
		"Heal Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Heal Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can give survivors temporary health.
			// 2: ON, the Super Tank can absorb health from nearby infected.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"				"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON, display message only when "Heal Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is set to 1 or 3.
			// 3: ON, display message only when "Ability Enabled" is set to 2 or 3.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The distance between an infected and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Heal Absorb Range"				"500.0"

			// The amount of temporary health given to survivors.
			// --
			// Minimum: 1.0
			// Maximum: 65535.0
			"Heal Buffer"					"25.0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Heal Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Heal Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Heal Hit Mode"					"0"

			// The Super Tank receives health from nearby infected every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Heal Interval"					"5.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Heal Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Heal Range Chance"				"16"

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
			"Health From Tanks"				"500"
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
		// The Super Tank hurts survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor gets hurt repeatedly.
		// - "Hurt Range"
		// - "Hurt Range Chance"
		// "Hurt Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor gets hurt repeatedly.
		// - "Hurt Chance"
		// - "Hurt Hit Mode"
		// Requires "st_hurt.smx" to be installed.
		"Hurt Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Hurt Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Hurt Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Hurt Chance"					"4"

			// The Super Tank's pain inflictions do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Hurt Damage"					"1"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hurt Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Hurt Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Hurt Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Hurt Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Hurt Range Chance"				"16"
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
		// The Super Tank hypnotizes survivors to damage themselves or teammates.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is hypnotized.
		// - "Hypno Range"
		// - "Hypno Range Chance"
		// "Hypno Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is hypnotized.
		// - "Hypno Chance"
		// - "Hypno Hit Mode"
		// Requires "st_hypno.smx" to be installed.
		"Hypno Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Hypno Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Hypno Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Hypno Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Hypno Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Hypno Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Hypno Hit Mode"				"0"

			// The mode of the Super Tank's hypno ability.
			// --
			// 0: Hypnotized survivors hurt themselves.
			// 1: Hypnotized survivors can hurt their teammates.
			"Hypno Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Hypno Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Hypno Range Chance"			"16"
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
		// "Ice Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is frozen in place.
		// - "Ice Chance"
		// - "Ice Hit Mode"
		// Requires "st_ice.smx" to be installed.
		"Ice Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Ice Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Ice Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Ice Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Ice Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Ice Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Ice Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Ice Range"						"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Ice Range Chance"				"16"
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
		// "Idle Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor goes idle.
		// - "Idle Chance"
		// - "Idle Hit Mode"
		// Requires "st_idle.smx" to be installed.
		"Idle Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Idle Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Idle Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Idle Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Idle Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Idle Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Idle Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Idle Range Chance"				"16"
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
		// "Invert Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor's movement keys are inverted.
		// - "Invert Chance"
		// - "Invert Hit Mode"
		// Requires "st_invert.smx" to be installed.
		"Invert Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Invert Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Invert Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Invert Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Invert Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Invert Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Invert Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Invert Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Invert Range Chance"			"16"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Item Chance"					"4"

			// The Super Tank gives survivors this loadout.
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "rifle_m60,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "first_aid_kit,defibrillator,knife,adrenaline"
			"Item Loadout"					"rifle,pistol,first_aid_kit,pain_pills"

			// The mode of the Super Tank's item ability.
			// --
			// 0: Survivors get a random item.
			// 1: Survivors get all items.
			"Item Mode"						"0"
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
		// The Super Tank jumps periodically.
		// Requires "st_jump.smx" to be installed.
		"Jump Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank jumps this high off a surface.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Height"					"300.0"

			// The Super Tank jumps every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Jump Interval"					"1.0"
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
		// "Kamikaze Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor dies along with the Super Tank.
		// - "Kamikaze Chance"
		// - "Kamikaze Hit Mode"
		// Requires "st_kamikaze.smx" to be installed.
		"Kamikaze Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Kamikaze Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Kamikaze Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Kamikaze Chance"				"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Kamikaze Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Kamikaze Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Kamikaze Range"				"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Kamikaze Range Chance"			"16"
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
		// "Leech Hit" - When a survivor is hit by the Super Tank's claw or rock, the Super Tank leeches health off of the survivor.
		// - "Leech Chance"
		// - "Leech Hit Mode"
		// Requires "st_leech.smx" to be installed.
		"Leech Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Leech Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Leech Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Leech Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Leech Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Leech Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Leech Hit Mode"				"0"

			// The Super Tank leeches health off of survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Leech Interval"				"1.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Leech Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Leech Range Chance"			"16"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Medic Chance"					"4"

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
			"Medic Health"					"25,25,25,25,25,25"

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
			"Medic Max Health"				"250,50,250,100,325,600"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Medic Range"					"500.0"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Meteor Chance"					"4"

			// The Super Tank's meteorites do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Meteor Damage"					"5"

			// The radius of the Super Tank's meteor shower.
			// --
			// 1st number = Minimum radius
			// Minimum: -200.0
			// Maximum: 0.0
			// --
			// 2nd number = Maximum radius
			// Minimum: 0.0
			// Maximum: 200.0
			"Meteor Radius"					"-180.0,180.0"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The amount of minions the Super Tank can spawn.
			// --
			// Minimum: 1
			// Maximum: 25
			"Minion Amount"					"5"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Minion Chance"					"4"

			// The Super Tank can spawn these minions.
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chance of being chosen.
			// Character limit: 12
			// --
			// 1: Smoker
			// 2: Boomer
			// 3: Hunter
			// 4: Spitter (Switches to Boomer in L4D1.)
			// 5: Jockey (Switches to Hunter in L4D1.)
			// 6: Charger (Switches to Smoker in L4D1.)
			"Minion Types"					"123456"
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
		// The Super Tank resurrects dead special infected.
		// Requires "st_necro.smx" to be installed.
		"Necro Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Necro Chance"					"4"

			// The distance between a special infected and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Necro Range"					"500.0"
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
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor does not do any damage.
		// - "Nullify Range"
		// - "Nullify Range Chance"
		// "Nullify Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor does not do any damage.
		// - "Nullify Chance"
		// - "Nullify Hit Mode"
		// Requires "st_nullify.smx" to be installed.
		"Nullify Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Nullify Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Nullify Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Nullify Chance"				"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Nullify Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Nullify Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Nullify Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Nullify Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Nullify Range Chance"			"16"
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
		// "Ability Enabled" - The Tank starts a panic event periodically.
		// - "Panic Interval"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, a panic event starts.
		// - "Panic Range"
		// - "Panic Range Chance"
		// "Panic Hit" - When a survivor is hit by the Super Tank's claw or rock, a panic event starts.
		// - "Panic Chance"
		// - "Panic Hit Mode"
		// Requires "st_panic.smx" to be installed.
		"Panic Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Panic Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can start panic events when a survivor is nearby.
			// 2: ON, the Super Tank can start panic events periodically.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"				"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON, display message only when "Panic Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is set to 1 or 3.
			// 3: ON, display message only when "Ability Enabled" is set to 2 or 3.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Panic Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Panic Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Panic Hit Mode"				"0"

			// The Super Tank starts a panic event every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Panic Interval"				"5.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Panic Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Panic Range Chance"			"16"
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
		// "Pimp Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is repeatedly pimp slapped.
		// - "Pimp Chance"
		// - "Pimp Hit Mode"
		// Requires "st_pimp.smx" to be installed.
		"Pimp Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Pimp Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Pimp Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The amount of pimp slaps the Super Tank can give to survivors.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Pimp Amount"					"5"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Pimp Chance"					"4"

			// The Super Tank's pimp slaps do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Pimp Damage"					"1"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Pimp Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Pimp Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Pimp Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Pimp Range Chance"				"16"
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
		// "Puke Hit" - When a survivor is hit by the Super Tank's claw or rock, the Super Tank pukes on the survivor.
		// - "Puke Chance"
		// - "Puke Hit Mode"
		// Requires "st_puke.smx" to be installed.
		"Puke Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Puke Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Puke Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Puke Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Puke Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Puke Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Puke Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Puke Range Chance"				"16"
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
		// The Super Tank gains a speed boost when on fire.
		// Requires "st_pyro.smx" to be installed.
		"Pyro Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank's speed boost value when on fire.
			// --
			// Minimum: 0.1
			// Maximum: 3.0
			"Pyro Boost"					"1.0"

			// The mode of the Super Tank's speed boost.
			// --
			// 0: Super Tank's speed = Run speed + Pyro boost
			// 1: Super Tank's speed = Pyro boost
			"Pyro Mode"						"0"
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
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor cannot hear the Super Tank's noises.
		// - "Quiet Range"
		// - "Quiet Range Chance"
		// "Quiet Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor cannot hear the Super Tank's noises.
		// - "Quiet Chance"
		// - "Quiet Hit Mode"
		// Requires "st_quiet.smx" to be installed.
		"Quiet Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Quiet Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Quiet Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Quiet Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Quiet Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Quiet Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Quiet Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Quiet Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Quiet Range Chance"			"16"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank regenerates this much health each time.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Regen health
			// Negative numbers: Current health - Regen health
			"Regen Health"					"1"

			// The Super Tank regenerates health every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Regen Interval"				"1.0"

			// The Super Tank stops regenerating health at this value.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: The Super Tank will stop regenerating health when it reaches this number.
			// Negative numbers: The Super Tank will stop losing health when it reaches this number.
			"Regen Limit"					"65535"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank respawns up to this many times.
			// Note: This setting only applies if the "Respawn Random" setting is set to 0.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Respawn Amount"				"1"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Respawn Chance"				"4"

			// The mode of the Super Tank's respawns.
			// --
			// 0: The Super Tank respawns as the same type.
			// 1: The Super Tank respawns as the type used in the "Respawn Type" setting.
			// 2: The Super Tank respawns as a random type.
			"Respawn Mode"					"0"

			// The type that the Super Tank will respawn as.
			// --
			// 0: OFF, use the randomization feature.
			// 1-5000: ON, the type to respawn as.
			"Respawn Type"					"0"
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
		// The Super Tank forces survivors to restart at the beginning of the map with a new loadout.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor respawns at the start of the map or near a teammate.
		// - "Restart Range"
		// - "Restart Range Chance"
		// "Restart Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor respawns at the start of the map or near a teammate.
		// - "Restart Chance"
		// - "Restart Hit Mode"
		// Requires "st_restart.smx" to be installed.
		"Restart Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Restart Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Restart Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Restart Chance"				"4"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Restart Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Restart Hit Mode"				"0"

			// The Super Tank makes survivors restart with this loadout.
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "smg_silenced,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "first_aid_kit,defibrillator,knife,adrenaline"
			"Restart Loadout"				"smg,pistol,pain_pills"

			// The mode of the Super Tank's restart ability.
			// --
			// 0: Survivors are teleported to the spawn area.
			// 1: Survivors are teleported to another teammate.
			"Restart Mode"					"1"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Restart Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Restart Range Chance"			"16"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Rock Chance"					"4"

			// The Super Tank's rocks do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Rock Damage"					"5"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Rock Duration"					"5.0"

			// The radius of the Super Tank's rock shower.
			// --
			// 1st number = Minimum radius
			// Minimum: -5.0
			// Maximum: 0.0
			// --
			// 2nd number = Maximum radius
			// Minimum: 0.0
			// Maximum: 5.0
			"Rock Radius"					"-1.25,1.25"
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
		// "Rocket Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is sent into space.
		// - "Rocket Chance"
		// - "Rocket Hit Mode"
		// Requires "st_rocket.smx" to be installed.
		"Rocket Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Rocket Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Rocket Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Rocket Chance"					"4"

			// The Super Tank sends survivors into space after this many seconds passes upon triggering the ability.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Rocket Delay"					"1.0"

			// Enable the Super Tank's claw/rock attack.
			// --
			// 0: OFF
			// 1: ON
			"Rocket Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Rocket Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Rocket Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Rocket Range Chance"			"16"
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
		// "Shake Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor's screen is shaken.
		// - "Shake Chance"
		// - "Shake Hit Mode"
		// Requires "st_shake.smx" to be installed.
		"Shake Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Shake Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Shake Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Shake Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shake Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Shake Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Shake Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Shake Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Shake Range Chance"			"16"
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
		// The Super Tank protects itself with a shield and traps survivors inside their own shields.
		// Requires "st_shield.smx" to be installed.
		"Shield Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// This is the Super Tank's shield's color.
			// --
			// Minimum value for each color: 0
			// Maximum value for each color: 255
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			"Shield Color"					"255,255,255"

			// The Super Tank's shield reactivates after this many seconds passes upon destroying the shield.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shield Delay"					"5.0"
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
		// The Super Tank shoves survivors.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is shoved repeatedly.
		// - "Shove Range"
		// - "Shove Range Chance"
		// "Shove Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is shoved repeatedly.
		// - "Shove Chance"
		// - "Shove Hit Mode"
		// Requires "st_shove.smx" to be installed.
		"Shove Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Shove Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Shove Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Shove Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Shove Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Shove Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Shove Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Shove Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Shove Range Chance"			"16"
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
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is smashed.
		// - "Smash Range"
		// - "Smash Range Chance"
		// "Smash Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is crushed to death.
		// - "Smash Chance"
		// - "Smash Hit Mode"
		// Requires "st_smash.smx" to be installed.
		"Smash Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Smash Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Smash Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Smash Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Smash Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Smash Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Smash Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Smash Range Chance"			"16"
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
		// "Smite Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is smitten.
		// - "Smite Chance"
		// - "Smite Hit Mode"
		// Requires "st_smite.smx" to be installed.
		"Smite Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Smite Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Smite Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Smite Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Smite Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Smite Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Smite Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Smite Range Chance"			"16"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Spam Chance"					"4"

			// The Super Tank's rocks do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Spam Damage"					"5"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Spam Duration"					"5.0"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Splash Chance"					"4"

			// The Super Tank's splashes do this much damage.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Splash Damage"					"5"

			// The Super Tank deals splash damage to nearby survivors every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Splash Interval"				"5.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Splash Range"					"150.0"
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
		// "Stun Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is slowed down.
		// - "Stun Chance"
		// - "Stun Hit Mode"
		// Requires "st_stun.smx" to be installed.
		"Stun Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Stun Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Stun Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Stun Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Stun Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Stun Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Stun Hit Mode"					"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Stun Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Stun Range Chance"				"16"

			// The Super Tank sets the survivors' run speed to this value.
			// --
			// Minimum: 0.1
			// Maximum: 0.99
			"Stun Speed"					"0.25"
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
		// The Super Tank throws things.
		// Requires "st_throw.smx" to be installed.
		"Throw Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON, the Super Tank throws cars.
			// 2: ON, the Super Tank throws special infected.
			// 3: ON, the Super Tank throws itself.
			"Ability Enabled"				"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON, display message only when "Ability Enabled" is set to 1.
			// 2: ON, display message only when "Ability Enabled" is set to 2.
			// 3: ON, display message only when "Ability Enabled" is set to 3.
			// 4: ON, display message when 1 or 2 apply.
			// 5: ON, display message when 1 or 3 apply.
			// 6: ON, display message when 2 or 3 apply.
			// 7: ON, display message when 1, 2, or 3 apply.
			"Ability Message"				"0"

			// The Super Tank can throw these cars.
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chance of being chosen.
			// Character limit: 6
			// --
			// 1: Small car with a big hatchback.
			// 2: Car that looks like a Chevrolet Impala SS.
			// 3: Car that looks like a Sixth Generation Chevrolet Impala.
			"Throw Car Options"				"123"

			// The Super Tank can throw these special infected.
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chance of being chosen.
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
		// The Super Tank throws a heat-seeking rock that will track down the nearest survivor.
		// Requires "st_track.smx" to be installed.
		"Track Ability"
		{
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Track Chance"					"4"

			// The mode of the Super Tank's track ability.
			// --
			// 0: The Super Tank's rock will only start tracking when it is near a survivor.
			// 1: The Super Tank's rock will track the nearest survivor.
			"Track Mode"					"1"

			// The Super Tank's track ability is this fast.
			// Note: This setting only applies if the "Track Mode" setting is set to 1.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Track Speed"					"500.0"
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
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the Super Tank gains health.
		// - "Vampire Health"
		// - "Vampire Range"
		// - "Vampire Range Chance"
		// "Vampire Hit" - When a survivor is hit by the Super Tank's claw or rock, the Super Tank gains health.
		// - "Vampire Chance"
		// - "Vampire Hit Mode"
		// Requires "st_vampire.smx" to be installed.
		"Vampire Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Vampire Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Vampire Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Vampire Chance"				"4"

			// The Super Tank receives this much health from survivors.
			// Note: Tank's health limit on any difficulty is 65,535.
			// Note: This setting does not apply to the "Vampire Hit" setting.
			// --
			// Minimum: -65535
			// Maximum: 65535
			// --
			// Positive numbers: Current health + Vampire health
			// Negative numbers: Current health - Vampire health
			"Vampire Health"				"100"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Vampire Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Vampire Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Vampire Range"					"500.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Vampire Range Chance"			"16"
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
		// The Super Tank changes the survivors' field of views.
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor's vision changes.
		// - "Vision Range"
		// - "Vision Range Chance"
		// "Vision Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor's vision changes.
		// - "Vision Chance"
		// - "Vision Hit Mode"
		// Requires "st_vision.smx" to be installed.
		"Vision Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Vision Hit" setting.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON, display message only when "Vision Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is on.
			// 3: ON, display message when both are on.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Vision Chance"					"4"

			// The Super Tank's ability effects last this long.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Vision Duration"				"5.0"

			// The Super Tank sets survivors' fields of view to this value.
			// --
			// Minimum: 1
			// Maximum: 160
			"Vision FOV"					"160"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// --
			// 0: OFF
			// 1: ON
			"Vision Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Vision Hit Mode"				"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Vision Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Vision Range Chance"			"16"
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
		// The Super Tank warps to survivors and warps survivors back to teammates.
		// "Ability Enabled" - The Tank warps to a random survivor.
		// - "Warp Interval"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, the survivor is warped to a random teammate.
		// - "Warp Range"
		// - "Warp Range Chance"
		// "Warp Hit" - When a survivor is hit by the Super Tank's claw or rock, the survivor is warped to a random teammate.
		// - "Warp Chance"
		// - "Warp Hit Mode"
		// Requires "st_warp.smx" to be installed.
		"Warp Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Warp Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can warp a survivor to a random teammate.
			// 2: ON, the Super Tank can warp itself to a survivor.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"				"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON, display message only when "Warp Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is set to 1 or 3.
			// 3: ON, display message only when "Ability Enabled" is set to 2 or 3.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Warp Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Warp Hit"						"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Warp Hit Mode"					"0"

			// The Super Tank warps to a random survivor every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Warp Interval"					"5.0"

			// The mode of the Super Tank's warp ability.
			// --
			// 0: The Super Tank warps to a random survivor.
			// 1: The Super Tank switches places with a random survivor.
			"Warp Mode"						"0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Warp Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Warp Range Chance"				"16"
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
			// Enable this ability.
			// --
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// Display a message whenever the ability activates/deactivates.
			// --
			// 0: OFF
			// 1: ON
			"Ability Message"				"0"

			// The Super Tank converts this many common infected into Witch minions at once.
			// --
			// Minimum: 1
			// Maximum: 25
			"Witch Amount"					"3"

			// The Super Tank's Witch minion causes this much damage per hit.
			// --
			// Minimum: 1
			// Maximum: 9999999999
			"Witch Damage"					"5"

			// The distance between a common infected and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Witch Range"					"500.0"
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
		// "Ability Enabled" - The Tank creates a zombie mob periodically.
		// - "Zombie Interval"
		// "Ability Enabled" - When a survivor is within range of the Super Tank, a zombie mob appears.
		// - "Zombie Range"
		// - "Zombie Range Chance"
		// "Panic Hit" - When a survivor is hit by the Super Tank's claw or rock, a zombie mob appears.
		// - "Zombie Chance"
		// - "Zombie Hit Mode"
		// Requires "st_zombie.smx" to be installed.
		"Zombie Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Zombie Hit" setting.
			// --
			// 0: OFF
			// 1: ON, the Super Tank can create zombie mobs when a survivor is nearby.
			// 2: ON, the Super Tank can create zombie mobs periodically.
			// 3: ON, the Super Tank can do both.
			"Ability Enabled"				"0"

			// Display a message whenever the ability activate/deactivate.
			// --
			// 0: OFF
			// 1: ON, display message only when "Zombie Hit" is on.
			// 2: ON, display message only when "Ability Enabled" is set to 1 or 3.
			// 3: ON, display message only when "Ability Enabled" is set to 2 or 3.
			// 4: ON, display message when 1 and 2 apply.
			// 5: ON, display message when 1 and 3 apply.
			// 6: ON, display message when 2 and 3 apply.
			// 7: ON, display message when 1, 2, and 3 apply.
			"Ability Message"				"0"

			// The Super Tank spawns this many common infected at once.
			// --
			// Minimum: 1
			// Maximum: 100
			"Zombie Amount"					"10"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Zombie Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" to be on.
			// --
			// 0: OFF
			// 1: ON
			"Zombie Hit"					"0"

			// The mode of the Super Tank's claw/rock attack.
			// --
			// 0: Both
			// 1: Ability activates when the Super Tank hits a survivor.
			// 2: Ability activates when the Super Tank is hit by a survivor.
			"Zombie Hit Mode"				"0"

			// The Super Tank spawns a zombie mob every time this many seconds passes.
			// --
			// Minimum: 0.1
			// Maximum: 9999999999.0
			"Zombie Interval"				"5.0"

			// The distance between a survivor and the Super Tank needed to trigger the ability.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 9999999999.0 (Farthest)
			"Zombie Range"					"150.0"

			// The Super Tank has 1 out of this many chances to trigger the range ability.
			// --
			// Minimum: 1 (Greatest chance)
			// Maximum: 9999999999 (Less chance)
			"Zombie Range Chance"			"16"
		}
	}
}
```