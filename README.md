# Super Tanks++
Super Tanks++ takes the original [Super Tanks](https://forums.alliedmods.net/showthread.php?t=165858) by [Machine](https://forums.alliedmods.net/member.php?u=74752) to the next level by enabling full customization of Super Tanks to make gameplay more interesting.

## License
Super Tanks++: a L4D/L4D2 SourceMod Plugin
Copyright (C) 2017 Alfred "Crasher_3637/Psyk0tik" Llagas

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

## About
Super Tanks++ makes fighting Tanks great again!

> Super Tanks++ will enhance and intensify Tank fights by making each Tank that spawns unique and different in its own way.

### What makes Super Tanks++ viable in Left 4 Dead/Left 4 Dead 2?
Super Tanks++ enhances the experience and fun that players get from Tank fights by 1000. This plugin gives server owners an arsenal of Super Tanks to test players' skills and create a unique experience in every Tank fight.

### Requirements
Super Tanks++ was developed against SourceMod 1.8+.

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
3. Fully customizable Super Tank types.

## KeyValues Settings
```
"Super Tanks++"
{
	// These are the general settings.
	// Note: The following settings will not work in custom config files:
	// "Enabled Game Modes"
	// "Disabled Game Modes"
	// "Enable Custom Configs"
	// "Create Config Types"
	// "Execute Config Types"
	"General"
	{
		// Enable Super Tanks++.
		// 0: OFF
		// 1: ON
		"Plugin Enabled"				"1"

		// Enable Super Tanks++ in these game modes.
		// Separate game modes with commas.
		// Game mode limit: 64
		// Character limit for each game mode: 32
		// Empty: All
		// Not empty: Enabled only in these game modes.
		"Enabled Game Modes"			"coop"

		// Disable Super Tanks++ in these game modes.
		// Separate game modes with commas.
		// Game mode limit: 64
		// Character limit for each game mode: 32
		// Empty: None
		// Not empty: Disabled only in these game modes.
		"Disabled Game Modes"			"mutation1"

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
		// 0: OFF
		// 1: ON
		"Human Super Tanks"				"1"

		// Maximum types of Super Tanks allowed.
		// Minimum: 1
		// Maximum: 250
		"Maximum Types"					"60"

		// Multiply the Super Tank's health.
		// 0: No changes to health.
		// 1: Multiply original health only.
		// 2: Multiply extra health only.
		// 3: Multiply both.
		"Multiply Health"				"0"

		// Spawn these Super Tank types.
		// Combine letters and numbers in any order for different results.
		// Repeat the same letter or number to increase its chance of being chosen.
		// Character limit: 250
		// Valid characters: Any number, letter, and symbol except for these: ' and "
		"Tank Types"					"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwx"

		// Amount of Tanks to spawn for each finale wave.
		// Separate waves with commas.
		// Wave limit: 3
		// Character limit for each wave: 3
		// 1st number = 1st wave
		// 2nd number = 2nd wave
		// 3rd number = 3rd wave
		"Tank Waves"					"2,3,4"
	}
	// This is just an example that contains information for each setting or ability.
	// This section is not used by the plugin in any way at all.
	// Feel free to add your own notes here if you wish.
	"Example"
	{
		// Name of the Super Tank.
		// Character limit: 32
		"Tank Name"						"Tank 1"

		// Character assigned to the Super Tank.
		// Valid characters: Any number, letter, and symbol except for these: ' and "
		// Character limit: 1
		"Tank Character"				"0"

		// These are the Super Tank's skin and glow outline colors.
		// Separate colors with "|".
		// Separate RGBAs with commas.
		// 1st set = skin color (RGBA)
		// 2nd set = glow color (RGB)
		"Skin-Glow Colors"				"255,255,255,255|255,255,255"

		// Props that the Super Tank can spawn with.
		// Combine numbers in any order for different results.
		// Character limit: 4
		// 1: attach lights only.
		// 2: attach oxygen tanks only.
		// 3: attach flames to oxygen tanks.
		// 4: attach rocks only.
		// 5: attach tires only.
		"Props Attached"				"12345"

		// Each prop has 1 of this many chances to appear when the Super Tank appears.
		// Separate chances with commas.
		// Chances limit: 4
		// Character limit for each chance: 3
		// 1st number = Chance for lights to appear.
		// 2nd number = Chance for oxygen tanks to appear.
		// 3rd number = Chance for oxygen tank flames to appear.
		// 4th number = Chance for rocks to appear.
		// 5th number = Chance for tires to appear.
		"Props Chance"					"3,3,3,3,3"

		// The Super Tank's prop colors.
		// Separate colors with "|".
		// Separate RGBAs with commas.
		// 1st set = lights color (RGBA)
		// 2nd set = oxygen tanks color (RGBA)
		// 3rd set = oxygen tank flames color (RGBA)
		// 4th set = rocks color (RGBA)
		// 5th set = tires color (RGBA)
		"Props Colors"					"255,255,255,255|255,255,255,255|255,255,255,125|255,255,255,255|255,255,255,255"

		// The Super Tank will have a glow outline.
		// Only available in Left 4 Dead 2.
		// 0: OFF
		// 1: ON
		"Glow Effect"					"1"

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
		// 7: Spit Puddle (Only available in Left 4 Dead 2.)
		"Particle Effects"				"1234567"

		// The Super Tank absorbs most of the damage it receives.
		// 0: OFF
		// 1: ON
		"Absorb Ability"				"0"

		// The Super Tank has 1 out of this many chances to spawn acid puddles underneath survivors.
		// Only available in Left 4 Dead 2.
		// Minimum: 1
		// Maximum: 99999
		"Acid Chance"					"4"

		// The Super Tank can spawn acid puddles underneath survivors.
		// Only available in Left 4 Dead 2.
		// 0: OFF
		// 1: ON
		"Acid Claw-Rock"				"0"

		// The Super Tank's rock spawns acid puddles when it breaks.
		// Only available in Left 4 Dead 2.
		// 0: OFF
		// 1: ON
		"Acid Rock Break"				"0"

		// The Super Tank has 1 out of this many chances to take away survivors' ammunition.
		// Minimum: 1
		// Maximum: 99999
		"Ammo Chance"					"4"

		// The Super Tank sets survivors' ammunition to this amount.
		// Minimum: 0
		// Maximum: 25
		"Ammo Count"					"0"

		// The Super Tank can take away survivors' ammunition.
		// 0: OFF
		// 1: ON
		"Ammo Claw-Rock"				"0"

		// The Super Tank has 1 out of this many chances to blind survivors.
		// Minimum: 1
		// Maximum: 99999
		"Blind Chance"					"4"

		// The Super Tank's blinding effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Blind Duration"				"5.0"

		// The Super Tank can blind survivors.
		// 0: OFF
		// 1: ON
		"Blind Claw-Rock"				"0"

		// The intensity of the Super Tank's blind effect.
		// Minimum: 0 (No effect)
		// Maximum: 255 (Fully blind)
		"Blind Intensity"				"255"

		// The Super Tank has 1 out of this many chances to start explosions.
		// Minimum: 1
		// Maximum: 99999
		"Bomb Chance"					"4"

		// The Super Tank can start explosions.
		// 0: OFF
		// 1: ON
		"Bomb Claw-Rock"				"0"

		// The Super Tank's rock explodes when it breaks.
		// 0: OFF
		// 1: ON
		"Bomb Rock Break"				"0"

		// The Super Tank has 1 out of this many chances to bury survivors.
		// Minimum: 1
		// Maximum: 99999
		"Bury Chance"					"4"

		// The Super Tank's buries lasts this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Bury Duration"					"5.0"

		// The Super Tank buries survivors this deep into the ground.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Bury Height"					"50.0"

		// The Super Tank can bury survivors.
		// 0: OFF
		// 1: ON
		"Bury Claw-Rock"				"0"

		// The Super Tank can throw cars at survivors.
		// 0: OFF
		// 1: ON
		"Car Throw Ability"				"0"

		// The Super Tank can spawn common infected.
		// 0: OFF
		// 1: ON
		"Common Ability"				"0"

		// The Super Tank spawns this many common infected at once.
		// Minimum: 1
		// Maximum: 100
		"Common Amount"					"10"

		// The Super Tank has 1 out of this many chances to drug survivors.
		// Minimum: 1
		// Maximum: 99999
		"Drug Chance"					"4"

		// The Super Tank's drug effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Drug Duration"					"5.0"

		// The Super Tank can drug survivors.
		// 0: OFF
		// 1: ON
		"Drug Claw-Rock"				"0"

		// Extra health given to the Super Tank.
		// Note: Tank's health limit on any difficulty is 62,400.
		// Note: Depending on the setting for "Multiply Health," the Super Tank's health will be multiplied based on player count.
		// Note: Health changes only occur when there are at least 2 alive non-idle human survivors.
		// Minimum: 0
		// Maximum: 62400
		"Extra Health"					"0"

		// The Super Tank has 1 out of this many chances to start fires.
		// Minimum: 1
		// Maximum: 99999
		"Fire Chance"					"4"

		// The Super Tank can start fires.
		// 0: OFF
		// 1: ON
		"Fire Claw-Rock"				"0"

		// Give the Super Tank fire immunity.
		// 0: OFF
		// 1: ON
		"Fire Immunity"					"0"

		// The Super Tank's rock starts fires when it breaks.
		// 0: OFF
		// 1: ON
		"Fire Rock Break"				"0"

		// The Super Tank can run really fast.
		// 0: OFF
		// 1: ON
		"Flash Ability"					"0"

		// The Super Tank has 1 out of this many chances to run really fast.
		// Minimum: 1
		// Maximum: 99999
		"Flash Chance"					"4"

		// The Super Tank's special speed.
		// Minimum: 3.0
		// Maximum: 8.0
		"Flash Speed"					"5.0"

		// The Super Tank has 1 out of this many chances to fling survivors into the air.
		// Only available in Left 4 Dead 2.
		// Minimum: 1
		// Maximum: 99999
		"Fling Chance"					"4"

		// The Super Tank can fling survivors into the air.
		// Only available in Left 4 Dead 2.
		// 0: OFF
		// 1: ON
		"Fling Claw-Rock"				"0"

		// The Super Tank can cloak itself and other infected.
		// 0: OFF
		// 1: ON
		"Ghost Ability"					"0"

		// The Super Tank has 1 out of this many chances to disarm survivors.
		// Minimum: 1
		// Maximum: 99999
		"Ghost Chance"					"4"

		// The limit of the Super Tank's ghost fade effect.
		// Minimum: 0 (Fully faded)
		// Maximum: 255 (No effect)
		"Ghost Fade Limit"				"0"

		// The Super Tank can disarm survivors.
		// 0: OFF
		// 1: ON
		"Ghost Claw-Rock"				"0"

		// The Super Tank disarms the following weapon slots.
		// Combine numbers in any order for different results.
		// Character limit: 5
		// 1: 1st slot only.
		// 2: 2nd slot only.
		// 3: 3rd slot only.
		// 4: 4th slot only.
		// 5: 5th slot only.
		"Ghost Weapon Slots"			"12345"

		// The Super Tank can pull in or push away survivors and infected.
		// 0: OFF
		// 1: ON
		"Gravity Ability"				"0"

		// The Super Tank has 1 out of this many chances to lower survivors' gravity.
		// Minimum: 1
		// Maximum: 99999
		"Gravity Chance"				"4"

		// The Super Tank's gravity effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Gravity Duration"				"5.0"

		// The Super Tank's gravity force.
		// Positive numbers = Push back
		// Negative numbers = Pull back
		// Minimum: -100.0
		// Maximum: 100.0
		"Gravity Force"					"-50.0"

		// The Super Tank can lower survivors' gravity.
		// 0: OFF
		// 1: ON
		"Gravity Claw-Rock"				"0"

		// The Super Tank sets the survivors' gravity to this value.
		// Minimum: 0.1
		// Maximum: 0.99
		"Gravity Value"					"0.3"

		// The Super Tank can receive health from nearby infected.
		// 0: OFF
		// 1: ON
		"Heal Ability"					"0"

		// The Super Tank has 1 out of this many chances to set survivors to black and white with temporary health.
		// Minimum: 1
		// Maximum: 99999
		"Heal Chance"					"4"

		// The Super Tank receives this much health from nearby common infected.
		// Minimum: 0
		// Maximum: 62400
		"Health From Commons"			"50"

		// The Super Tank can set survivors to black and white with temporary health.
		// 0: OFF
		// 1: ON
		"Heal Claw-Rock"				"0"

		// The Super Tank receives health from nearby infected every time this many seconds passes.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Heal Interval"					"5.0"

		// The Super Tank receives this much health from other nearby special infected.
		// Minimum: 0
		// Maximum: 62400
		"Health From Specials"			"100"

		// The Super Tank receives this much health from other nearby Tanks.
		// Minimum: 0
		// Maximum: 62400
		"Health From Tanks"				"500"

		// The Super Tank can constantly hurt survivors.
		// 0: OFF
		// 1: ON
		"Hurt Ability"					"0"

		// The Super Tank has 1 out of this many chances to constantly hurt survivors.
		// Minimum: 1
		// Maximum: 99999
		"Hurt Chance"					"4"

		// The Super Tank's constant pain infliction does this much damage.
		// Minimum: 1
		// Maximum: 99999
		"Hurt Damage"					"1"

		// The Super Tank's painful effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Hurt Duration"					"5.0"

		// The Super Tank has 1 out of this many chances to hypnotize survivors.
		// Minimum: 1
		// Maximum: 99999
		"Hypno Chance"					"4"

		// The Super Tank's hypnosis effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Hypno Duration"				"5.0"

		// The Super Tank can hypnotize survivors.
		// 0: OFF
		// 1: ON
		"Hypno Claw-Rock"				"0"

		// The mode of the Super Tank's hypno ability.
		// 0: Hypnotized survivors hurt themselves.
		// 1: Hypnotized survivors can hurt their teammates.
		"Hypno Mode"					"0"

		// The Super Tank has 1 out of this many chances to freeze survivors.
		// Minimum: 1
		// Maximum: 99999
		"Ice Chance"					"4"

		// The Super Tank can freeze survivors.
		// 0: OFF
		// 1: ON
		"Ice Claw-Rock"					"0"

		// The Super Tank has 1 out of this many chances to make survivors go idle.
		// Minimum: 1
		// Maximum: 99999
		"Idle Chance"					"4"

		// The Super Tank can make survivors go idle.
		// 0: OFF
		// 1: ON
		"Idle Claw-Rock"				"0"

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

		// The Super Tank can throw special infected.
		// 0: OFF
		// 1: ON
		"Infected Throw Ability"		"0"

		// The Super Tank has 1 out of this many chances to invert survivors' movement keys.
		// Minimum: 1
		// Maximum: 99999
		"Invert Chance"					"4"

		// The Super Tank's inverted effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Invert Duration"				"5.0"

		// The Super Tank can invert survivors' movement keys.
		// 0: OFF
		// 1: ON
		"Invert Claw-Rock"				"0"

		// The Super Tank can jump high into the air.
		// 0: OFF
		// 1: ON
		"Jump Ability"					"0"

		// The Super Tank has 1 out of this many chances to jump high into the air.
		// Minimum: 1
		// Maximum: 99999
		"Jump Chance"					"4"

		// The Super Tank can start meteor showers.
		// 0: OFF
		// 1: ON
		"Meteor Ability"				"0"

		// The Super Tank has 1 out of this many chances to start meteor showers.
		// Minimum: 1
		// Maximum: 99999
		"Meteor Chance"					"4"

		// The Super Tank's meteorites do this much damage.
		// Minimum: 1.0
		// Maximum: 99999.0
		"Meteor Damage"					"25.0"

		// The Super Tank has 1 out of this many chances to start panic events.
		// Minimum: 1
		// Maximum: 99999
		"Panic Chance"					"4"

		// The Super Tank can start panic events.
		// 0: OFF
		// 1: ON
		"Panic Claw-Rock"				"0"

		// The Super Tank has 1 out of this many chances to puke on survivors.
		// Minimum: 1
		// Maximum: 99999
		"Puke Chance"					"4"

		// The Super Tank can puke on survivors.
		// 0: OFF
		// 1: ON
		"Puke Claw-Rock"				"0"

		// The Super Tank gains a speed boost when on fire.
		// 0: OFF
		// 1: ON
		"Pyro Ability"					"0"

		// The Super Tank's speed boost value when on fire.
		// Note: This is a speed boost, not the overall speed. (Current speed + Pyro boost)
		// Minimum: 0.1
		// Maximum: 3.0
		"Pyro Boost"					"1.0"

		// The Super Tank has 1 out of this many chances to make survivors restart at the spawn area.
		// Minimum: 1
		// Maximum: 99999
		"Restart Chance"				"4"

		// The Super Tank can make survivors restart at the spawn area.
		// 0: OFF
		// 1: ON
		"Restart Claw-Rock"				"0"

		// The Super Tank makes survivors restart with this loadout.
		// Item limit: 5
		// Character limit for each item: 64
		"Restart Loadout"				"smg,pistol,pain_pills"

		// The Super Tank has 1 out of this many chances to send survivors into space.
		// Minimum: 1
		// Maximum: 99999
		"Rocket Chance"					"4"

		// The Super Tank can send survivors into space.
		// 0: OFF
		// 1: ON
		"Rocket Claw-Rock"				"0"

		// Set the Super Tank's run speed.
		// Note: Default run speed is 1.0.
		// Minimum: 0.1
		// Maximum: 3.0
		"Run Speed"						"1.0"

		// The Super Tank has 1 out of this many chances to shake survivors' screens.
		// Minimum: 1
		// Maximum: 99999
		"Shake Chance"					"4"

		// The Super Tank's shake effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Shake Duration"				"5.0"

		// The Super Tank can shake survivors' screens.
		// 0: OFF
		// 1: ON
		"Shake Claw-Rock"				"0"

		// The Super Tank can spawn with a shield.
		// 0: OFF
		// 1: ON
		"Shield Ability"				"0"

		// This is the Super Tank's shield's color.
		// 1st number = Red
		// 2nd number = Green
		// 3rd number = Blue
		"Shield Color"					"255,255,255"

		// The Super Tank's shield reactivates after this many seconds passes.
		// Minimum: 1.0
		// Maximum: 99999.0
		"Shield Delay"					"5.0"

		// The Super Tank has 1 out of this many chances to shove survivors.
		// Minimum: 1
		// Maximum: 99999
		"Shove Chance"					"4"

		// The Super Tank's shove effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Shove Duration"				"5.0"

		// The Super Tank can shove survivors.
		// 0: OFF
		// 1: ON
		"Shove Claw-Rock"				"0"

		// The Super Tank has 1 out of this many chances to instantly kill survivors.
		// Minimum: 1
		// Maximum: 99999
		"Slug Chance"					"4"

		// The Super Tank can instantly kill survivors.
		// 0: OFF
		// 1: ON
		"Slug Claw-Rock"				"0"

		// The Super Tank can spam rocks at survivors.
		// 0: OFF
		// 1: ON
		"Spam Ability"					"0"

		// The Super Tank spams this many rocks at survivors.
		// Minimum: 1
		// Maximum: 100
		"Spam Amount"					"5"

		// The Super Tank's rocks do this much damage.
		// Minimum: 1
		// Maximum: 99999
		"Spam Damage"					"5"

		// The Super Tank spams rocks at survivors every time this many seconds passes.
		// Minimum: 1
		// Maximum: 99999
		"Spam Interval"					"5.0"

		// The Super Tank has 1 out of this many chances to stun survivors.
		// Minimum: 1
		// Maximum: 99999
		"Stun Chance"					"4"

		// The Super Tank's stun effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Stun Duration"					"5.0"

		// The Super Tank can stun survivors.
		// 0: OFF
		// 1: ON
		"Stun Claw-Rock"				"0"

		// The Super Tank sets the survivors' run speed to this amount.
		// Minimum: 0.1
		// Maximum: 0.99
		"Stun Speed"					"0.25"

		// The Super Tank's rock throw interval.
		// Note: Default throw interval is 5.0 seconds.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Throw Interval"				"5.0"

		// The Super Tank has 1 out of this many chances to steal survivors' health.
		// Minimum: 1
		// Maximum: 99999
		"Vampire Chance"				"4"

		// The Super Tank receives this much health from hitting survivors.
		// Note: Tank's health limit on any difficulty is 62,400.
		// Minimum: 0
		// Maximum: 62400
		"Vampire Health"				"100"

		// The Super Tank can steal survivors' health.
		// 0: OFF
		// 1: ON
		"Vampire Claw-Rock"				"0"

		// The Super Tank has 1 out of this many chances to change survivors' fields of view.
		// Minimum: 1
		// Maximum: 99999
		"Vision Chance"					"4"

		// The Super Tank's visual effects last this long.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Vision Duration"				"5.0"

		// The Super Tank sets survivors' fields of view to this amount.
		// Minimum: 1
		// Maximum: 160
		"Vision FOV"					"160"

		// The Super Tank can change survivors' fields of view.
		// 0: OFF
		// 1: ON
		"Vision Claw-Rock"				"0"

		// The Super Tank can warp to survivors.
		// 0: OFF
		// 1: ON
		"Warp Ability"					"0"

		// The Super Tank warps to a random survivor every time this many seconds passes.
		// Minimum: 0.1
		// Maximum: 99999.0
		"Warp Interval"					"5.0"

		// The Super Tank can spawn Witch minions.
		// 0: OFF
		// 1: ON
		"Witch Ability"					"0"

		// The Super Tank can spawn this many Witches at once.
		// Minimum: 1
		// Maximum: 25
		"Witch Amount"					"3"

		// The Super Tank's Witch minion causes this much damage per hit.
		// Minimum: 1.0
		// Maximum: 99999.0
		"Witch Minion Damage"			"10.0"
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

You must specify the game modes in the "Enabled Game Modes" and "Disabled Game Modes" KeyValues.

Here are some scenarios and their outcomes:

- Scenario 1
```
"Enabled Game Modes" "" // The plugin is enabled in all game modes.
"Disabled Game Modes" "coop" // The plugin is disabled in "coop" mode.

Outcome: The plugin works in every game mode except "coop" mode.
```
- Scenario 2
```
"Enabled Game Modes" "coop" // The plugin is enabled in only "coop" mode.
"Disabled Game Modes" "" // The plugin is not disabled in any game modes.

Outcome: The plugin works only in "coop" mode.
```
- Scenario 3
```
"Enabled Game Modes" "coop,versus" // The plugin is enabled in only "coop" and "versus" mode.
"Disabled Game Modes" "coop" // The plugin is disabled in "coop" mode.

Outcome: The plugin works only in "versus" mode.
```

2. How do I make the plugin work on only finale maps?

Set the KeyValue of "Finales Only" to 1.

3. How can I change the amount of Tanks that spawn on each finale wave?

Here's an example:

```
"Tank Waves" "2,3,4" // Spawn 2 Tanks on the 1st wave, 3 Tanks on the 2nd wave, and 4 Tanks on the 3rd wave.
```

4. How can I decide whether to display each Tank's health?

Set the value in the "Display Health" KeyValue.

5. How do I give each Tank more health?

Set the value in the "Extra Health" KeyValue.

Example:

```
"Extra Health" "5000" // Add 5000 to the Super Tank's health.
```

6. How do I adjust each Tank's run speed?

Set the value in the "Run Speed" KeyValue.

Example:

```
"Run Speed" "3.0" // Add 2.0 to the Super Tank's run speed. Default run speed is 1.0.
```

7. How can I give each Tank fire immunity?

Set the value of the "Fire Immunity" KeyValue to 1.

8. How can I delay the throw interval of each Tank?

Set the value in the "Throw Interval" KeyValue.

Example:

```
"Throw Interval" "8.0" // Add 3.0 to the Super Tank's throw interval. Default throw interval is 5.0.
```

9. Why do some Tanks spawn with different props?

Each prop has 1 out of X chances to appear on Super Tanks when they spawn. Configure the chances for each prop in the "Props Chance" KeyValue.

10. Why are the Tanks spawning with more than the extra health given to them?

Since v8.10, extra health given to Tanks is now multiplied by the number of alive non-idle human survivors present when the Tank spawns.

11. How do I filter out certain Super Tanks that I made without deleting them?

Add/remove the character of each Super Tank in the "Tank Types" KeyValue.

Example:

```
"Super Tanks++"
{
	"General"
	{
		"Tank Types"		"ad" // Only pick Super Tanks with either the character "a" or "d".
	}
	"Tank 1"
	{
		"Tank Character"	"a" // Tank 1 can be chosen.
	}
	"Tank 2"
	{
		"Tank Character"	"b" // Tank 2 cannot be chosen.
	}
	"Tank 3"
	{
		"Tank Character"	"c" // Tank 3 cannot be chosen.
	}
	"Tank 4"
	{
		"Tank Character"	"d" // Tank 4 can be chosen.
	}
}
```

12. Are there any developer/tester features available in the plugin?

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
sm_tank <type 1-*> *The maximum value is determined by the value of the "Maximum Types" KeyValue. (The highest value you can set is 250 though.)
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

**strontiumdog** - For the [Evil Admin: Mirror Damage](https://forums.alliedmods.net/showthread.php?p=702913), [Evil Admin: Rocket](https://forums.alliedmods.net/showthread.php?t=79617), and [Evil Admin: Vision](https://forums.alliedmods.net/showthread.php?p=702918).

**Marcus101RR** - For the code to set a player's weapon's ammo.

**AtomicStryker** - For the code and gamedata signatures to respawn survivors.

**Farbror Godis** - For the [Curse](https://forums.alliedmods.net/showthread.php?p=2402076) plugin.

**Uncle Jessie** - For the Tremor Tank in his [Last Boss Extended revision](https://forums.alliedmods.net/showpost.php?p=2570108&postcount=73).

**pRED** - For the [SM Super Commands](https://forums.alliedmods.net/showthread.php?p=498802) plugin.

**Silvers (Silvershot)** - For the code that allows users to enable/disable the plugin in certain game modes, help with gamedata signatures, the code to prevent Tanks from damaging themselves and other infected with their own abilities, and help with optimizing/fixing various parts of the code.

**Milo|** - For the code that automatically generates config files for each day and each map installed on a server.

**hmmmmm** - For showing me how to pick a random character out of a dynamic string.

**Mi.Cura** - For reporting issues, giving me ideas, and overall continuous support.

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