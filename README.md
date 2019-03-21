# Mutant Tanks
Mutant Tanks takes the original [[L4D2] Super Tanks](https://forums.alliedmods.net/showthread.php?t=165858) by [Machine](https://forums.alliedmods.net/member.php?u=74752) to the next level by enabling full customization of Mutant Tanks to make gameplay more interesting.

## License
> The following license is also placed inside the source code of each plugin and include file.

Mutant Tanks: a L4D/L4D2 SourceMod Plugin
Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

## About
> Mutant Tanks makes fighting Tanks great again!

Mutant Tanks will enhance and intensify Tank fights by making each Tank that spawns unique and different in its own way.

### What makes Mutant Tanks worth installing?
Mutant Tanks enhances the experience and fun that players get from Tank fights by 1000. This plugin gives server owners an arsenal of Mutant Tanks to test players' skills and create a unique experience in every Tank fight.

## Features
1. Supports all game modes - Provides the option to enable/disable the plugin in all game modes.
2. Custom configurations - Provides support for custom configurations, whether per difficulty, per map, per game mode, per day, or per player count.
3. Fully customizable Mutant Tank types - Provides the ability to fully customize all the Mutant Tanks that come with the config file and user-made Mutant Tanks.
4. Create and save up to 1000 Mutant Tank types - Provides the ability to store up to 1000 Mutant Tank types.
5. Flexible config formatting - Provides 4 different formats for the config file.
6. Config auto-reloader - Provides the feature to auto-reload the config file when users change settings mid-game.
7. Optional abilities - Provides the option to choose which abilities to install.
8. User-friendly API - Provides the ability to allow users to add their own abilities and features through the use of forwards and natives.
9. Target filters - Provides custom target filters for targeting survivors and special infected.
10. Supports multiple languages - Provides support for translations.
11. Chat color tags - Provides chat color tags for translation files.
12. Administration system - Provides an administration system revolved around the usage and effectiveness of each Mutant Tank type.

### Requirements
1. You must have at least `SourceMod 1.10.0.6352` or higher.

### Notes
1. I do not provide support for listen servers but the plugin and its modules should still work properly on them.
2. I will not help you with installing or troubleshooting problems on your part.
3. If you get errors from SourceMod itself, that is your problem, not mine.
4. MAKE SURE YOU MEET ALL THE REQUIREMENTS AND FOLLOW THE INSTALLATION GUIDE PROPERLY.

### Installation
1. Delete files from old versions of the plugin.
2. Extract the folder inside the `mutant_tanks.zip` file.
3. Place all the contents into their respective folders.
4. If prompted to replace or merge anything, click yes.
5. Load up Mutant Tanks by restarting the server.
6. Customize Mutant Tanks in `addons/sourcemod/data/mutant_tanks/mutant_tanks.cfg`

### Uninstalling/Upgrading to Newer Versions
1. Delete `mutant_tanks` folder from:
 - `addons/sourcemod/plugins` folder (`mutant_tanks.smx` and all of its modules)
 - `addons/sourcemod/scripting` folder (`mutant_tanks.sp` and all of its modules)
2. Delete `mutant_tanks.txt` from `addons/sourcemod/gamedata` folder.
3. Delete `mutant_tanks.inc` from `addons/sourcemod/scripting/include` folder.
4. Delete `mt_clone.inc` from `addons/sourcemod/scripting/include` folder.
5. Delete `mutant_tanks.phrases.txt` from `addons/sourcemod/translations` folder.
6. Backup `mutant_tanks` folder in `addons/sourcemod/data` folder.
6. Follow the Installation guide above. (Only for upgrading to newer versions.)

### Disabling
1. Move `mutant_tanks` folder (`mutant_tanks.smx` and all of its modules) to `plugins/disabled` folder.
2. Unload Mutant Tanks by restarting the server.

## KeyValues Settings
> View the INFORMATION.md file for information about each available setting.

### Custom Configuration Files
> Mutant Tanks has features that allow for creating and executing custom configuration files.

By default, Mutant Tanks can create and execute the following types of configurations:
1. Difficulty - Files are created/executed based on the current game difficulty. (Example: If the current `z_difficulty` is set to Impossible (Expert mode), then `impossible.cfg` is executed (or created if it doesn't exist already).
2. Map - Files are created/executed based on the current map. (Example: If the current map is `c1m1_hotel`, then `c1m1_hotel.cfg` is executed (or created if it doesn't exist already).
3. Game mode - Files are created/executed based on the current game mode. (Example: If the current game mode is Versus, then `versus.cfg` is executed (or created if it doesn't exist already).
4. Daily - Files are created/executed based on the current day. (Example: If the current day is Friday, then `friday.cfg` is executed (or created if it doesn't exist already).
5. Player count - Files are created/executed based on the current number of human players. (Example: If the current number is 8, then `8.cfg` is executed (or created if it doesn't exist already).

#### Features
1. Create custom config files (can be based on difficulty, map, game mode, day, player count, or custom name).
2. Execute custom config files (can be based on difficulty, map, game mode, day, player count, or custom name).
3. Automatically generate config files for up to 66 players, all difficulties specified by `z_difficulty`, maps installed on the server, game modes specified by `sv_gametypes` and `mp_gamemode`, and days.

## Questions You May Have
> If you have any questions that aren't addressed below, feel free to message me or post on this [thread](https://forums.alliedmods.net/showthread.php?t=302140).

### Main Features
1. How do I make my own Mutant Tank?

- Create an entry.

Examples:

This is okay:
```
"Mutant Tanks"
{
	"Tank #25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Enabled"				"1" // Tank is enabled.
			"Tank Chance"				"100.0" // Tank has 100% chance of spawning.
			"Spawn Enabled"				"1" // Tank can spawn.
			"Menu Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin Color"				"255,0,0,255" // Tank has red skin.
			"Glow Color"				"255,255,0" // Tank has a yellow glow outline.
		}
	}
}
```

This is not okay:
```
"Mutant Tanks"
{
	"Tank #25"
	{
		"General"
		{
			// "Tank Enabled" is missing so this entry is disabled.
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Chance"				"47.0" // Tank has 47% chance of spawning.
			"Spawn Enabled"				"1" // Tank can spawn.
			"Menu Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin Color"				"255,0,0,255" // Tank has red skin.
			"Glow Color"				"255,255,0" // Tank has a yellow glow outline.
		}
	}
}
```

This is okay:
```
"Mutant Tanks"
{
	"Tank #25"
	{
		"General"
		{
			// Since "Tank Name" is missing, the default name for this entry will be "Tank"
			"Tank Enabled"				"1" // Tank is enabled.
			"Tank Chance"				"12.3" // Tank has 12.3% chance of spawning.
			"Spawn Enabled"				"1" // Tank can spawn.
			"Menu Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin Color"				"255,0,0,255" // Tank has red skin.
			"Glow Color"				"255,255,0" // Tank has a yellow glow outline.
		}
	}
}
```

This is not okay:
```
"Mutant Tanks"
{
	"Tank #25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Enabled"				"1" // Tank is enabled.
			"Tank Chance"				"59.0" // Tank has 59% chance of spawning.
			"Spawn Enabled"				"1" // Tank can spawn.
			"Menu Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin Color"				"255 0 0 255" // The string should not contain any commas.
			"Glow Color"				"255 255 0" // The string should not contain any commas.
		}
	}
}
```

- Adding the entry to the roster.

Here's our final entry:
```
"Mutant Tanks"
{
	"Tank #25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Named "Test Tank".
			"Tank Enabled"				"1" // Entry is enabled.
			"Tank Chance"				"9.5" // Tank has 9.5% chance of spawning.
			"Spawn Enabled"				"1" // Tank can spawn.
			"Menu Enabled"				"1" // Tank can be spawned through the "sm_tank" command.
			"Skin Color"				"255,0,0,255" // Tank has red skin.
			"Glow Color"				"255,255,0" // Tank has a yellow glow outline.
		}
		"Immunities"
		{
			"Fire Immunity"				"1" // Immune to fire.
		}
	}
}
```

To make sure that this entry can be chosen, we must change the value in the `Type Range` setting.

```
"Mutant Tanks"
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

Now, assuming that `Tank #25` is our highest entry, we just raise the maximum value of `Type Range` by 1, so we get 25 entries to choose from. Once the plugin starts reading the config file, when it gets to `Tank #25` it will stop reading the rest.

- Advanced Entry Examples

```
"Mutant Tanks"
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
			"Tank Chance"				"75.2"
			"Spawn Enabled"				"1"
			"Menu Enabled"				"1"
			"Skin Color"				"255,255,0,255"
			"Glow Color"				"255,255,0"
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
```

```
"Mutant Tanks"
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
			"Tank Chance"				"38.2"
			"Spawn Enabled"				"1"
			"Menu Enabled"				"1"
			"Skin Color"				"255,255,255,255"
			"Glow Color"				"255,255,255"
			"Glow Enabled"				"0" // No glow outline.
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

You must add numbers up together in `Game Mode Types`.

For option 2:

You must specify the game modes in `Enabled Game Modes` and `Disabled Game Modes`.

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

Scenario 3:

```
"Game Mode Types" "5" // The plugin is enabled in every Campaign-based and Survival-based game mode.
"Enabled Game Modes" "coop,versus" // The plugin is enabled in only "coop" and "versus" mode.
"Disabled Game Modes" "coop" // The plugin is disabled in "coop" mode.

Outcome: The plugin works in every Campaign-based and Survival-based game mode except "coop" mode.
```

4. How come some Mutant Tanks aren't showing up?

It may be due to one or more of the following:

- The `Tank Enabled` setting for that Mutant Tank may be set to 0 or doesn't exists at all which defaults to 0.
- The `Spawn Enabled` setting for that Mutant Tank may be set to 0
- You have created a new Mutant Tank and didn't raise the maximum value of `Type Range`.
- You have misspelled one of the settings.
- You are still using the `Tank Character` setting which is no longer used since v8.16.
- You didn't set up the Mutant Tank properly.
- You are missing quotation marks.
- You are missing curly braces.
- You have more than 1000 Mutant Tanks in your config file.
- You didn't format your config file properly.
- The `Detect Plugins` setting automatically disabled the Mutant Tank due to not having any of its abilities installed.

5. How do I kill the Tanks depending on what abilities they have?

The following abilities require different strategies:

- Absorb Ability: The Mutant Tank takes way less damage. Conserve your ammo and maintain distance between you and the Mutant Tank.
- God Ability: The Mutant Tank will have god mode temporarily and will not take any damage at all until the effect ends. Maintain distance between you and the Mutant Tank.
- Bullet Immunity: Forget your guns. Just spam your grenade launcher at it, slash it with an axe or crowbar, or burn it to death.
- Explosive Immunity: Forget explosives and just focus on gunfire, melee weapons, and molotovs/gascans.
- Fire Immunity: No more barbecued Tanks.
- Melee Immunity: No more Gordon Freeman players (immune to melee weapons including crowbar).
- Nullify Hit: The Mutant Tank can mark players as useless, which means as long as that player is nullified, they will not do any damage.
- Shield Ability: Wait for the Tank to throw propane tanks at you and then throw it back at the Tank. Then shoot the propane tank to deactivate the Tank's shield.

6. How can I change the amount of Tanks that spawn on each finale wave?

Here's an example:

```
"Finale Waves" "2,3,4" // Spawn 2 Tanks on the 1st wave, 3 Tanks on the 2nd wave, and 4 Tanks on the 3rd wave.
```

7. How can I decide whether to display each Tank's health?

Set the value in `Display Health`.

8. Why do some Tanks spawn with different props?

Each prop has X out of 100.0% chance to appear on Mutant Tanks when they spawn. Configure the chances for each prop in the `Props Chance` setting.

9. Why are the Tanks spawning with more than the extra health given to them?

Since v8.10, extra health given to Tanks is now multiplied by the number of alive non-idle human survivors present when the Tank spawns.

10. How do I add more Mutant Tanks?

- Add a new entry in the config file.
- Raise the maximum value of the `Type Range` setting.

Example:

```
"Mutant Tanks"
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

11. How do I filter out certain Mutant Tanks that I made without deleting them?

Enable/disable them with the `Tank Enabled` setting.

Example:

```
"Mutant Tanks"
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
// Settings for addons/sourcemod/data/mutant_tanks/mutant_tanks.cfg
"Mutant Tanks"
{
	"Plugin Settings"
	{
		"Custom"
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
			"Tank Chance"				"2.53"
			"Spawn Enabled"				"1"
			"Menu Enabled"				"1"
			"Skin Color"				"0,170,255,255"
			"Glow Color"				"0,170,255"
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

// Settings for addons/sourcemod/data/mutant_tanks/difficulty_configs/impossible.cfg
"Mutant Tanks"
{
	"Tank #69"
	{
		"General"
		{
			"Tank Name"				"Idiot Tank"
			"Tank Enabled"				"1"
			"Tank Chance"				"1.0"
			"Spawn Enabled"				"1"
			"Menu Enabled"				"1"
			"Skin Color"				"1,1,1,255"
			"Glow Color"				"1,1,1"
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

13. How can I move the Mutant Tanks category around on the admin menu?

- You have to open up addons/sourcemod/configs/adminmenu_sorting.txt.
- Enter the `MutantTanks` category.

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

	"MutantTanks"
	{
		"item"		"sm_tank"
	}
}
```

14. Are there any developer/tester features available in the plugin?

Yes, there are forwards, natives, stocks, target filters for each special infected, and an admin command that allows developers/testers to spawn and test each Mutant Tank.

Forwards:
```
/**
 * Called every second to trigger a Mutant Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param tank			Client index of the Tank.
 **/
forward void MT_OnAbilityActivated(int tank);

/**
 * Called when a human-controlled Mutant Tank presses a button.
 * Use this forward to trigger abilities manually.
 *
 * @param tank			Client index of the Tank.
 * @param button		Button pressed.
 **/
forward void MT_OnButtonPressed(int tank, int button);

/**
 * Called when a human-controlled Mutant Tank releases a button.
 * Use this forward to trigger abilities manually.
 *
 * @param tank			Client index of the Tank.
 * @param button		Button released.
 **/
forward void MT_OnButtonReleased(int tank, int button);

/**
 * Called when a Mutant Tank changes types.
 * Use this forward to trigger any features/abilities/settings when a Mutant Tank changes types.
 *
 * @param tank			Client index of the Tank.
 * @param revert		True if reverting to a normal Tank, false otherwise.
 **/
forward void MT_OnChangeType(int tank, bool revert);

/**
 * Called when the config file is about to load.
 * Use this forward to set default values for settings for the plugin.
 **/
forward void MT_OnConfigsLoad();

/**
 * Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param subsection		The subsection the config parser is currently on.
 * @param key			The key the config parser is currently on.
 * @param value			The value the config parser is currently on.
 * @param type			The Mutant Tank type the config parser is currently on. (Used for Mutant Tank-specific settings.)
 * @param admin			Client index of an admin. (Used for admin-specific settings.)
 **/
forward void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin);

/**
 * Called when a player uses the "sm_mt_info" command.
 * Use this forward to add menu items.
 *
 * @param menu			Handle to the menu.
 **/
forward void MT_OnDisplayMenu(Menu menu);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast		True if event was not broadcast to clients, false otherwise.
 **/
forward void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast);

/**
 * Called when the core plugin is hooking/unhooking events.
 * Use this forward to hook/unhook events.
 *
 * @param mode			True if event was hooked, false otherwise.
 **/
forward void MT_OnHookEvent(bool mode);

/**
 * Called when a player selects an item from the "Mutant Tanks Information" menu.
 * Use this forward to do anything when an item is selected.
 *
 * @param client		Client index of the player selecting the item.
 * @param info			String containing the name of the item.
 **/
forward void MT_OnMenuItemSelected(int client, const char[] info);

/**
 * Called when the core plugin is unloaded/reloaded.
 * Use this forward to get rid of any modifications to Tanks or survivors.
 **/
forward void MT_OnPluginEnd();

/**
 * Called after a Mutant Tank spawns.
 * Use this forward for any post-spawn actions.
 * If you plan on using this to activate an ability, use MT_OnAbilityActivated() instead.
 *
 * @param tank			Client index of the Tank.
 **/
forward void MT_OnPostTankSpawn(int tank);

/**
 * Called when a Mutant Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void MT_OnRockBreak(int tank, int rock);

/**
 * Called when a Mutant Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void MT_OnRockThrow(int tank, int rock);
```

Natives:
```
/**
 * Returns if a certain Mutant Tank type can spawn.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type can spawn, false otherwise.
 * @error			Type is 0.
 **/
native bool MT_CanTankSpawn(int type);

/**
 * Returns the status of an ability for a certain Mutant Tank type.
 *
 * @param type			Mutant Tank type.
 * @param order			Ability order starting from 0.
 * @param status		True if the type has the ability, false otherwise.
 **/
native void MT_FindAbility(int type, int order, bool status);

/**
 * Returns the current access flags set by the core plugin.
 *
 * @param mode			1 = Global flags, 2 = Type-specific flags, 3 = Global admin flags, 4 = Type-specific admin flags
 * @param type			Mutant Tank type. (Optional)
 * @param admin			Client index of an admin. (Optional)
 * @return			The current access flags.
 * @error			Invalid client index or type is 0.
 **/
native int MT_GetAccessFlags(int mode, int type = 0, int admin = -1);

/**
 * Returns the current finale wave.
 *
 * @return			The current finale wave.
 **/
native int MT_GetCurrentFinaleWave();

/**
 * Returns the current immunity flags set by the core plugin.
 *
 * @param mode			1 = Global flags, 2 = Type-specific flags, 3 = Global admin flags, 4 = Type-specific admin flags
 * @param type			Mutant Tank type. (Optional)
 * @param admin			Client index of an admin. (Optional)
 * @return			The current immunity flags.
 * @error			Invalid client index or type is 0.
 **/
native int MT_GetImmunityFlags(int mode, int type = 0, int admin = -1);

/**
 * Returns the maximum value of the "Type Range" setting.
 *
 * @return			The maximum value of the "Type Range" setting.
 **/
native int MT_GetMaxType();

/**
 * Returns the minimum value of the "Type Range" setting.
 *
 * @return			The minimum value of the "Type Range" setting.
 **/
native int MT_GetMinType();

/**
 * Returns the RGBA colors given to a Mutant Tank's props.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Light color, 2 = Oxygen tank color, 3 = Oxygen tank flames color,
 *				4 = Rock color, 5 = Tire color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 * @error			Invalid client index.
 **/
native void MT_GetPropColors(int tank, int mode, int &red, int &green, int &blue, int &alpha);

/**
 * Returns a Mutant Tank's run speed.
 *
 * @param tank			Client index of the Tank.
 * @return			The run speed of the Tank.
 * @error			Invalid client index.
 **/
native float MT_GetRunSpeed(int tank);

/**
 * Returns the RGB colors given to a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Skin color, 2 = Glow outline color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 * @error			Invalid client index.
 **/
native void MT_GetTankColors(int tank, int mode, int &red, int &green, int &blue, int &alpha);

/**
 * Returns the custom name given to a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 * @param buffer		Buffer to store the custom name in.
 * @error			Invalid client index.
 **/
native void MT_GetTankName(int tank, int type, char[] buffer);

/**
 * Returns the type of a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @return			The Tank's Mutant Tank type.
 * @error			Invalid client index.
 **/
native int MT_GetTankType(int tank);

/**
 * Returns if a human player has access to a Mutant Tank type.
 *
 * @param admin			Client index of the admin.
 * @return			True if the human player has access, false otherwise.
 **/
native bool MT_HasAdminAccess(int admin);

/**
 * Returns if a certain Mutant Tank type has a chance of spawning.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type has a chance of spawning, false otherwise.
 * @error			Type is 0.
 **/
native bool MT_HasChanceToSpawn(int type);

/**
 * Hooks/unhooks any entity to/from the core plugin's SetTransmit callback.
 *
 * @param entity		Entity index of the entity.
 * @param mode			True if hooking entity, false otherwise.
 * @error			Invalid entity index.
 **/
native void MT_HideEntity(int entity, bool mode);

/**
 * Returns if a human survivor is immune to a Mutant Tank's attacks.
 *
 * @param survivor		Client index of the survivor.
 * @param tank			Client index of the Tank.
 * @return			True if the human survivor is immune, false otherwise.
 **/
native bool MT_IsAdminImmune(int survivor, int tank);

/**
 * Returns if the clone can use abilities.
 *
 * @param tank				Client index of the Tank.
 * @param clone				Checks whether "mt_clone.smx" is installed.
 * @return				True if clone can use abilities, false otherwise.
 **/
native bool MT_IsCloneSupported(int tank, bool clone);

/**
 * Returns if the core plugin is enabled.
 *
 * @return			True if core plugin is enabled, false otherwise.
 **/
native bool MT_IsCorePluginEnabled();

/**
 * Returns if a certain Mutant Tank type is only available on finale maps.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type is available, false otherwise.
 * @error			Type is 0.
 **/
native bool MT_IsFinaleTank(int type);

/**
 * Returns if a Mutant Tank type has a glow outline.
 *
 * @param tank			Client index of the Tank.
 * @return			True if the Tank has a glow outline, false otherwise.
 * @error			Invalid client index.
 **/
native bool MT_IsGlowEnabled(int tank);

/**
 * Returns if a Tank is allowed to be a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param flags			Checks to run.
 *				MT_CHECK_INDEX = client index, MT_CHECK_CONNECTED = connection, MT_CHECK_INGAME = in-game status,
 *				MT_CHECK_ALIVE = life state, MT_CHECK_KICKQUEUE = kick status, MT_CHECK_FAKECLIENT = bot check
 *				Default: MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE
 * @return			True if Tank is allowed to be a Mutant Tank, false otherwise.
 * @error			Invalid client index.
 **/
native bool MT_IsTankSupported(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE);

/**
 * Returns if a certain Mutant Tank type is enabled.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type is enabled, false otherwise.
 * @error			Type is 0.
 **/
native bool MT_IsTypeEnabled(int type);

/**
 * Sets a Tank's Mutant Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 * @param mode			True if the Tank should transform physically into the new Mutant Tank type, false otherwise.
 **/
native void MT_SetTankType(int tank, int type, bool mode);

/**
 * Spawns a Tank with the specified Mutant Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 * @error			Invalid client index or type is 0.
 **/
native void MT_SpawnTank(int tank, int type);
```

Stocks:

```
stock void MT_PrintToChat(int client, char[] message, any ...)
{
	if (!bIsValidClient(client, "0"))
	{
		ThrowError("Invalid client index %d", client);
	}
	
	if (!bIsValidClient(client, "2"))
	{
		ThrowError("Client %d is not in game", client);
	}

	char sBuffer[255], sMessage[255];
	SetGlobalTransTarget(client);
	Format(sBuffer, sizeof(sBuffer), "\x01%s", message);
	VFormat(sMessage, sizeof(sMessage), sBuffer, 3);

	ReplaceString(sMessage, sizeof(sMessage), "{default}", "\x01");
	ReplaceString(sMessage, sizeof(sMessage), "{mint}", "\x03");
	ReplaceString(sMessage, sizeof(sMessage), "{yellow}", "\x04");
	ReplaceString(sMessage, sizeof(sMessage), "{olive}", "\x05");

	PrintToChat(client, sMessage);
}

stock void MT_PrintToChatAll(char[] message, any ...)
{
	char sBuffer[255];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "25"))
		{
			SetGlobalTransTarget(iPlayer);
			VFormat(sBuffer, sizeof(sBuffer), message, 2);

			MT_PrintToChat(iPlayer, sBuffer);
		}
	}
}
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
// Requires "z" (Root) flag.
sm_tank - Spawn a Mutant Tank.

Valid inputs:

1. sm_tank <type 1*-1000*> <amount: 1-32> <0: spawn on crosshair|1: spawn automatically> *The minimum and maximum values are determined by "Type Range". (The lowest value you can set is 1 and the highest value you can set is 1000 though.)
2. sm_tank <type name*> <amount: 1-32> <0: spawn on crosshair|1: spawn automatically> *The plugin will attempt to match the name with any of the Mutant Tank types' names. (Partial names are acceptable. If more than 1 match is found, a random match is chosen. If 0 matches are found, the command cancels the request.)

The command has 4 functions.

If you are not a Tank:

1. When facing a non-Tank entity, a Mutant Tank will spawn with the chosen type.
2. When facing a Tank, it will switch to the chosen type.

If you are a Tank:

1. When holding down the +speed (default: LSHIFT) button, a Mutant Tank will spawn into the chosen type.
2. When not holding down the +speed button, you will transform into the chosen type.
```

```
// Accessible by the developer and admins with "z" (Root) flag.
sm_mt_list - View a list of installed abilities.
sm_tank2 - Spawn a Mutant Tank.

// Accessible by all players.
sm_mt_config - View a section of the config file.
sm_mt_info - View information about Mutant Tanks.
sm_mt_absorb - View information about the Absorb ability.
sm_mt_acid - View information about the Acid ability.
sm_mt_aimless - View information about the Aimless ability.
sm_mt_ammo - View information about the Ammo ability.
sm_mt_blind - View information about the Blind ability.
sm_mt_bomb - View information about the Bomb ability.
sm_mt_bury - View information about the Bury ability.
sm_mt_car - View information about the Car ability.
sm_mt_choke - View information about the Choke ability.
sm_mt_clone - View information about the Clone ability.
sm_mt_cloud - View information about the Cloud ability.
sm_mt_drop - View information about the Drop ability.
sm_mt_drug - View information about the Drug ability.
sm_mt_drunk - View information about the Drunk ability.
sm_mt_electric - View information about the Electric ability.
sm_mt_enforce - View information about the Enforce ability.
sm_mt_fast - View information about the Fast ability.
sm_mt_fire - View information about the Fire ability.
sm_mt_fling - View information about the Fling ability.
sm_mt_fragile - View information about the Fragile ability.
sm_mt_ghost - View information about the Ghost ability.
sm_mt_god - View information about the God ability.
sm_mt_gravity - View information about the Gravity ability.
sm_mt_heal - View information about the Heal ability.
sm_mt_hit - View information about the Hit ability.
sm_mt_hurt - View information about the Hurt ability.
sm_mt_hypno - View information about the Hypno ability.
sm_mt_ice - View information about the Ice ability.
sm_mt_idle - View information about the Idle ability.
sm_mt_invert - View information about the Invert ability.
sm_mt_item - View information about the Item ability.
sm_mt_jump - View information about the Jump ability.
sm_mt_kamikaze - View information about the Kamikaze ability.
sm_mt_lag - View information about the Lag ability.
sm_mt_leech - View information about the Leech ability.
sm_mt_medic - View information about the Medic ability.
sm_mt_meteor - View information about the Meteor ability.
sm_mt_minion - View information about the Minion ability.
sm_mt_necro - View information about the Necro ability.
sm_mt_nullify - View information about the Nullify ability.
sm_mt_octal - View information about the Octal ability.
sm_mt_panic - View information about the Panic ability.
sm_mt_pimp - View information about the Pimp ability.
sm_mt_puke - View information about the Puke ability.
sm_mt_pyro - View information about the Pyro ability.
sm_mt_quiet - View information about the Quiet ability.
sm_mt_recoil - View information about the Recoil ability.
sm_mt_regen - View information about the Regen ability.
sm_mt_respawn - View information about the Respawn ability.
sm_mt_restart - View information about the Restart ability.
sm_mt_rock - View information about the Rock ability.
sm_mt_rocket - View information about the Rocket ability.
sm_mt_shake - View information about the Shake ability.
sm_mt_shield - View information about the Shield ability.
sm_mt_shove - View information about the Shove ability.
sm_mt_smash - View information about the Smash ability.
sm_mt_smite - View information about the Smite ability.
sm_mt_spam - View information about the Spam ability.
sm_mt_splash - View information about the Splash ability.
sm_mt_slow - View information about the Slow ability.
sm_mt_throw - View information about the Throw ability.
sm_mt_track - View information about the Track ability.
sm_mt_ultimate - View information about the Ultimate ability.
sm_mt_undead - View information about the Undead ability.
sm_mt_vampire - View information about the Vampire ability.
sm_mt_vision - View information about the Vision ability.
sm_mt_warp - View information about the Warp ability.
sm_mt_whirl - View information about the Whirl ability.
sm_mt_witch - View information about the Witch ability.
sm_mt_xiphos - View information about the Xiphos ability.
sm_mt_yell - View information about the Yell ability.
sm_mt_zombie - View information about the Zombie ability.
```

### Configuration Formatting
1. How many config formats are there?

At the moment, there are 4 different formats.

2. Do I need to edit my current config file from version 8.57 and below?

No, all plugins still read the original format properly.

3. Which config format should I use?

Whichever one you want. You are free to combine all of them as well, it doesn't matter. For consistency and to avoid confusion, this file and any other files with config examples will use the original format.

Example:

```
// Original format
"Mutant Tanks"
{
	"Plugin Settings"
	{
		"Game Modes"
		{
			"Game Mode Types"			"0"
		}
	}
}

// Custom format
mutanttanks // 2nd format
{
	Settings // 4th format
	{
		game_modes // 3rd format
		{
			"Game Mode Types"			0 // original format
		}
	}
}
```

### Administration System
1. How does the system work?

The administration system is designed for the usage and effectiveness of each Mutant Tank type. Basically, it controls and determines what kind of Mutant Tanks players can use or be immune from.

2. Why create an entirely new administration system instead of using SourceMod's own system?

At first, using SM's own system was the goal, but that system has certain limitations that I wanted to get rid of for this project. For example, in SM's system, assigning multiple flags to an override command requires admins to have all of those flags. In this system, admins only need one of those flags, which makes the system flexible for filtering multiple admin flags.

Example:

```
// SM's system
"sm_tank"			"abc" // Admins need all three flags to use the command.

// MT's system
"Access Flags"			"abc" // Admins only need one of these flags to access a Mutant Tank type.
```

3. What are the admin flags used for?

The flags are used for two things:
- Accessibility - What Mutant Tank types admins can access.
- Immunity - What Mutant Tank types admins are immune to.

4. What other features does the system have?

Currently, the system allows admins to each have a favorite/custom/personalized Mutant Tank type.

Each custom admin setting will override the general settings. This is a powerful feature because each admin can have his/her own custom-made Mutant Tank type without tampering with the general Mutant Tank types.

The only limitation at the moment is that admins cannot have custom/personalized ability settings. Whatever Mutant Tank type the admin spawns as, the admin will inherit that type's current abilities.

Example:

```
"Mutant Tanks"
{
	"STEAM_0:1:23456789"
	{
		"General"
		{
			"Tank Name"				"Awesome Player" // Admin-controlled Tanks will have this name.
		}
	}
	"Tank #1"
	{
		"General"
		{
			"Tank Name"				"Awesome AI" // AI Tanks will have this name.
		}
	}
}
```

5. How does the override feature work?

It will sound complicated but here is the simplest way to explain it:

Ability Overrides

```
If an ability's access/immunity flags are defined for a player, it must contain a flag that is required by one of the following:
- If a Mutant Tank type has the same ability, and that ability has access/immunity flags defined, those flags will be compared to the player's ability flags.

OR ELSE

- If a Mutant Tank type has access/immunity flags defined, those flags will be compared to the player's ability flags.

OR ELSE

- If the global access/immunity flags are defined, those flags will be compared to the player's ability flags.

Note: If all 3 of these return false, the player will not have access to that ability.
```

Type Overrides

```
If a type's access/immunity flags are defined for a player, it must contain a flag that is required by one of the following:
- If a Mutant Tank type's ability has access/immunity flags defined, those flags will be compared to the player's type flags.

OR ELSE

- If a Mutant Tank type has access/immunity flags defined, those flags will be compared to the player's type flags.

OR ELSE

- If the global access/immunity flags are defined, those flags will be compared to the player's type flags.

Note: If all 3 of these return false, the player will not have access to that type.
```

Global Overrides

```
If global access/immunity flags are defined for a player, it must contain a flag that is required by one of the following:
- If a Mutant Tank type's ability has access/immunity flags defined, those flags will be compared to the player's global flags.

OR ELSE

- If a Mutant Tank type has access/immunity flags defined, those flags will be compared to the player's global flags.

OR ELSE

- If the global access/immunity flags are defined, those flags will be compared to the player's global flags.

Note: If all 3 of these return false, the player will not have access to that type.
```

6. What is the `Allow Developer` setting for?

The setting allows the developer (Psyk0tik/Crasher_3637) to access certain features of the project on your server. These features include:
- Access to all Mutant Tanks. (Allows the developer to see what Mutant Tanks your config has.)
- Immunity from all Mutant Tanks. (Allows the developer to test each Mutant Tank without having to deal with each ability's effects.)
- Ability to spawn Mutant Tanks. (Allows the developer to spawn each Mutant Tank for testing.)
- Check which abilities are installed. (Allows the developer to check which abilities to test for.)

In short, this setting does not give the developer access to other features or plugins, thus avoiding the potential to cause trouble on your server. Disable the setting if you are not confident with trusting the developer. This setting was added to help server owners give the developer temporary access in case the developer needs to help server owners debug problems.

### Human Support
1. How do I enable human support?

Set `Human Support` to 1.

2. Can players use the abilities manually?

Yes, just set `Human Ability` to 1 for EACH ability.

Example:

```
"Mutant Tanks"
{
	"Tank #1"
	{
		"Fast Ability"
		{
			"Human Ability"				"1"
		}
	}
}
```

3. How can players use the abilities manually?

There are 4 buttons that players can use when they spawn as Mutant Tanks.

```
+use (default: E) - Main ability
+reload (default: R) - Sub/range ability
+zoom (default: Mouse3/Scroll wheel) - Special ability
+duck (default: CTRL) - Upon-death ability
```

Whatever each button activates is entirely up to your configuration settings.

4. How do I change the buttons or add extra buttons?

Edit lines 32-35 of the `mutant_tanks.inc` file and recompile each ability plugin.

5. What happens if a Mutant Tank has multiple abilities that are all activated by the same button?

All related abilities may or may not activate at the same time, depending on your configuration settings. It is recommended to not stack many abilities for human-controlled Mutant Tanks.

6. How do I limit the usage of abilities for each player?

Set the `Human Ammo` setting for each ability to whatever value you want.

Example:

```
"Mutant Tanks"
{
	"Tank #1"
	{
		"Fast Ability"
		{
			"Human Ammo"				"1"
		}
	}
}
```

7. Can I add a cooldown to the usage of abilities for each player?

Yes, just set the `Human Cooldown` setting for each ability to whatever value you want.

Example:

```
"Mutant Tanks"
{
	"Tank #1"
	{
		"Fast Ability"
		{
			"Human Cooldown"			"1"
		}
	}
}
```

8. What is the `Human Duration` setting for in some of the abilities?

That setting is a special duration for players, but they only apply if the `Human Mode` setting is set to 0.

Furthermore, there are some duration settings for abilities that will also affect players. Read the `INFORMATION.md` file for more details.

9. What is the `Human Mode` setting for in some of the abilities?

That setting is a special mode setting for players, which can determine how some abilities are activated. Read the `INFORMATION.md` file for more details.

10. Is there any way players can view information about this feature in-game?

Yes, each ability has a `sm_mt_<ability name here>` command that players can use anytime to view information about abilities.

The commands will each provide a menu that players can use to display certain information in chat.

The information displayed in chat will be more detailed and accurate when the player is playing as a Mutant Tank.

11. Is there any way players can change their current Mutant Tank type in the middle of a fight?

Yes, players can use the `sm_mutanttank` command if the `Spawn Mode` setting under the `Human Support` section under the `Plugin Settings` section is set to 0. There will be a cooldown though to prevent abuse.

12. Is there any way to exempt admins from the cooldown mentioned in question #11?

Yes, assign admins the `mt_admin` override.

Example:

```
Overrides
{
	"mt_admin"		"z" // All admins with the Root (z) flag are exempted from cooldowns.
}
```

### Configuration
1. How do I enable the custom configurations features?

Set `Enable Custom Configs` to 1.

2. How do I tell the plugin to only create certain custom config files?

Set the values in `Create Config Types`.

Examples:

```
"Create Config Types" "7" // Creates the folders and config files for each difficulty, map, and game mode.
"Create Config Types" "8" // Creates the folder and config files for each day.
"Create Config Types" "31" // Creates the folders and config files for each difficulty, map, game mode, day, and player count.
```

3. How do I tell the plugin to only execute certain custom config files?

Set the values in `Execute Config Types`.

Examples:

```
"Execute Config Types" "7" // Executes the config file for the current difficulty, map, and game mode.
"Execute Config Types" "8" // Executes the config file for the current day.
"Execute Config Types" "31" // Executes the config file for the current difficulty, map, game mode, day, and player count.
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

**nico-op** - For the [[L4D/L4D2] Infected Health Gauge (Tank & Witch & Special)](https://forums.alliedmods.net/showthread.php?t=125747) plugin.

**Silvers (Silvershot)** - For his plugins which make good references, help with gamedata signatures, and helping to optimize/fix various parts of the code.

**Lux** - For helping to optimize/fix various parts of the code and code for detecting thirdperson view.

**Milo|** - For the [Extended Map Configs](https://forums.alliedmods.net/showthread.php?t=85551) and [Dailyconfig](https://forums.alliedmods.net/showthread.php?t=84720) plugins.

**exvel** - For the [Colors](https://forums.alliedmods.net/showthread.php?t=96831) include.

**Impact** - For the [AutoExecConfig](https://forums.alliedmods.net/showthread.php?t=204254) include.

**hmmmmm** - For showing me how to pick a random character out of a dynamic string.

**Mi.Cura** - For reporting issues, suggesting ideas, and overall support.

**KasperH** - For reporting issues, suggesting ideas, and overall support.

**emsit** - For reporting issues, helping with parts of the code, and suggesting ideas.

**ReCreator** - For reporting issues and suggesting ideas.

**Princess LadyRain** - For reporting issues.

**Nekrob** - For reporting issues.

**fig101** - For reporting issues.

**AK978** - For reporting issues.

**rickfishin** - For reporting issues.

**Zytheus** - For reporting issues and suggesting ideas.

**huwong** - For reporting issues and suggesting ideas.

**foquaxticity** - For suggesting ideas.

**FatalOE71** - For suggesting ideas.

**Marttt** - For convincing me the effectiveness and usefulness of convar flags.

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



Thank you very much and have fun! :D