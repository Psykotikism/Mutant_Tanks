# Super Tanks++
Super Tanks++ takes the original [Super Tanks](https://forums.alliedmods.net/showthread.php?t=165858) by [Machine](https://forums.alliedmods.net/member.php?u=74752) to the next level by enabling full customization of Super Tanks to make gameplay more interesting.

## License
Super Tanks++: a L4D/L4D2 SourceMod Plugin
Copyright (C) 2018 Alfred "Crasher_3637/Psyk0tik" Llagas

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

## About
Super Tanks++ makes fighting Tanks great again!

> Super Tanks++ will enhance and intensify Tank fights by making each Tank that spawns unique and different in its own way.

### What makes Super Tanks++ viable in Left 4 Dead/Left 4 Dead 2?
Super Tanks++ enhances the experience and fun that players get from Tank fights by 1000. This plugin gives server owners an arsenal of Super Tanks to test players' skills and create a unique experience in every Tank fight.

### Requirements
SourceMod 1.8+

### Installation
1. Delete files from old versions of the plugin.
2. Extract the folder inside the .zip file.
3. Place all the contents into their respective folders.
4. If prompted to replace or merge anything, click yes.
5. Load up Super Tanks++.
  - Type ```sm_rcon sm plugins load super_tanks++``` in console.
  - OR restart the server.
6. Customize Super Tanks++ in super_tanks++.cfg.

### Uninstalling/Upgrading to Newer Versions
1. Delete super_tanks++.smx from addons/sourcemod/plugins folder.
2. Delete super_tanks++.txt from addons/sourcemod/gamedata folder.
3. Delete super_tanks++ folder from addons/sourcemod/scripting folder.
4. Delete super_tanks++.inc from addons/sourcemod/scripting/include folder.
5. Delete super_tanks++ folder from cfg/sourcemod folder.
6. Follow the Installation guide above. (Only for upgrading to newer versions.)

### Disabling
1. Move super_tanks++.smx to plugins/disabled folder.
2. Unload Super Tanks++.
  - Type ```sm_rcon sm plugins unload super_tanks++``` in console.
  - OR restart the server.

## Features
1. Supports multiple game modes - Provides the option to enable/disable the plugin in certain game modes.
2. Custom configurations - Provides support for custom configurations, whether per difficulty, per map, per game mode, per day, or per player count.
3. Fully customizable Super Tank types - Provides the ability to fully customize all the Super Tanks that come with the auto-generated KeyValue config file and user-made Super Tanks.
4. Create and save up to 1000 Super Tank types - Provides the ability to store up to 1000 Super Tank types that users can enable/disable.
5. Easy-to-use config file - Provides a user-friendly KeyValues config file that users can easily understand and edit.

## KeyValues Settings
```
// Super Tanks++ KeyValues Settings
"Super Tanks++"
{
	// These are the general settings.
	// Note: The following settings will not work in custom config files:
	// "Game Mode Types"
	// "Enabled Game Modes"
	// "Disabled Game Modes"
	// "Enable Custom Configs"
	// "Create Config Types"
	// "Execute Config Types"
	"Plugin Settings"
	{
		"General"
		{
			// Enable Super Tanks++.
			// 0: OFF
			// 1: ON
			"Plugin Enabled"				"1"

			// Enable Super Tanks++ in these game mode types.
			// Add up numbers together for different results.
			// 0: All game mode types.
			// 1: Co-Op modes only.
			// 2: Versus modes only.
			// 4: Survival modes only.
			// 8: Scavenge modes only. (Only available in Left 4 Dead 2.)
			"Game Mode Types"				"0"

			// Enable Super Tanks++ in these game modes.
			// Separate game modes with commas.
			// Game mode limit: 64
			// Character limit for each game mode: 64
			// Empty: All
			// Not empty: Enabled only in these game modes.
			"Enabled Game Modes"			""

			// Disable Super Tanks++ in these game modes.
			// Separate game modes with commas.
			// Game mode limit: 64
			// Character limit for each game mode: 64
			// Empty: None
			// Not empty: Disabled only in these game modes.
			"Disabled Game Modes"			""

			// Announce each Super Tank's arrival.
			// 0: OFF
			// 1: ON
			"Announce Arrival"				"1"

			// Display Tanks' names and health.
			// 0: OFF
			// 1: ON, show names only.
			// 2: ON, show health only.
			// 3: ON, show both names and health.
			"Display Health"				"3"

			// Enable Super Tanks++ in finales only.
			// 0: OFF
			// 1: ON
			"Finales Only"					"0"

			// Enable Super Tanks++ for human-controlled Tanks.
			// Note: Some Super Tank abilities may be too overpowered to use in a competitive game mode.
			// 0: OFF
			// 1: ON
			"Human Super Tanks"				"1"

			// Maximum types of Super Tanks allowed.
			// Minimum: 1
			// Maximum: 1000
			"Maximum Types"					"72"

			// Multiply the Super Tank's health.
			// 0: No changes to health.
			// 1: Multiply original health only.
			// 2: Multiply extra health only.
			// 3: Multiply both.
			"Multiply Health"				"0"

			// Amount of Tanks to spawn for each finale wave.
			// Separate waves with commas.
			// Wave limit: 3
			// Character limit for each wave: 3
			// 1st number = 1st wave
			// 2nd number = 2nd wave
			// 3rd number = 3rd wave
			"Tank Waves"					"2,3,4"
		}
		"Custom"
		{
			// Enable Super Tanks++ custom configuration.
			// 0: OFF
			// 1: ON
			"Enable Custom Configs"			"0"

			// The type of custom config that Super Tanks++ creates.
			// Combine numbers in any order for different results.
			// Character limit: 5
			// 1: Difficulties
			// 2: Maps
			// 3: Game modes
			// 4: Days
			// 5: Player count
			"Create Config Types"			"12345"

			// The type of custom config that Super Tanks++ executes.
			// Combine numbers in any order for different results.
			// Character limit: 5
			// 1: Difficulties
			// 2: Maps
			// 3: Game modes
			// 4: Days
			// 5: Player count
			"Execute Config Types"			"1"
		}
	}
	"Example"
	{
		"General"
		{
			// Name of the Super Tank.
			// Character limit: 32
			"Tank Name"						"Tank 1"

			// Enable the Super Tank.
			// 0: OFF
			// 1: ON
			"Tank Enabled"					"0"

			// These are the Super Tank's skin and glow outline colors.
			// Separate colors with "|".
			// Separate RGBAs with commas.
			// 1st set = skin color (RGBA)
			// 2nd set = glow color (RGB)
			"Skin-Glow Colors"				"255,255,255,255|255,255,255"

			// The Super Tank will have a glow outline.
			// Only available in Left 4 Dead 2.
			// 0: OFF
			// 1: ON
			"Glow Effect"					"1"

			// Props that the Super Tank can spawn with.
			// Combine numbers in any order for different results.
			// Character limit: 6
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
			// 1st set = lights color (RGBA)
			// 2nd set = oxygen tanks color (RGBA)
			// 3rd set = oxygen tank flames color (RGBA)
			// 4th set = rocks color (RGBA)
			// 5th set = tires color (RGBA)
			"Props Colors"					"255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255"

			// The Super Tank will spawn with a particle effect.
			// 0: OFF
			// 1: ON
			"Particle Effect"				"0"

			// The particle effects for the Super Tank.
			// Combine numbers in any order for different results.
			// Character limit: 7
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 3: Fire Trail
			// 4: Ice Steam
			// 5: Meteor Smoke
			// 6: Smoker Cloud
			// 7: Acid Trail (Only available in Left 4 Dead 2.)
			"Particle Effects"				"1234567"

			// The Super Tank's rock will have a particle effect.
			// 0: OFF
			// 1: ON
			"Rock Effect"					"0"

			// The particle effects for the Super Tank's rock.
			// Combine numbers in any order for different results.
			// Character limit: 4
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 3: Fire Trail
			// 4: Acid Trail (Only available in Left 4 Dead 2.)
			"Rock Effects"					"1234"
		}
		"Enhancements"
		{
			// Extra health given to the Super Tank.
			// Note: Tank's health limit on any difficulty is 62,400.
			// Note: Depending on the setting for "Multiply Health," the Super Tank's health will be multiplied based on player count.
			// Note: Health changes only occur when there are at least 2 alive non-idle human survivors.
			// Minimum: 0
			// Maximum: 65535
			"Extra Health"					"0"

			// Set the Super Tank's run speed.
			// Note: Default run speed is 1.0.
			// Minimum: 0.1
			// Maximum: 3.0
			"Run Speed"						"1.0"

			// The Super Tank's rock throw interval.
			// Note: Default throw interval is 5.0 seconds.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Throw Interval"				"5.0"
		}
		"Immunities"
		{
			// Give the Super Tank bullet immunity.
			// 0: OFF
			// 1: ON
			"Bullet Immunity"				"0"

			// Give the Super Tank explosive immunity.
			// 0: OFF
			// 1: ON
			"Explosive Immunity"			"0"

			// Give the Super Tank fire immunity.
			// 0: OFF
			// 1: ON
			"Fire Immunity"					"0"

			// Give the Super Tank melee immunity.
			// 0: OFF
			// 1: ON
			"Melee Immunity"				"0"
		}
		// The Super Tank absorbs most of the damage it receives.
		"Absorb Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Absorb Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Absorb Duration"				"5.0"
		}
		// The Super Tank creates acid puddles.
		// "Ability Enabled" - When a survivor is within range of the Tank, an acid puddle is created underneath the survivor.
		// "Acid Hit" - When a survivor is hit by a Tank's claw or rock, an acid puddle is created underneath the survivor.
		"Acid Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Acid Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Acid Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Acid Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Acid Range"					"500.0"

			// The Super Tank's rock spawns acid puddles when it breaks.
			// Only available in Left 4 Dead 2.
			// 0: OFF
			// 1: ON
			"Acid Rock Break"				"0"
		}
		// The Super Tank takes away survivors' ammunition.
		// "Ability Enabled" - When a survivor is within range of the Tank, their ammunition is taken away.
		// "Ammo Hit" - When a survivor is hit by a Tank's claw or rock, their ammunition is taken away.
		"Ammo Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Ammo Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Ammo Chance"					"4"

			// The Super Tank sets survivors' ammunition to this amount.
			// Minimum: 0
			// Maximum: 25
			"Ammo Count"					"0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Ammo Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Ammo Range"					"500.0"
		}
		// The Super Tank blinds survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is blinded.
		// "Blind Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is blinded.
		"Blind Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Blind Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Blind Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Blind Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Blind Hit"						"0"

			// The intensity of the Super Tank's blind effect.
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully blind)
			"Blind Intensity"				"255"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Blind Range"					"500.0"
		}
		// The Super Tank creates explosions.
		// "Ability Enabled" - When a survivor is within range of the Tank, an explosion is created around the survivor.
		// "Bomb Hit" - When a survivor is hit by a Tank's claw or rock, an explosion is created around the survivor.
		"Bomb Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Bomb Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Bomb Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Bomb Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Bomb Range"					"500.0"

			// The Super Tank's rock explodes when it breaks.
			// 0: OFF
			// 1: ON
			"Bomb Rock Break"				"0"
		}
		// The Super Tank buries survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is buried.
		// "Bury Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is buried.
		"Bury Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Bury Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Bury Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Bury Duration"					"5.0"

			// The Super Tank buries survivors this deep into the ground.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Bury Height"					"50.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Bury Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Bury Range"					"500.0"
		}
		// The Super Tank creates clones of itself.
		"Clone Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The amount of clones the Super Tank can spawn.
			// Minimum: 1
			// Maximum: 25
			"Clone Amount"					"2"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Clone Chance"					"4"

			// The Super Tank's clones' health.
			// Minimum: 1
			// Maximum: 65535
			"Clone Health"					"1000"

			// The mode of the Super Tank's clone ability.
			// 0: Clones will not have access to the same abilities as the original Super Tank.
			// 1: Clones will have access to the same abilities as the original Super Tank.
			"Clone Mode"					"0"
		}
		// The Super Tank drugs survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is drugged.
		// "Drug Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is drugged.
		"Drug Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Drug Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Drug Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Drug Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Drug Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Drug Range"					"500.0"
		}
		// The Super Tank creates fires.
		// "Ability Enabled" - When a survivor is within range of the Tank, a fire is created around the survivor.
		// "Fire Hit" - When a survivor is hit by a Tank's claw or rock, a fire is created around the survivor.
		"Fire Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Fire Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Fire Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Fire Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Fire Range"					"500.0"

			// The Super Tank's rock starts fires when it breaks.
			// 0: OFF
			// 1: ON
			"Fire Rock Break"				"0"
		}
		// The Super Tank runs really fast like the Flash.
		"Flash Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Flash Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Flash Duration"				"5.0"

			// The Super Tank's special speed.
			// Minimum: 3.0
			// Maximum: 10.0
			"Flash Speed"					"5.0"
		}
		// The Super Tank flings survivors high into the air.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is flung into the air.
		// "Fling Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is flung into the air.
		"Fling Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Fling Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Fling Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Fling Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Fling Range"					"500.0"
		}
		// The Super Tank makes itself and any other nearby infected invisible, and disarms survivors.
		// "Ability Enabled" - Any nearby infected turns invisible.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is disarmed.
		// "Ghost Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is disarmed.
		"Ghost Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Ghost Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Ghost Chance"					"4"

			// The limit of the Super Tank's ghost fade effect.
			// Minimum: 0 (Fully faded)
			// Maximum: 255 (No effect)
			"Ghost Fade Limit"				"0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Ghost Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Ghost Range"					"500.0"

			// The Super Tank disarms the following weapon slots.
			// Combine numbers in any order for different results.
			// Character limit: 5
			// 1: 1st slot only.
			// 2: 2nd slot only.
			// 3: 3rd slot only.
			// 4: 4th slot only.
			// 5: 5th slot only.
			"Ghost Weapon Slots"			"12345"
		}
		// The Super Tank gains temporary immunity to all damage.
		"God Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"God Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"God Duration"					"5.0"
		}
		// The Super Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.
		// "Ability Enabled" - Any nearby infected and survivors are pulled in or pushed away.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor's gravity changes.
		// "Gravity Hit" - When a survivor is hit by a Tank's claw or rock, the survivor's gravity changes.
		"Gravity Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Gravity Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Gravity Chance"				"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Gravity Duration"				"5.0"

			// The Super Tank's gravity force.
			// Positive numbers = Push back
			// Negative numbers = Pull back
			// Minimum: -100.0
			// Maximum: 100.0
			"Gravity Force"					"-50.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Gravity Hit"					"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Gravity Range"					"500.0"

			// The Super Tank sets the survivors' gravity to this value.
			// Minimum: 0.1
			// Maximum: 0.99
			"Gravity Value"					"0.3"
		}
		// The Super Tank gains health from other nearby infected and sets survivors to black and white with temporary health.
		// "Ability Enabled" - Any nearby infected can give the Tank some health.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor can go black and white and have temporary health.
		// "Heal Hit" - When a survivor is hit by a Tank's claw or rock, the survivor can go black and white and have temporary health.
		"Heal Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Heal Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Heal Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Heal Hit"						"0"

			// The Super Tank receives health from nearby infected every time this many seconds passes.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Heal Interval"					"5.0"

			// The distance between an infected and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Heal Range"					"500.0"

			// The Super Tank receives this much health from nearby common infected.
			// Minimum: 0
			// Maximum: 65535
			"Health From Commons"			"50"

			// The Super Tank receives this much health from other nearby special infected.
			// Minimum: 0
			// Maximum: 65535
			"Health From Specials"			"100"

			// The Super Tank receives this much health from other nearby Tanks.
			// Minimum: 0
			// Maximum: 65535
			"Health From Tanks"				"500"
		}
		// The Super Tank hurts survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor gets hurt repeatedly.
		// "Hurt Hit" - When a survivor is hit by a Tank's claw or rock, the survivor gets hurt repeatedly.
		"Hurt Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Hurt Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Hurt Chance"					"4"

			// The Super Tank's pain infliction does this much damage.
			// Minimum: 1
			// Maximum: 99999
			"Hurt Damage"					"1"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Hurt Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Hurt Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Hurt Range"					"500.0"
		}
		// The Super Tank hypnotizes survivors to damage themselves or teammates.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is hypnotized.
		// "Hypno Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is hypnotized.
		"Hypno Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Hypno Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Hypno Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Hypno Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Hypno Hit"						"0"

			// The mode of the Super Tank's hypno ability.
			// 0: Hypnotized survivors hurt themselves.
			// 1: Hypnotized survivors can hurt their teammates.
			"Hypno Mode"					"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Hypno Range"					"500.0"
		}
		// The Super Tank freezes survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is frozen in place.
		// "Ice Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is frozen in place.
		"Ice Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Ice Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Ice Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Ice Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Ice Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Ice Range"						"500.0"
		}
		// The Super Tank forces survivors to go idle.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor goes idle.
		// "Idle Hit" - When a survivor is hit by a Tank's claw or rock, the survivor goes idle.
		"Idle Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Idle Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Idle Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Idle Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Idle Range"					"500.0"
		}
		// The Super Tank inverts the survivors' movement keys.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor's movement keys are inverted.
		// "Invert Hit" - When a survivor is hit by a Tank's claw or rock, the survivor's movement keys are inverted.
		"Invert Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Invert Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"50.0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Invert Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Invert Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// 0: OFF
			// 1: ON
			"Invert Hit"					"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Invert Range"					"500.0"
		}
		// The Super Tank jumps really high.
		"Jump Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Jump Chance"					"4"
		}
		// The Super Tank creates meteor showers.
		"Meteor Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Meteor Chance"					"4"

			// The Super Tank's meteorites do this much damage.
			// Minimum: 1
			// Maximum: 99999
			"Meteor Damage"					"25"

			// The radius of the Super Tank's meteor shower.
			// 1st number = Minimum radius
			// Minimum: -200.0
			// Maximum: 0.0
			// 2nd number = Maximum radius
			// Minimum: 0.0
			// Maximum: 200.0
			"Meteor Radius"					"-180.0,180.0"
		}
		// The Super Tank spawns minions.
		"Minion Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The amount of minions the Super Tank can spawn.
			// Minimum: 1
			// Maximum: 25
			"Minion Amount"					"5"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Minion Chance"					"4"

			// The Super Tank can spawn these minions.
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chance of being chosen.
			// Character limit: 12
			// 1: Smoker
			// 2: Boomer
			// 3: Hunter
			// 4: Spitter (Switches to Boomer in L4D1.)
			// 5: Jockey (Switches to Hunter in L4D1.)
			// 6: Charger (Switches to Smoker in L4D1.)
			"Minion Types"					"123456"
		}
		// The Super Tank nullifies all of the survivors' damage.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor does not do any damage.
		// "Nullify Hit" - When a survivor is hit by a Tank's claw or rock, the survivor does not do any damage.
		"Nullify Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Nullify Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Nullify Chance"				"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Nullify Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// 0: OFF
			// 1: ON
			"Nullify Hit"					"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Nullify Range"					"500.0"
		}
		// The Super Tank starts panic events.
		// "Ability Enabled" - The Tank starts a panic event periodically.
		// "Panic Hit" - When a survivor is hit by a Tank's claw or rock, a panic event starts.
		"Panic Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Panic Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Panic Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Panic Hit"						"0"

			// The Super Tank starts a panic event every time this many seconds passes.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Panic Interval"				"5.0"
		}
		// The Super Tank pimp slaps survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is repeatedly pimp slapped.
		// "Pimp Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is repeatedly pimp slapped.
		"Pimp Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Pimp Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The amount of pimp slaps the Super Tank can give to survivors.
			// Minimum: 1
			// Maximum: 99999
			"Pimp Amount"					"5"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Pimp Chance"					"4"

			// The Super Tank's pimp slaps do this much damage.
			// Minimum: 1
			// Maximum: 99999
			"Pimp Damage"					"1"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Pimp Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Pimp Range"					"500.0"
		}
		// The Super Tank pukes on survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the Tank pukes on the survivor.
		// "Puke Hit" - When a survivor is hit by a Tank's claw or rock, the Tank pukes on the survivor.
		"Puke Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Puke Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Puke Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Puke Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Puke Range"					"500.0"
		}
		// The Super Tank gains speed when on fire.
		"Pyro Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank's speed boost value when on fire.
			// Note: This is a speed boost, not the overall speed. (Current speed + Pyro boost)
			// Minimum: 0.1
			// Maximum: 3.0
			"Pyro Boost"					"1.0"
		}
		// The Super Tank regenerates health.
		"Regenerate Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank regenerates this much health each time.
			// Minimum: 1
			// Maximum: 65535
			"Regenerate Health"				"1"

			// The Super Tank regenerates health every time this many seconds passes.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Regenerate Interval"			"1.0"
		}
		// The Super Tank forces survivors to restart at the beginning of the map with a new loadout.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor respawns at the start of the map or near a teammate.
		// "Restart Hit" - When a survivor is hit by a Tank's claw or rock, the survivor respawns at the start of the map or near a teammate.
		"Restart Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Restart Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Restart Chance"				"4"

			// Enable the Super Tank's claw/rock attack.
			// 0: OFF
			// 1: ON
			"Restart Hit"					"0"

			// The Super Tank makes survivors restart with this loadout.
			// Item limit: 5
			// Character limit for each item: 64
			"Restart Loadout"				"smg,pistol,pain_pills"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Restart Range"					"500.0"
		}
		// The Super Tank creates rock showers.
		"Rock Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Rock Chance"					"4"

			// The Super Tank's rocks do this much damage.
			// Minimum: 1
			// Maximum: 99999
			"Rock Damage"					"5"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Rock Duration"					"5.0"

			// The radius of the Super Tank's rock shower.
			// 1st number = Minimum radius
			// Minimum: -5.0
			// Maximum: 0.0
			// 2nd number = Maximum radius
			// Minimum: 0.0
			// Maximum: 5.0
			"Rock Radius"					"-1.25,1.25"
		}
		// The Super Tank sends survivors into space.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is sent into space.
		// "Rocket Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is sent into space.
		"Rocket Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Rocket Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Rocket Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// 0: OFF
			// 1: ON
			"Rocket Hit"					"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Rocket Range"					"500.0"
		}
		// The Super Tank shakes the survivors' screens.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor's screen is shaken.
		// "Shake Hit" - When a survivor is hit by a Tank's claw or rock, the survivor's screen is shaken.
		"Shake Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Shake Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Shake Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Shake Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Shake Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Shake Range"					"500.0"
		}
		// The Super Tank protects itself with a shield and traps survivors inside their own shields.
		"Shield Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// This is the Super Tank's shield's color.
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			"Shield Color"					"255,255,255"

			// The Super Tank's shield reactivates after this many seconds passes.
			// Minimum: 1.0
			// Maximum: 99999.0
			"Shield Delay"					"5.0"
		}
		// The Super Tank shoves survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is shoved repeatedly.
		// "Shove Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is shoved repeatedly.
		"Shove Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Shove Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Shove Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Shove Duration"				"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Shove Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Shove Range"					"500.0"
		}
		// The Super Tank smites survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is smitten.
		// "Smite Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is smitten.
		"Smite Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Smite Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Smite Chance"					"4"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Smite Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Smite Range"					"500.0"
		}
		// The Super Tank spams rocks at survivors.
		"Spam Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Spam Chance"					"4"

			// The Super Tank's rocks do this much damage.
			// Minimum: 1
			// Maximum: 99999
			"Spam Damage"					"5"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Spam Duration"					"5.0"
		}
		// The Super Tank slows survivors down.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor is slowed down.
		// "Stun Hit" - When a survivor is hit by a Tank's claw or rock, the survivor is slowed down.
		"Stun Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Stun Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Stun Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Stun Duration"					"5.0"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Stun Hit"						"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Stun Range"					"500.0"

			// The Super Tank sets the survivors' run speed to this value.
			// Minimum: 0.1
			// Maximum: 0.99
			"Stun Speed"					"0.25"
		}
		// The Super Tank throws things.
		"Throw Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON, the Super Tank throws cars.
			// 2: ON, the Super Tank throws special infected.
			// 3: ON, the Super Tank throws itself.
			"Ability Enabled"				"0"

			// The Super Tank can throw these cars.
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chance of being chosen.
			// Character limit: 6
			// 1: Small car with a big hatchback.
			// 2: Car that looks like a Chevrolet Impala SS.
			// 3: Car that looks like a Sixth Generation Chevrolet Impala.
			"Car Options"					"123"

			// The Super Tank can throw these special infected.
			// Combine numbers in any order for different results.
			// Repeat the same number to increase its chance of being chosen.
			// Character limit: 14
			// 1: Smoker
			// 2: Boomer
			// 3: Hunter
			// 4: Spitter (Switches to Boomer in L4D1.)
			// 5: Jockey (Switches to Hunter in L4D1.)
			// 6: Charger (Switches to Smoker in L4D1.)
			// 7: Tank
			"Infected Options"				"1234567"
		}
		// The Super Tank gains health from hurting survivors.
		// "Ability Enabled" - When a survivor is within range of the Tank, the Tank gains health.
		// "Vampire Hit" - When a survivor is hit by a Tank's claw or rock, the Tank gains health.
		"Vampire Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Vampire Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Vampire Chance"				"4"

			// The Super Tank receives this much health from survivors.
			// Note: Tank's health limit on any difficulty is 62,400.
			// Minimum: 0
			// Maximum: 65535
			"Vampire Health"				"100"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Vampire Hit"					"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Vampire Range"					"500.0"
		}
		// The Super Tank changes the survivors' field of views.
		// "Ability Enabled" - When a survivor is within range of the Tank, the survivor's vision changes.
		// "Vision Hit" - When a survivor is hit by a Tank's claw or rock, the survivor's vision changes.
		"Vision Ability"
		{
			// Enable this ability.
			// Note: This setting does not affect the "Vision Hit" setting.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank has 1 out of this many chances to trigger the ability.
			// Minimum: 1 (Greatest chance)
			// Maximum: 99999 (Less chance)
			"Vision Chance"					"4"

			// The Super Tank's ability effects last this long.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Vision Duration"				"5.0"

			// The Super Tank sets survivors' fields of view to this value.
			// Minimum: 1
			// Maximum: 160
			"Vision FOV"					"160"

			// Enable the Super Tank's claw/rock attack.
			// Note: This setting does not need "Ability Enabled" set to 1.
			// 0: OFF
			// 1: ON
			"Vision Hit"					"0"

			// The distance between a survivor and the Super Tank to trigger the ability.
			// Minimum: 1.0 (Closest)
			// Maximum: 99999.0 (Farthest)
			"Vision Range"					"500.0"
		}
		// The Super Tank warps to survivors.
		"Warp Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank warps to a random survivor every time this many seconds passes.
			// Minimum: 0.1
			// Maximum: 99999.0
			"Warp Interval"					"5.0"
		}
		// The Super Tank spawns Witch minions.
		"Witch Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank spawns this many Witches at once.
			// Minimum: 1
			// Maximum: 25
			"Witch Amount"					"3"

			// The Super Tank's Witch minion causes this much damage per hit.
			// Minimum: 1.0
			// Maximum: 99999.0
			"Witch Minion Damage"			"10.0"
		}
		// The Super Tank spawns common infected.
		"Zombie Ability"
		{
			// Enable this ability.
			// 0: OFF
			// 1: ON
			"Ability Enabled"				"0"

			// The Super Tank spawns this many common infected at once.
			// Minimum: 1
			// Maximum: 100
			"Zombie Amount"					"10"
		}
	}
	// Create your own Super Tanks below.
	"Tank 1"
	{
	}
}
```

### Custom Configuration Files
Super Tanks++ has features that allow for creating and executing custom configuration files.

By default, Super Tanks++ can create and execute the following types of configurations:
1. Difficulty - Files are created/executed based on the current game difficulty. (Example: If the current z_difficulty is set to Impossible (Expert mode), then "impossible.cfg" is executed (or created if it doesn't exist already).
2. Map - Files are created/executed based on the current map. (Example: If the current map is c1m1_hotel, then "c1m1_hotel.cfg" is executed (or created if it doesn't exist already).
3. Game mode - Files are created/executed based on the current game mode. (Example: If the current game mode is Versus, then "versus.cfg" is executed (or created if it doesn't exist already).
4. Daily - Files are created/executed based on the current day. (Example: If the current day is Friday, then "friday.cfg" is executed (or created if it doesn't exist already).
5. Player count - Files are created/executed based on the current number of human players. (Example: If the current number is 8, then "8.cfg" is executed (or created if it doesn't exist already).

#### Features
1. Create custom config files (can be based on difficulty, map, game mode, day, player count, or custom name).
2. Execute custom config files (can be based on difficulty, map, game mode, day, player count, or custom name).
3. Automatically generate config files for all difficulties specified by z_difficulty.
4. Automatically generate config files for all maps installed on the server.
5. Automatically generate config files for all game modes specified by sv_gametypes and mp_gamemode.
6. Automatically generate config files for all days.
7. Automatically generate config files for up to 66 players.

## Questions You May Have
> If you have any questions that aren't addressed below, feel free to message me or post on this [thread](https://forums.alliedmods.net/showthread.php?t=302140).

### Main Features
1. How do I enable/disable the plugin in certain game modes?

You have 2 options:

- Enable/disable in certain game mode types.
- Enable/disable in specific game modes.

For option 1:

You must add numbers up together in the "Game Mode Types" KeyValues.

For option 2:

You must specify the game modes in the "Enabled Game Modes" and "Disabled Game Modes" KeyValues.

Here are some scenarios and their outcomes:

- Scenario 1
```
"Game Mode Types" "0" // The plugin is enabled in all game mode types.
"Enabled Game Modes" "" // The plugin is enabled in all game modes.
"Disabled Game Modes" "coop" // The plugin is disabled in "coop" mode.

Outcome: The plugin works in every game mode except "coop" mode.
```
- Scenario 2
```
"Game Mode Types" "1" // The plugin is enabled in every Campaign-based game mode.
"Enabled Game Modes" "coop" // The plugin is enabled in only "coop" mode.
"Disabled Game Modes" "" // The plugin is not disabled in any game modes.

Outcome: The plugin works only in "coop" mode.
```
- Scenario 3
```
"Game Mode Types" "5" // The plugin is enabled in every Campaign-based and Survival-based game mode.
"Enabled Game Modes" "coop,versus" // The plugin is enabled in only "coop" and "versus" mode.
"Disabled Game Modes" "coop" // The plugin is disabled in "coop" mode.

Outcome: The plugin works in every Campaign-based and Survival-based game mode except "coop" mode.
```

2. How come some Super Tanks aren't showing up?

It may be due to one or more of the following:

- The "Tank Enabled" KeyValue for that Super Tank may be set to 0 or doesn't exists at all which defaults to 0.
- You have created a new Super Tank and didn't raise the value of the "Maximum Types" KeyValue.
- You have misspelled one of the KeyValues settings.
- You are still using the "Tank Character" KeyValue which is no longer used since v8.16.
- You didn't set up the Super Tank properly.
- You are missing quotation marks.
- You have more than 1000 Super Tanks in your config file.

3. How do I kill the Tanks depending on what abilities they have?

The following abilities require different strategies:

- Absorb Ability: The Super Tank takes way less damage.
- God Ability: The Super Tank will have god mode temporarily and will not take any damage at all until the effect ends.
- Bullet Immunity: Forget your guns. Just spam your grenade launcher at it, slash it with an axe or crowbar, or burn it to death.
- Explosive Immunity: Forget explosives and just focus on gunfire, melee weapons, and molotovs/gascans.
- Fire Immunity: No more barbecued Tanks.
- Melee Immunity: No more Gordon Freeman players (immune to melee weapons including crowbar).
- Nullify Hit: The Super Tank can mark players as useless, which means as long as that player is nullified, they will not do any damage.
- Shield Ability: Wait for the Tank to throw propane tanks at you and then throw it back at the Tank. Then shoot the propane tank to deactivate the Tank's shield.

4. How do I make the plugin work on only finale maps?

Set the value of the "Finales Only" KeyValue to 1.

5. How can I change the amount of Tanks that spawn on each finale wave?

Here's an example:

```
"Tank Waves" "2,3,4" // Spawn 2 Tanks on the 1st wave, 3 Tanks on the 2nd wave, and 4 Tanks on the 3rd wave.
```

6. How can I decide whether to display each Tank's health?

Set the value in the "Display Health" KeyValue.

7. How do I give each Tank more health?

Set the value in the "Extra Health" KeyValue.

Example:

```
"Extra Health" "5000" // Add 5000 to the Super Tank's health.
```

8. How do I adjust each Tank's run speed?

Set the value in the "Run Speed" KeyValue.

Example:

```
"Run Speed" "3.0" // Add 2.0 to the Super Tank's run speed. Default run speed is 1.0.
```

9. How can I give each Tank bullet immunity?

Set the value of the "Bullet Immunity" KeyValue to 1.

10. How can I give each Tank explosive immunity?

Set the value of the "Explosive Immunity" KeyValue to 1.

11. How can I give each Tank fire immunity?

Set the value of the "Fire Immunity" KeyValue to 1.

12. How can I give each Tank melee immunity?

Set the value of the "Melee Immunity" KeyValue to 1.

13. How can I delay the throw interval of each Tank?

Set the value in the "Throw Interval" KeyValue.

Example:

```
"Throw Interval" "8.0" // Add 3.0 to the Super Tank's throw interval. Default throw interval is 5.0.
```

14. Why do some Tanks spawn with different props?

Each prop has 1 out of X chances to appear on Super Tanks when they spawn. Configure the chances for each prop in the "Props Chance" KeyValue.

15. Why are the Tanks spawning with more than the extra health given to them?

Since v8.10, extra health given to Tanks is now multiplied by the number of alive non-idle human survivors present when the Tank spawns.

16. How do I add more Super Tanks?

- Add a new entry in the config file.
- Raise the value of the "Maximum Types" KeyValue.

Example:

```
"Super Tanks++"
{
	"General"
	{
		"Maximum Types"		"69" // The plugin will check for 69 entries when loading the config file.
	}
	"Tank 69"
	{
		"Tank Enabled"		"1" // Tank 69 is enabled and can be chosen.
	}
}
```

17. How do I filter out certain Super Tanks that I made without deleting them?

Enable/disable them with the "Tank Enabled" KeyValue.

Example:

```
"Super Tanks++"
{
	"Tank 1"
	{
		"Tank Enabled"		"1" // Tank 1 can be chosen.
	}
	"Tank 2"
	{
		"Tank Enabled"		"0" // Tank 2 cannot be chosen.
	}
	"Tank 3"
	{
		"Tank Enabled"		"0" // Tank 3 cannot be chosen.
	}
	"Tank 4"
	{
		"Tank Enabled"		"1" // Tank 4 can be chosen.
	}
}
```

18. Can I create temporary Tanks without removing or replacing them?

Yes, you can do that with custom configs.

Example:

```
// Settings for cfg/sourcemod/super_tanks++/super_tanks++.cfg
"Super Tanks++"
{
	"General"
	{
		"Enable Custom Configs"			"1" // Enable custom configs
		"Execute Config Types"			"1" // 1: Difficulty configs (easy, normal, hard, impossible)
	}
	"Tank 69"
	{
		"Tank Name"				"Psyk0tik Tank"
		"Tank Enabled"			"1"
		"Skin-Glow Colors"		"0,170,255,255|0,170,255"
		"Extra Health"			"250"
		"Fire Immunity"			"1"
	}
}

// Settings for cfg/sourcemod/super_tanks++/difficulty_configs/impossible.cfg
"Super Tanks++"
{
	"Tank 69"
	{
		"Tank Name"				"Idiot Tank"
		"Tank Enabled"			"1"
		"Skin-Glow Colors"		"1,1,1,255|1,1,1"
		"Extra Health"			"1"
	}
}

Output: When the current difficulty is Expert mode (impossible), the Idiot Tank will spawn instead of Psyk0tik Tank as long as custom configs is being used.

These are basically temporary Tanks that you guys can create for certain situations, like if there's 5 players on the server, the map is c1m1_hotel, or even if the day is Thursday, etc.
```

19. How can I move the Super Tanks++ category around on the admin menu?

- You have to open up addons/sourcemod/configs/adminmenu_sorting.txt.
- Enter the "SuperTanks++" category.

Example:

```
"Menu"
{
	"PlayerCommands"
	{
		"item"		"sm_respawn"
		"item"		"sm_slay"
		"item"		"sm_slap"
		"item"		"sm_kick"
		"item"		"sm_ban"
		"item"		"sm_bandisconnected"
		"item"		"sm_gag"
		"item"		"sm_burn"		
		"item"		"sm_beacon"
		"item"		"sm_freeze"
		"item"		"sm_timebomb"
		"item"		"sm_firebomb"
		"item"		"sm_freezebomb"
	}

	"ServerCommands"
	{
		"item"		"sm_map"
		"item"		"sm_execcfg"
		"item"		"sm_reloadadmins"
	}

	"VotingCommands"
	{
		"item"		"sm_cancelvote"
		"item"		"sm_votemap"
		"item"		"sm_votekick"
		"item"		"sm_voteban"
	}

	"SuperTanks++"
	{
		"item"		"sm_tank"
	}

	"A Menu"
	{
		"item"		"sm_test"
	}

	"Zombie Spawner"
	{
		"item"		"sm_spawn"
	}
}
```

20. Are there any developer/tester features available in the plugin?

Yes, there are target filters for each special infected and the sm_tank command that allows developers/testers to spawn each Super Tank.

List of target filters:

```
@smokers
@boomers
@hunters
@spitters
@jockeys
@chargers
@witches
@tanks
```

Command usage:

```
sm_tank <type 1-*> *The maximum value is determined by the value of the "Maximum Types" KeyValue. (The highest value you can set is 1000 though.)
```

### Configuration
1. How do I enable the custom configurations features?

Set the value of the "Enable Custom Configs" KeyValue to 1.

2. How do I tell the plugin to only create certain custom config files?

Set the values in the "Create Config Types" KeyValue.

Examples:
```
"Create Config Types" "123" // Creates the folders and config files for each difficulty, map, and game mode.
"Create Config Types" "4" // Creates the folder and config files for each day.
"Create Config Types" "12345" // Creates the folders and config files for each difficulty, map, game mode, day, and player count.
```

3. How do I tell the plugin to only execute certain custom config files?

Set the values in the "Execute Config Types" KeyValue.

Examples:
```
"Execute Config Types" "123" // Executes the config file for the current difficulty, map, and game mode.
"Execute Config Types" "4" // Executes the config file for the current day.
"Execute Config Types" "12345" // Executes the config file for the current difficulty, map, game mode, day, and player count.
```

## Credits
**NgBUCKWANGS** - For the mapname.cfg code in his [ABM](https://forums.alliedmods.net/showthread.php?t=291562) plugin.

**Spirit_12** - For the L4D signatures for the gamedata file.

**honorcode** - For the [[L4D & L4D2] New Custom Commands](https://forums.alliedmods.net/showthread.php?p=1251446) plugin.

**panxiaohai** - For the [We Can Not Survive Alone](https://forums.alliedmods.net/showthread.php?t=167389) plugin.

**strontiumdog** - For the [Evil Admin: Mirror Damage](https://forums.alliedmods.net/showthread.php?p=702913), [Evil Admin: Pimp Slap](https://forums.alliedmods.net/showthread.php?p=702914), [Evil Admin: Rocket](https://forums.alliedmods.net/showthread.php?t=79617), and [Evil Admin: Vision](https://forums.alliedmods.net/showthread.php?p=702918).

**Marcus101RR** - For the code to set a player's weapon's ammo.

**AtomicStryker** - For the code and gamedata signatures to respawn survivors.

**Farbror Godis** - For the [Curse](https://forums.alliedmods.net/showthread.php?p=2402076) plugin.

**ztar** - For the [Last Boss](https://forums.alliedmods.net/showthread.php?t=129013?t=129013) plugin.

**IxAvnoMonvAxI** - For the [Last Boss Extended](https://forums.alliedmods.net/showpost.php?p=1463486&postcount=2) plugin.

**Uncle Jessie** - For the Tremor Tank in his [Last Boss Extended revision](https://forums.alliedmods.net/showpost.php?p=2570108&postcount=73).

**pRED** - For the [SM Super Commands](https://forums.alliedmods.net/showthread.php?p=498802) plugin.

**sheo** - For the [Fix Frozen Tanks](https://forums.alliedmods.net/showthread.php?p=2133193) plugin.

**Silvers (Silvershot)** - For the code that allows users to enable/disable the plugin in certain game modes, help with gamedata signatures, the code to prevent Tanks from damaging themselves and other infected with their own abilities, and help with optimizing/fixing various parts of the code.

**Milo|** - For the code that automatically generates config files for each day and each map installed on a server.

**hmmmmm** - For showing me how to pick a random character out of a dynamic string.

**Mi.Cura** - For reporting issues, giving me ideas, and overall support.

**emsit** - For reporting issues and helping with parts of the code.

**ReCreator** - For reporting issues.

**AngelAce113** - For the default colors, testing each Tank type, giving me ideas, and overall support.

**Sipow** - For the default colors and overall support.

**SourceMod Team** - For the beacon, blind, drug, and ice source codes.

# Contact Me
If you wish to contact me for any questions, concerns, suggestions, or criticism, I can be found here:
- [AlliedModders Forum](https://forums.alliedmods.net/member.php?u=181166)
- [Steam](https://steamcommunity.com/profiles/76561198056665335)

# 3rd-Party Revisions Notice
If you would like to share your own revisions of this plugin, please rename the files! I do not want to create confusion for end-users and it will avoid conflict and negative feedback on the official versions of my work. If you choose to keep the same file names for your revisions, it will cause users to assume that the official versions are the source of any problems your revisions may have. This is to protect you (the reviser) and me (the developer)! Thank you!

# Donate
- [Donate to SourceMod](https://www.sourcemod.net/donate.php)

Thank you very much! :)