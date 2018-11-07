# Super Tanks++
Super Tanks++ takes the original [[L4D2] Super Tanks](https://forums.alliedmods.net/showthread.php?t=165858) by [Machine](https://forums.alliedmods.net/member.php?u=74752) to the next level by enabling full customization of Super Tanks to make gameplay more interesting.

## License
> The following license is also placed inside the source code of each plugin and include file.

Super Tanks++: a L4D/L4D2 SourceMod Plugin
Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

## About
Super Tanks++ makes fighting Tanks great again!

> Super Tanks++ will enhance and intensify Tank fights by making each Tank that spawns unique and different in its own way.

### What makes Super Tanks++ worth installing?
Super Tanks++ enhances the experience and fun that players get from Tank fights by 500. This plugin gives server owners an arsenal of Super Tanks to test players' skills and create a unique experience in every Tank fight.

### Requirements
1. You must have at least SourceMod 1.10.0.6352 or higher.

### Notes
1. I do not provide support for local/listen servers but the plugin and its modules should still work properly on them.
2. I will not help you with installing or troubleshooting problems on your part.
3. If you get errors from SourceMod itself, that is your problem, not mine.
4. MAKE SURE YOU MEET ALL THE REQUIREMENTS AND FOLLOW THE INSTALLATION GUIDE PROPERLY.

### Installation
1. Delete files from old versions of the plugin.
2. Extract the folder inside the super_tanks++.zip file.
3. Place all the contents into their respective folders.
4. If prompted to replace or merge anything, click yes.
5. Load up Super Tanks++ by restarting the server.
6. Customize Super Tanks++ in addons/sourcemod/data/super_tanks++/super_tanks++.cfg.

### Uninstalling/Upgrading to Newer Versions
1. Delete super_tanks++ folder (super_tanks++.smx and all of its modules) from addons/sourcemod/plugins folder.
2. Delete super_tanks++.txt from addons/sourcemod/gamedata folder.
3. Delete super_tanks++ folder (super_tanks++.sp and all of its modules) from addons/sourcemod/scripting folder.
4. Delete super_tanks++.inc from addons/sourcemod/scripting/include folder.
5. Delete st_clone.inc from addons/sourcemod/scripting/include folder.
6. Delete super_tanks++ folder from addons/sourcemod/data folder.
7. Delete super_tanks++.phrases.txt from addons/sourcemod/translations folder.
8. Follow the Installation guide above. (Only for upgrading to newer versions.)

### Disabling
1. Move super_tanks++ folder (super_tanks++.smx and all of its modules) to plugins/disabled folder.
2. Unload Super Tanks++ by restarting the server.

## Features
1. Supports multiple game modes - Provides the option to enable/disable the plugin in certain game modes.
2. Custom configurations - Provides support for custom configurations, whether per difficulty, per map, per game mode, per day, or per player count.
3. Fully customizable Super Tank types - Provides the ability to fully customize all the Super Tanks that come with the KeyValue config file and user-made Super Tanks.
4. Create and save up to 500 Super Tank types - Provides the ability to store up to 500 Super Tank types that users can enable/disable.
5. Easy-to-use config file - Provides a user-friendly KeyValues config file that users can easily understand and edit.
6. Config auto-reloader - Provides the feature to auto-reload the config file when users change settings mid-game.
7. Optional abilities - Provides the option to choose which abilities to install.
8. Forwards and natives - Provides the ability to allow users to add their own abilities and features through the use of forwards and natives.

## KeyValues Settings
> View the INFORMATION.md file for information about each available setting.

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
3. Automatically generate config files for up to 66 players, all difficulties specified by z_difficulty, maps installed on the server, game modes specified by sv_gametypes and mp_gamemode, and days.

## Questions You May Have
> If you have any questions that aren't addressed below, feel free to message me or post on this [thread](https://forums.alliedmods.net/showthread.php?t=302140).

### Main Features
1. How do I make my own Super Tank?

- Create an entry.

Examples:

This is okay:
```
"Super Tanks++"
{
	"Tank #25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Enabled"				"1" // Tank is enabled.
			"Tank Chance"				"100.0" // Tank has 100% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"255,0,0,255|255,255,0" // Tank has a red (skin) and yellow (glow outline) color scheme.
		}
	}
}
```

This is not okay:
```
"Super Tanks++"
{
	"Tank #25"
	{
		"General"
		{
			// "Tank Enabled" is missing so this entry is disabled.
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Chance"				"47.0" // Tank has 47% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"255,0,0,255|255,255,0" // Tank has a red (skin) and yellow (glow outline) color scheme.
		}
	}
}
```

This is okay:
```
"Super Tanks++"
{
	"Tank #25"
	{
		"General"
		{
			// Since "Tank Name" is missing, the default name for this entry will be "Tank"
			"Tank Enabled"				"1" // Tank is enabled.
			"Tank Chance"				"12.3" // Tank has 12.3% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"255,0,0,255|255,255,0" // Tank has a red (skin) and yellow (glow outline) color scheme.
		}
	}
}
```

This is not okay:
```
"Super Tanks++"
{
	"Tank #25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Enabled"				"1" // Tank is enabled.
			"Tank Chance"				"59.0" // Tank has 59% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"255, 0, 0, 255 | 255, 255, 0" // The string should not contain any spaces.
		}
	}
}
```

- Adding the entry to the roster.

Here's our final entry:
```
"Super Tanks++"
{
	"Tank #25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Named "Test Tank".
			"Tank Enabled"				"1" // Entry is enabled.
			"Tank Chance"				"9.5" // Tank has 9.5% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"255,0,0,255|255,255,0" // Has red/yellow color scheme.
		}
		"Immunities"
		{
			"Fire Immunity"				"1" // Immune to fire.
		}
	}
}
```

To make sure that this entry can be chosen, we must go to the "Plugin Settings" section and look for the "Type Range" setting in the "General" subsection.

```
"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Type Range"				"1-24" // Determines what entry to start and stop at when reading the entire config file.
		}
	}
}
```

Now, assuming that "Tank #25" is our highest entry, we just raise the maximum value of "Type Range" by 1, so we get 25 entries to choose from. Once the plugin starts reading the config file, when it gets to "Tank #25" it will stop reading the rest.

- Advanced Entry Examples

```
"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Type Range"				"1-5" // Check "Tank #1" to "Tank #5"
		}
	}
	"Tank #5" // Checked by the plugin.
	{
		"General"
		{
			"Tank Name"				"Leaper Tank"
			"Tank Enabled"				"1"
			"Tank Chance"				"75.2" // Tank has 75.2% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"255,255,0,255|255,255,0"
		}
		"Enhancements"
		{
			"Extra Health"				"50" // Tank's base health + 50
		}
		"Jump Ability"
		{
			"Ability Enabled"			"2" // The Tank jumps periodically.
			"Ability Message"			"3" // Notify players when the Tank is jumping periodically.
			"Jump Height"				"300.0" // How high off the ground the Tank can jump.
			"Jump Interval"				"1.0" // How often the Tank jumps.
			"Jump Mode"				"0" // The Tank's jumping method.
		}
	}
}

"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Type Range"				"1-11" // Only check for the first 11 Tank types. ("Tank #1" to "Tank #11")
		}
	}
	"Tank #13" // This will not be checked by the plugin.
	{
		"General"
		{
			"Tank Name"				"Invisible Tank"
			"Tank Enabled"				"1"
			"Tank Chance"				"38.2" // Tank has 38.2% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"255,255,255,255|255,255,255"
			"Glow Outline"				"0" // No glow outline.
		}
		"Immunities"
		{
			"Fire Immunity"				"1" // Immune to fire.
		}
		"Ghost Ability"
		{
			"Ability Enabled"			"2"
			"Ghost Fade Alpha"			"2"
			"Ghost Fade Delay"			"5.0"
			"Ghost Fade Limit"			"0"
			"Ghost Fade Rate"			"0.1"
		}
	}
	"Tank #10" // Checked by the plugin.
	{
		"General"
		{
			"Tank Enabled"				"1"
		}
		"Enhancements"
		{
			"Run Speed"				"1.5" // How fast the Tank moves.
		}
	}
}
```

2. Can you add more abilities or features?

- That depends on whether it's doable/possible and if I want to add it.
- If it's from another plugin, it would depend on whether the code is too long, and if it is, I most likely won't go through all that effort for just 1 ability.
- Post on the AM thread or PM me.

3. How do I enable/disable the plugin in certain game modes?

You have 2 options:

- Enable/disable in certain game mode types.
- Enable/disable in specific game modes.

For option 1:

You must add numbers up together in the "Game Mode Types" KeyValues.

For option 2:

You must specify the game modes in the "Enabled Game Modes" and "Disabled Game Modes" KeyValues.

Here are some scenarios and their outcomes:

Scenario 1:

```
"Game Mode Types" "0" // The plugin is enabled in all game mode types.
"Enabled Game Modes" "" // The plugin is enabled in all game modes.
"Disabled Game Modes" "coop" // The plugin is disabled in "coop" mode.

Outcome: The plugin works in every game mode except "coop" mode.
```

Scenario 2:

```
"Game Mode Types" "1" // The plugin is enabled in every Campaign-based game mode.
"Enabled Game Modes" "coop" // The plugin is enabled in only "coop" mode.
"Disabled Game Modes" "" // The plugin is not disabled in any game modes.

Outcome: The plugin works only in "coop" mode.
```

Scenario 3"

```
"Game Mode Types" "5" // The plugin is enabled in every Campaign-based and Survival-based game mode.
"Enabled Game Modes" "coop,versus" // The plugin is enabled in only "coop" and "versus" mode.
"Disabled Game Modes" "coop" // The plugin is disabled in "coop" mode.

Outcome: The plugin works in every Campaign-based and Survival-based game mode except "coop" mode.
```

4. How come some Super Tanks aren't showing up?

It may be due to one or more of the following:

- The "Tank Enabled" KeyValue for that Super Tank may be set to 0 or doesn't exists at all which defaults to 0.
- You have created a new Super Tank and didn't raise the maximum value of the "Type Range" KeyValue.
- You have misspelled one of the KeyValues settings.
- You are still using the "Tank Character" KeyValue which is no longer used since v8.16.
- You didn't set up the Super Tank properly.
- You are missing quotation marks.
- You have more than 500 Super Tanks in your config file.
- You didn't format your config file properly.

5. How do I kill the Tanks depending on what abilities they have?

The following abilities require different strategies:

- Absorb Ability: The Super Tank takes way less damage. Conserve your ammo and maintain distance between you and the Super Tank.
- God Ability: The Super Tank will have god mode temporarily and will not take any damage at all until the effect ends. Maintain distance between you and the Super Tank.
- Bullet Immunity: Forget your guns. Just spam your grenade launcher at it, slash it with an axe or crowbar, or burn it to death.
- Explosive Immunity: Forget explosives and just focus on gunfire, melee weapons, and molotovs/gascans.
- Fire Immunity: No more barbecued Tanks.
- Melee Immunity: No more Gordon Freeman players (immune to melee weapons including crowbar).
- Nullify Hit: The Super Tank can mark players as useless, which means as long as that player is nullified, they will not do any damage.
- Shield Ability: Wait for the Tank to throw propane tanks at you and then throw it back at the Tank. Then shoot the propane tank to deactivate the Tank's shield.

6. How can I change the amount of Tanks that spawn on each finale wave?

Here's an example:

```
"Tank Waves" "2,3,4" // Spawn 2 Tanks on the 1st wave, 3 Tanks on the 2nd wave, and 4 Tanks on the 3rd wave.
```

7. How can I decide whether to display each Tank's health?

Set the value in the "Display Health" KeyValue.

8. Why do some Tanks spawn with different props?

Each prop has X out of 100.0% probability to appear on Super Tanks when they spawn. Configure the chances for each prop in the "Props Chance" KeyValue.

9. Why are the Tanks spawning with more than the extra health given to them?

Since v8.10, extra health given to Tanks is now multiplied by the number of alive non-idle human survivors present when the Tank spawns.

10. How do I add more Super Tanks?

- Add a new entry in the config file.
- Raise the maximum value of the "Type Range" KeyValue.

Example:

```
"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Type Range"				"1-69" // The plugin will check for 69 entries when loading the config file.
		}
	}
	"Tank #69"
	{
		"General"
		{
			"Tank Enabled"				"1" // Tank #69 is enabled and can be chosen.
		}
	}
}
```

11. How do I filter out certain Super Tanks that I made without deleting them?

Enable/disable them with the "Tank Enabled" KeyValue.

Example:

```
"Super Tanks++"
{
	"Tank #1"
	{
		"General"
		{
			"Tank Enabled"				"1" // Tank #1 can be chosen.
			"Tank Chance"				"100.0" // Tank #1 has a chance to spawn.
		}
	}
	"Tank #2"
	{
		"General"
		{
			"Tank Enabled"				"0" // Tank #2 cannot be chosen.
			"Tank Chance"				"0.0" // Tank #2 has no chance to spawn but can still be spawned through the menu.
		}
	}
	"Tank #3"
	{
		"General"
		{
			"Tank Enabled"				"0" // Tank #3 cannot be chosen.
			"Tank Chance"				"0.0" // Tank #3 has no chance to spawn but can still be spawned through the menu.
		}
	}
	"Tank #4"
	{
		"General"
		{
			"Tank Enabled"				"1" // Tank #4 can be chosen.
			"Tank Chance"				"100.0" // Tank #4 has a chance to spawn.
		}
	}
}
```

12. Can I create temporary Tanks without removing or replacing them?

Yes, you can do that with custom configs.

Example:

```
// Settings for addons/sourcemod/data/super_tanks++/super_tanks++.cfg
"Super Tanks++"
{
	"Plugin Settings"
	{
		"Game Modes"
		{
			"Enable Custom Configs"			"1" // Enable custom configs
			"Execute Config Types"			"1" // 1: Difficulty configs (easy, normal, hard, impossible)
		}
	}
	"Tank #69"
	{
		"General"
		{
			"Tank Name"				"Psyk0tik Tank"
			"Tank Enabled"				"1"
			"Tank Chance"				"2.53" // Tank has 2.53% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"0,170,255,255|0,170,255"
		}
		"Enhancements"
		{
			"Extra Health"				"250"
		}
		"Immunities"
		{
			"Fire Immunity"				"1"
		}
	}
}

// Settings for addons/sourcemod/data/super_tanks++/difficulty_configs/impossible.cfg
"Super Tanks++"
{
	"Tank #69"
	{
		"General"
		{
			"Tank Name"				"Idiot Tank"
			"Tank Enabled"				"1"
			"Tank Chance"				"1.0" // Tank has 1% chance of spawning.
			"Spawn Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin-Glow Colors"			"1,1,1,255|1,1,1"
		}
		"Enhancements"
		{
			"Extra Health"				"1"
		}
		"Immunities"
		{
			"Fire Immunity"				"0"
		}
	}
}

Output: When the current difficulty is Expert mode (impossible), the Idiot Tank will spawn instead of Psyk0tik Tank as long as custom configs is being used.

These are basically temporary Tanks that you can create for certain situations, like if there's 5 players on the server, the map is c1m1_hotel, or even if the day is Thursday, etc.
```

13. How can I move the Super Tanks++ category around on the admin menu?

- You have to open up addons/sourcemod/configs/adminmenu_sorting.txt.
- Enter the "SuperTanks++" category.

Example:

```
"Menu"
{
	"PlayerCommands"
	{
		"item"		"sm_slay"
		"item"		"sm_slap"
		"item"		"sm_kick"
		"item"		"sm_ban"
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

14. Are there any developer/tester features available in the plugin?

Yes, there are forwards, natives, stocks, target filters for each special infected, and admin commands that allow developers/testers to spawn each Super Tank and see their statuses.

Forwards:
```
/**
 * Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param tank			Client index of the Tank.
 **/
forward void ST_Ability(int tank);

/**
 * Called when the Super Tank evolves.
 * Use this forward to trigger any features/abilities/settings when a Super Tank evolves.
 *
 * @param tank			Client index of the Tank.
 **/
forward void ST_BossStage(int tank);

/**
 * Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param main			Checks whether the main config or a custom config is being used.
 **/
forward void ST_Configs(const char[] savepath, bool main);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 **/
forward void ST_Event(Event event, const char[] name);

/**
 * Called when the core plugin is unloaded/reloaded.
 * Use this forward to get rid of any modifications to Tanks or survivors.
 **/
forward void ST_PluginEnd();

/**
 * Called when the Tank spawns.
 * Use this forward for any on-spawn presets.
 * If you plan on using this to activate an ability, use ST_Ability() instead.
 *
 * @param tank			Client index of the Tank.
 **/
forward void ST_Preset(int tank);

/**
 * Called when the Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void ST_RockBreak(int tank, int rock);

/**
 * Called when the Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void ST_RockThrow(int tank, int rock);
```

Natives:
```
/**
 * Returns the maximum value of the "Type Range" setting.
 *
 * @return			The maximum value of the "Type Range" setting.
 **/
native int ST_MaxType();

/**
 * Returns the minimum value of the "Type Range" setting.
 *
 * @return			The minimum value of the "Type Range" setting.
 **/
native int ST_MinType();

/**
 * Returns if the core plugin is enabled.
 *
 * @return			True if core plugin is enabled, false otherwise.
 **/
native bool ST_PluginEnabled();

/**
 * Returns if a certain Super Tank type can be spawned.
 *
 * @param type			Super Tank type.
 * @return			True if the type can be spawned, false otherwise.
 * @error			Type is 0.
 **/
native bool ST_SpawnEnabled(int type);

/**
 * Spawns a Tank with the specified Super Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Super Tank type.
 * @error			Invalid client index or type is 0.
 **/
native void ST_SpawnTank(int tank, int type);

/**
 * Returns if the Tank is allowed to be a Super Tank.
 *
 * @param tank			Client index of the Tank.
 * @return			True if Tank is allowed to be a Super Tank, false otherwise.
 * @error			Invalid client index.
 **/
native bool ST_TankAllowed(int tank);

/**
 * Returns if a certain Super Tank type has a chance of spawning.
 *
 * @param type			Super Tank type.
 * @return			True if the type has a chance of spawning, false otherwise.
 * @error			Type is 0.
 **/
native bool ST_TankChance(int type);

/**
 * Returns the RGB colors given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Skin color, 2 = Glow outline color
 * @param red			Buffer to store the red color in.
 * @param green			Buffer to store the green color in.
 * @param blue			Buffer to store the blue color in.
 * @error			Invalid client index.
 **/
native void ST_TankColors(int tank, int mode, char[] red, char[] green, char[] blue);

/**
 * Returns the custom name given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param buffer		Buffer to store the custom name in.
 * @error			Invalid client index.
 **/
native void ST_TankName(int tank, char[] buffer);

/**
 * Returns the Super Tank type of the Tank.
 *
 * @param tank			Client index of the Tank.
 * @return			The Tank's Super Tank type.
 * @error			Invalid client index.
 **/
native int ST_TankType(int tank);

/**
 * Returns the current finale wave.
 *
 * @return			The current finale wave.
 **/
native int ST_TankWave();

/**
 * Returns if a certain Super Tank type is enabled.
 *
 * @param type			Super Tank type.
 * @return			True if the type is enabled, false otherwise.
 * @error			Type is 0.
 **/
native bool ST_TypeEnabled(int type);
```

Target filters:

```
@smokers
@boomers
@hunters
@spitters
@jockeys
@chargers
@witches
@tanks
@special
@infected
```

Commands:

```
sm_tank

Valid inputs:

1. sm_tank <type 1*-500*> *The minimum and maximum values are determined by the "Type Range" KeyValue setting. (The lowest value you can set is 1 and the highest value you can set is 500 though.)
2. sm_tank <type name*> *The plugin will attempt to match the name with any of the Super Tank types' names. (Partial names are acceptable. If more than 1 match is found, a random match is chosen. If 0 matches are found, the command cancels the request.)
```

Logging:

```
The core plugin provides some logging, which consists of only logging each Super Tank's colors, arrival, and death.

Changed the value of ST_LOGS in the core plugin.

#define ST_LOGS 0 to #define ST_LOGS 1
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
**Machine** - For the original [[L4D2] Super Tanks](https://forums.alliedmods.net/showthread.php?t=165858) plugin.

**NgBUCKWANGS** - For the mapname.cfg code in his [[L4D2] ABM](https://forums.alliedmods.net/showthread.php?t=291562) plugin.

**Spirit_12** - For the L4D signatures for the gamedata file.

**honorcode23** - For the [[L4D & L4D2] New Custom Commands](https://forums.alliedmods.net/showthread.php?t=133475) plugin.

**panxiaohai** - For the [[L4D & L4D2] We Can Not Survive Alone](https://forums.alliedmods.net/showthread.php?t=167389), [[L4D & L4D2] Melee Weapon Tank](https://forums.alliedmods.net/showthread.php?t=166356), and [[L4D & L4D2] Tank's Power](https://forums.alliedmods.net/showthread.php?t=134537) plugins.

**strontiumdog** - For the [[ANY] Evil Admin: Mirror Damage](https://forums.alliedmods.net/showthread.php?t=79321), [[ANY] Evil Admin: Pimp Slap](https://forums.alliedmods.net/showthread.php?t=79322), [[ANY] Evil Admin: Rocket](https://forums.alliedmods.net/showthread.php?t=79617), and [Evil Admin: Vision](https://forums.alliedmods.net/showthread.php?t=79324) plugins.

**Hipster** - For the [[ANY] Admin Smite](https://forums.alliedmods.net/showthread.php?t=118534) plugin.

**Marcus101RR** - For the code to set a player's weapon's ammo.

**AtomicStryker** - For the [[L4D & L4D2] SM Respawn Command](https://forums.alliedmods.net/showthread.php?t=96249) and [[L4D & L4D2] Boomer Splash Damage](https://forums.alliedmods.net/showthread.php?t=98794) plugins.

**ivailosp and V10** - For the [[L4D] Away](https://forums.alliedmods.net/showthread.php?t=85537) and [[L4D2] Away](https://forums.alliedmods.net/showthread.php?t=222590) plugins.

**mi123645** - For the [[L4D(2)] 4+ Survivor AFK Fix](https://forums.alliedmods.net/showthread.php?t=132409) plugin.

**Farbror Godis** - For the [[ANY] Curse](https://forums.alliedmods.net/showthread.php?t=280146) plugin.

**GoD-Tony** - For the [Toggle Weapon Sounds](https://forums.alliedmods.net/showthread.php?p=1694338) plugin.

**Phil25** - For the [[TF2] Roll the Dice Revamped (RTD)](https://forums.alliedmods.net/showthread.php?t=278579) plugin.

**Chaosxk** - For the [[ANY] Spin my screen](https://forums.alliedmods.net/showthread.php?t=283120) plugin.

**ztar** - For the [[L4D2] LAST BOSS](https://forums.alliedmods.net/showthread.php?t=129013?t=129013) plugin.

**IxAvnoMonvAxI** - For the [[L4D2] Last Boss Extended](https://forums.alliedmods.net/showpost.php?p=1463486&postcount=2) plugin.

**Uncle Jessie** - For the Tremor Tank in his [Last Boss Extended revision](https://forums.alliedmods.net/showpost.php?p=2570108&postcount=73).

**Drixevel** - For the [[ANY] Force Active Weapon](https://forums.alliedmods.net/showthread.php?t=293645) plugin.

**pRED** - For the [[ANY] SM Super Commands](https://forums.alliedmods.net/showthread.php?t=57448) plugin.

**sheo** - For the [[L4D2] Fix Frozen Tanks](https://forums.alliedmods.net/showthread.php?t=239809) plugin.

**Silvers (Silvershot)** - For the code that allows users to enable/disable the plugin in certain game modes, for the [[L4D & L4D2] Silenced Infected](https://forums.alliedmods.net/showthread.php?t=137397) plugin, help with gamedata signatures, the code to prevent Tanks from damaging themselves and other infected with their own abilities, and helping to optimize/fix various parts of the code.

**Lux** - For helping to optimize/fix various parts of the code.

**Milo|** - For the [Extended Map Configs](https://forums.alliedmods.net/showthread.php?t=85551) and [Dailyconfig](https://forums.alliedmods.net/showthread.php?t=84720) plugins.

**hmmmmm** - For showing me how to pick a random character out of a dynamic string.

**Mi.Cura** - For reporting issues, suggesting ideas, and overall support.

**KasperH** - For reporting issues, suggesting ideas, and overall support.

**emsit** - For reporting issues, helping with parts of the code, and suggesting ideas.

**ReCreator** - For reporting issues and suggesting ideas.

**Princess LadyRain** - For reporting issues.

**Zytheus** - For reporting issues and suggesting ideas.

**huwong** - For reporting issues and suggesting ideas.

**AngelAce113** - For the default colors (before v8.12), testing each Tank type, suggesting ideas, and overall support.

**Sipow** - For the default colors (before v8.12), suggesting ideas, and overall support.

**SourceMod Team** - For the blind, drug, and ice source codes, and for miscellaneous reasons.

# Contact Me
If you wish to contact me for any questions, concerns, suggestions, or criticism, I can be found here:
- [AlliedModders Forum](https://forums.alliedmods.net/member.php?u=181166) (Use this for just reporting bugs/issues or giving suggestions/ideas.)
- [Steam](https://steamcommunity.com/profiles/76561198056665335) (Use this for getting to know me or wanting to be friends with me.)
- Psyk0tik#7757 on Discord (Use this for pitching in new/better code.)

# 3rd-Party Revisions Notice
If you would like to share your own revisions of this plugin, please rename the files! I do not want to create confusion for end-users and it will avoid conflict and negative feedback on the official versions of my work. If you choose to keep the same file names for your revisions, it will cause users to assume that the official versions are the source of any problems your revisions may have. This is to protect you (the reviser) and me (the developer)! Thank you!

# Donate (PayPal only)
- [Donate to SourceMod](https://www.sourcemod.net/donate.php)
- Donate to me at alfred_llagas3637@yahoo.com

Thank you very much and have fun! :)