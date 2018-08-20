# Super Tanks++
Super Tanks++ takes the original [Super Tanks](https://forums.alliedmods.net/showthread.php?t=165858) by [Machine](https://forums.alliedmods.net/member.php?u=74752) to the next level by enabling full customization of Super Tanks to make gameplay more interesting.

## License
Super Tanks++: a L4D/L4D2 SourceMod Plugin
Copyright (C) 2018 Alfred "Crasher_3637/Psyk0tik" Llagas

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

## About
Super Tanks++ makes fighting Tanks great again!

> Super Tanks++ will enhance and intensify Tank fights by making each Tank that spawns unique and different in its own way.

### What makes Super Tanks++ viable in Left 4 Dead/Left 4 Dead 2?
Super Tanks++ enhances the experience and fun that players get from Tank fights by 2500. This plugin gives server owners an arsenal of Super Tanks to test players' skills and create a unique experience in every Tank fight.

### Requirements
1. SourceMod 1.9.0.6225 or higher
2. A dedicated server

### Installation
1. Delete files from old versions of the plugin.
2. Extract the folder inside the .zip file.
3. Place all the contents into their respective folders.
4. If prompted to replace or merge anything, click yes.
5. Load up Super Tanks++ by restarting the server.
6. Customize Super Tanks++ in:
- cfg/sourcemod/super_tanks++.cfg
- cfg/sourcemod/super_tanks++/super_tanks++.cfg.

### Uninstalling/Upgrading to Newer Versions
1. Delete super_tanks++ folder (super_tanks++.smx and all of its modules) from addons/sourcemod/plugins folder.
2. Delete super_tanks++.txt from addons/sourcemod/gamedata folder.
3. Delete super_tanks++ folder (super_tanks++.smx and all of its modules) from addons/sourcemod/scripting folder.
4. Delete super_tanks++.inc from addons/sourcemod/scripting/include folder.
5. Delete super_tanks++ folder from cfg/sourcemod folder.
6. Delete super_tanks++.cfg from cfg/sourcemod folder.
7. Follow the Installation guide above. (Only for upgrading to newer versions.)

### Disabling
1. Move super_tanks++ folder (super_tanks++.smx and all of its modules) to plugins/disabled folder.
2. Unload Super Tanks++ by restarting the server.

## Features
1. Supports multiple game modes - Provides the option to enable/disable the plugin in certain game modes.
2. Custom configurations - Provides support for custom configurations, whether per difficulty, per map, per game mode, per day, or per player count.
3. Fully customizable Super Tank types - Provides the ability to fully customize all the Super Tanks that come with the auto-generated KeyValue config file and user-made Super Tanks.
4. Create and save up to 2500 Super Tank types - Provides the ability to store up to 2500 Super Tank types that users can enable/disable.
5. Easy-to-use config file - Provides a user-friendly KeyValues config file that users can easily understand and edit.
6. Config auto-reloader - Provides the feature to auto-reload the config file when users change settings mid-game.
7. Optional abilities - Provides the option to choose which abilities to install.
8. Forwards and natives - Provides the ability to allow users to add their own abilities and features through the use of forwards and natives.

## ConVars
```
// Enable Super Tanks++.
// 0: OFF
// 1: ON
// -
// Default: "1"
st_enableplugin "1"
```

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
3. Automatically generate config files for all difficulties specified by z_difficulty.
4. Automatically generate config files for all maps installed on the server.
5. Automatically generate config files for all game modes specified by sv_gametypes and mp_gamemode.
6. Automatically generate config files for all days.
7. Automatically generate config files for up to 66 players.

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
	"Tank 25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Enabled"			"1" // Tank is enabled.
			"Skin-Glow Colors"		"255,0,0,255|255,255,0" // Tank has a red (skin) and yellow (glow outline) color scheme.
		}
	}
}
```

This is not okay:
```
"Super Tanks++"
{
	"Tank 25"
	{
		"General"
		{
			// "Tank Enabled" is missing so this entry is disabled.
			"Tank Name"				"Test Tank" // Tank has a name.
			"Skin-Glow Colors"		"255,0,0,255|255,255,0" // Tank has a red (skin) and yellow (glow outline) color scheme.
		}
	}
}
```

This is okay:
```
"Super Tanks++"
{
	"Tank 25"
	{
		"General"
		{
			// Since "Tank Name" is missing, the default name for this entry will be "Tank"
			"Tank Enabled"			"1" // Tank is enabled.
			"Skin-Glow Colors"		"255,0,0,255|255,255,0" // Tank has a red (skin) and yellow (glow outline) color scheme.
		}
	}
}
```

This is not okay:
```
"Super Tanks++"
{
	"Tank 25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Tank has a name.
			"Tank Enabled"			"1" // Tank is enabled.
			"Skin-Glow Colors"		"255, 0, 0, 255 | 255, 255, 0" // The string should not contain any spaces.
		}
	}
}
```

- Adding the entry to the roster.

Here's our final entry:
```
"Super Tanks++"
{
	"Tank 25"
	{
		"General"
		{
			"Tank Name"				"Test Tank" // Named "Test Tank".
			"Tank Enabled"			"1" // Entry is enabled.
			"Skin-Glow Colors"		"255,0,0,255|255,255,0" // Has red/yellow color scheme.
		}
		"Immunities"
		{
			"Fire Immunity"			"1" // Immune to fire.
		}
	}
}
```

To make sure that this entry can be chosen, we must go to the "Plugin Settings" section and look for the "Maximum Types" setting in the "General" subsection.

```
"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Maximum Types"			"24" // Determines what entry to stop at when reading the entire config file.
		}
	}
}
```

Now, assuming that "Tank 25" is our highest entry, we just raise the value of "Maximum Types" by 1, so we get 25 entries to choose from. Once the plugin starts reading the config file, when it gets to "Tank 25" it will stop reading the rest.

- Advanced Entry Examples

```
"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Maximum Types"			"5" // Check "Tank 1" to "Tank 5"
		}
	}
	"Tank 5" // Checked by the plugin.
	{
		"General"
		{
			"Tank Name"				"Airborne Tank"
			"Tank Enabled"			"1"
			"Skin-Glow Colors"		"255,255,0,255|255,255,0"
		}
		"Enhancements"
		{
			"Extra Health"			"50" // Tank's base health + 50
		}
		"Jump Ability"
		{
			"Ability Enabled"		"1"
			"Jump Chance"			"1"
		}
	}
}

"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Maximum Types"			"11" // Only check for the first 11 Tank types. ("Tank 1" to "Tank 11")
		}
	}
	"Tank 13" // This will not be checked by the plugin.
	{
		"General"
		{
			"Tank Name"				"Invisible Tank"
			"Tank Enabled"			"1"
			"Skin-Glow Colors"		"255,255,255,255|255,255,255"
			"Glow Effect"			"0" // No glow outline.
		}
		"Immunities"
		{
			"Fire Immunity"			"1" // Immune to fire.
		}
		"Ghost Ability"
		{
			"Ability Enabled"		"1"
			"Fade Limit"			"0"
		}
	}
	"Tank 10" // Checked by the plugin.
	{
		"General"
		{
			"Tank Enabled"			"1"
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
- You have created a new Super Tank and didn't raise the value of the "Maximum Types" KeyValue.
- You have misspelled one of the KeyValues settings.
- You are still using the "Tank Character" KeyValue which is no longer used since v8.16.
- You didn't set up the Super Tank properly.
- You are missing quotation marks.
- You have more than 2500 Super Tanks in your config file.
- You didn't format your config file properly.

5. How do I kill the Tanks depending on what abilities they have?

The following abilities require different strategies:

- Absorb Ability: The Super Tank takes way less damage.
- God Ability: The Super Tank will have god mode temporarily and will not take any damage at all until the effect ends.
- Bullet Immunity: Forget your guns. Just spam your grenade launcher at it, slash it with an axe or crowbar, or burn it to death.
- Explosive Immunity: Forget explosives and just focus on gunfire, melee weapons, and molotovs/gascans.
- Fire Immunity: No more barbecued Tanks.
- Melee Immunity: No more Gordon Freeman players (immune to melee weapons including crowbar).
- Nullify Hit: The Super Tank can mark players as useless, which means as long as that player is nullified, they will not do any damage.
- Shield Ability: Wait for the Tank to throw propane tanks at you and then throw it back at the Tank. Then shoot the propane tank to deactivate the Tank's shield.

6. How do I make the plugin work on only finale maps?

Set the value of the "Finales Only" KeyValue to 1.

7. How can I change the amount of Tanks that spawn on each finale wave?

Here's an example:

```
"Tank Waves" "2,3,4" // Spawn 2 Tanks on the 1st wave, 3 Tanks on the 2nd wave, and 4 Tanks on the 3rd wave.
```

8. How can I decide whether to display each Tank's health?

Set the value in the "Display Health" KeyValue.

9. How do I give each Tank more health?

Set the value in the "Extra Health" KeyValue.

Example:

```
"Extra Health" "5000" // Add 5000 to the Super Tank's health.
```

10. How do I adjust each Tank's run speed?

Set the value in the "Run Speed" KeyValue.

Example:

```
"Run Speed" "3.0" // Add 2.0 to the Super Tank's run speed. Default run speed is 1.0.
```

11. How can I give each Tank bullet immunity?

Set the value of the "Bullet Immunity" KeyValue to 1.

12. How can I give each Tank explosive immunity?

Set the value of the "Explosive Immunity" KeyValue to 1.

13. How can I give each Tank fire immunity?

Set the value of the "Fire Immunity" KeyValue to 1.

14. How can I give each Tank melee immunity?

Set the value of the "Melee Immunity" KeyValue to 1.

15. How can I delay the throw interval of each Tank?

Set the value in the "Throw Interval" KeyValue.

Example:

```
"Throw Interval" "8.0" // Add 3.0 to the Super Tank's throw interval. Default throw interval is 5.0.
```

16. Why do some Tanks spawn with different props?

Each prop has 1 out of X chances to appear on Super Tanks when they spawn. Configure the chances for each prop in the "Props Chance" KeyValue.

17. Why are the Tanks spawning with more than the extra health given to them?

Since v8.10, extra health given to Tanks is now multiplied by the number of alive non-idle human survivors present when the Tank spawns.

18. How do I add more Super Tanks?

- Add a new entry in the config file.
- Raise the value of the "Maximum Types" KeyValue.

Example:

```
"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Maximum Types"		"69" // The plugin will check for 69 entries when loading the config file.
		}
	}
	"Tank 69"
	{
		"General"
		{
			"Tank Enabled"		"1" // Tank 69 is enabled and can be chosen.
		}
	}
}
```

19. How do I filter out certain Super Tanks that I made without deleting them?

Enable/disable them with the "Tank Enabled" KeyValue.

Example:

```
"Super Tanks++"
{
	"Tank 1"
	{
		"General"
		{
			"Tank Enabled"		"1" // Tank 1 can be chosen.
		}
	}
	"Tank 2"
	{
		"General"
		{
			"Tank Enabled"		"0" // Tank 2 cannot be chosen.
		}
	}
	"Tank 3"
	{
		"General"
		{
			"Tank Enabled"		"0" // Tank 3 cannot be chosen.
		}
	}
	"Tank 4"
	{
		"General"
		{
			"Tank Enabled"		"1" // Tank 4 can be chosen.
		}
	}
}
```

20. Can I create temporary Tanks without removing or replacing them?

Yes, you can do that with custom configs.

Example:

```
// Settings for cfg/sourcemod/super_tanks++/super_tanks++.cfg
"Super Tanks++"
{
	"Plugin Settings"
	{
		"General"
		{
			"Enable Custom Configs"			"1" // Enable custom configs
			"Execute Config Types"			"1" // 1: Difficulty configs (easy, normal, hard, impossible)
		}
	}
	"Tank 69"
	{
		"General"
		{
			"Tank Name"						"Psyk0tik Tank"
			"Tank Enabled"					"1"
			"Skin-Glow Colors"				"0,170,255,255|0,170,255"
		}
		"Enhancements"
		{
			"Extra Health"					"250"
		}
		"Immunities"
		{
			"Fire Immunity"					"1"
		}
	}
}

// Settings for cfg/sourcemod/super_tanks++/difficulty_configs/impossible.cfg
"Super Tanks++"
{
	"Tank 69"
	{
		"General"
		{
			"Tank Name"						"Idiot Tank"
			"Tank Enabled"					"1"
			"Skin-Glow Colors"				"1,1,1,255|1,1,1"
		}
		"Enhancements"
		{
			"Extra Health"					"1"
		}
		"Immunities"
		{
			"Fire Immunity"					"0"
		}
	}
}

Output: When the current difficulty is Expert mode (impossible), the Idiot Tank will spawn instead of Psyk0tik Tank as long as custom configs is being used.

These are basically temporary Tanks that you can create for certain situations, like if there's 5 players on the server, the map is c1m1_hotel, or even if the day is Thursday, etc.
```

21. How can I move the Super Tanks++ category around on the admin menu?

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

22. Are there any developer/tester features available in the plugin?

Yes, there are forwards, natives, stocks, target filters for each special infected, and admin commands that allow developers/testers to spawn each Super Tank and see their statuses.

Forwards:
```
/* Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param client		Client index of the Tank.
 */
forward void ST_Ability(int client);

/* Called when the Super Tank evolves.
 * Use this forward to trigger any features/abilities/settings
 * when a Super Tank evolves.
 *
 * @param client		Client index of the Tank.
 */
forward void ST_BossStage(int client);

/* Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param limit			The limit for how many
 *							Super Tank types' settings
 *							to check for.
 * @param main			Checks whether the main config
 *							or a custom config
 *							is being used.
 */
forward void ST_Configs(char[] savepath, int limit, bool main);

/* Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 */
forward void ST_Event(Event event, const char[] name);

/* Called when the Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 */
forward void ST_RockBreak(int client, int entity);

/* Called when the Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 */
forward void ST_RockThrow(int client, int entity);

/* Called when the Tank spawns.
 * Use this forward for any one-time abilities
 * or on-spawn presets.
 *
 * @param client		Client index of the Tank.
 */
forward void ST_Spawn(int client);
```

Natives:
```
/* Returns the value of the "Maximum Types" setting.
 *
 * @return				The value of the
 *							"Maximum Types" setting.
 */
native int ST_MaxTypes();

/* Returns the status of the core plugin.
 *
 * @return				True on success, false if
 *							core plugin is disabled.
 */
native bool ST_PluginEnabled();

/* Spawns a Tank with the specified Super Tank type.
 *
 * @param client		Client index of the Tank.
 * @param type			Type of Super Tank.
 */
native void ST_SpawnTank(int client, int type);

/* Returns the status of the "Human Super Tanks" setting.
 *
 * @param client		Client index of the Tank.
 *
 * @return				True on success, false if
 *							the setting is disabled.
 */
native bool ST_TankAllowed(int client);

/* Returns the Super Tank type of the Tank.
 *
 * @param client		Client index of the Tank.
 *
 * @return				The Tank's Super Tank type.
 */
native int ST_TankType(int client);
```

Stocks:
```
stock bool bHasIdlePlayer(int client)
{
	char sClassname[12];
	GetEntityNetClass(client, sClassname, sizeof(sClassname));
	if (strcmp(sClassname, "SurvivorBot") == 0)
	{
		int iSpectatorUserId = GetEntProp(client, Prop_Send, "m_humanSpectatorUserID");
		if (iSpectatorUserId > 0)
		{
			int iIdler = GetClientOfUserId(iSpectatorUserId);
			if (iIdler > 0 && IsClientInGame(iIdler) && !IsFakeClient(iIdler) && (GetClientTeam(iIdler) != 2))
			{
				return true;
			}
		}
	}
	return false;
}

stock bool bIsBoomer(int client)
{
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 2;
}

stock bool bIsBotIdle(int client)
{
	return bIsSurvivor(client) && IsFakeClient(client) && bHasIdlePlayer(client);
}

stock bool bIsBotIdleSurvivor(int client)
{
	return bIsSurvivor(client) && IsFakeClient(client) && !bHasIdlePlayer(client);
}

stock bool bIsBotSurvivor(int client)
{
	return bIsSurvivor(client) && IsFakeClient(client);
}

stock bool bIsCharger(int client)
{
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 6;
}

stock bool bIsFinaleMap()
{
	return FindEntityByClassname(-1, "trigger_finale") != -1;
}

stock bool bIsHumanSurvivor(int client)
{
	return bIsSurvivor(client) && !IsFakeClient(client) && !bHasIdlePlayer(client) && !bIsPlayerIdle(client);
}

stock bool bIsHunter(int client)
{
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 3;
}

stock bool bIsIdlePlayer(int bot, int client)
{
	return bIsValidClient(client) && !IsFakeClient(client) && GetClientTeam(bot) == 2;
}

stock bool bIsInfected(int client)
{
	return bIsValidClient(client) && GetClientTeam(client) == 3;
}

stock bool bIsJockey(int client)
{
	return bIsInfected(client) && bIsL4D2Game() && GetEntProp(client, Prop_Send, "m_zombieClass") == 5;
}

stock bool bIsL4D2Game()
{
	return GetEngineVersion() == Engine_Left4Dead2;
}

stock bool bIsPlayerBurning(int client)
{
	if (GetEntPropFloat(client, Prop_Send, "m_burnPercent") > 0.0 || GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerGrounded(int client)
{
	if (GetEntProp(client, Prop_Send, "m_fFlags") & FL_ONGROUND)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerIdle(int client)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!IsClientInGame(iPlayer) || GetClientTeam(iPlayer) != 2 || !IsFakeClient(iPlayer) || !bHasIdlePlayer(iPlayer))
		{
			continue;
		}
		char sClassname[12];
		GetEntityNetClass(iPlayer, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "SurvivorBot") == 0)
		{
			int iSpectatorUserId = GetEntProp(iPlayer, Prop_Send, "m_humanSpectatorUserID");
			if (iSpectatorUserId > 0)
			{
				int iIdler = GetClientOfUserId(iSpectatorUserId);
				if (iIdler == client)
				{
					return true;
				}
			}
		}
	}
	return false;
}

stock bool bIsPlayerIncapacitated(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
	{
		return true;
	}
	return false;
}

int g_iCurrentMode;
stock bool bIsPluginEnabled(ConVar convar, int mode, char[] enabled, char[] disabled)
{
	if (convar == null)
	{
		return false;
	}
	if (mode != 0)
	{
		g_iCurrentMode = 0;
		int iGameMode = CreateEntityByName("info_gamemode");
		DispatchSpawn(iGameMode);
		HookSingleEntityOutput(iGameMode, "OnCoop", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnSurvival", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnVersus", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnScavenge", vGameMode, true);
		ActivateEntity(iGameMode);
		AcceptEntityInput(iGameMode, "PostSpawnActivate");
		AcceptEntityInput(iGameMode, "Kill");
		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}
	char sGameMode[32];
	char sGameModes[513];
	convar.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);
	if (strcmp(enabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", enabled);
		if (StrContains(sGameModes, sGameMode, false) == -1)
		{
			return false;
		}
	}
	if (strcmp(disabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", disabled);
		if (StrContains(sGameModes, sGameMode, false) != -1)
		{
			return false;
		}
	}
	return true;
}

stock bool bIsSmoker(int client)
{
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 1;
}

stock bool bIsSpecialInfected(int client)
{
	if (bIsSmoker(client) || bIsBoomer(client) || bIsHunter(client) || bIsSpitter(client) || bIsJockey(client) || bIsCharger(client))
	{
		return true;
	}
	return false;
}

stock bool bIsSpitter(int client)
{
	return bIsInfected(client) && GetEntProp(client, Prop_Send, "m_zombieClass") == 4;
}

stock bool bIsSurvivor(int client)
{
	return bIsValidClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}

stock bool bIsTank(int client)
{
	return bIsInfected(client) && (bIsL4D2Game() ? GetEntProp(client, Prop_Send, "m_zombieClass") == 8 : GetEntProp(client, Prop_Send, "m_zombieClass") == 5);
}

stock bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

stock bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

stock bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

stock bool bIsValidHumanClient(int client)
{
	return bIsValidClient(client) && !IsFakeClient(client);
}

stock bool bIsWitch(int client)
{
	if (IsValidEntity(client))
	{
		char sClassname[32];
		GetEntityClassname(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "witch") == 0)
		{
			return true;
		}
	}
	return false;
}

public bool bBoomerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsBoomer(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bChargerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsCharger(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bHunterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsHunter(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bJockeyFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsJockey(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSmokerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSmoker(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSpitterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpitter(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bTankFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer) && IsPlayerAlive(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bTraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data)
	{
		return false;
	}
	return true;
}

public bool bTraceRayDontHitSelfAndPlayer(int entity, int mask, any data)
{
	if (entity == data || bIsValidClient(entity))
	{
		return false;
	}
	return true;
}

public bool bTraceRayDontHitSelfAndSurvivor(int entity, int mask, any data)
{
	if (entity == data || bIsSurvivor(entity))
	{
		return false;
	}
	return true;
}

stock bool bVisiblePosition(float pos1[3], float pos2[3], int entity, int flag)
{
	Handle hTrace;
	switch (flag)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndSurvivor, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndPlayer, entity);
	}
	if (TR_DidHit(hTrace))
	{
		return false;
	}
	delete hTrace;
	return true;
}

stock float flGetAngle(float angle1[3], float angle2[3])
{
	return ArcCosine(GetVectorDotProduct(angle1, angle2) / (GetVectorLength(angle1) * GetVectorLength(angle2)));
}

stock float flGetDistance(float pos[3], float angle[3], float offset1, float offset2, float force[3], int entity, int trace) 
{
	float flAngle[3];
	vCopyVector(angle, flAngle);
	flAngle[0] += offset1;
	flAngle[1] += offset2;
	GetAngleVectors(flAngle, force, NULL_VECTOR, NULL_VECTOR);
	float flDistance = flGetRayDistance(pos, flAngle, entity, trace);
	return flDistance;
}

stock float flGetGroundUnits(int entity)
{
	if (!(GetEntityFlags(entity) & FL_ONGROUND))
	{ 
		Handle hTrace;
		float flOrigin[3];
		float flPosition[3];
		float flDown[3] = {90.0, 0.0, 0.0};
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);
		hTrace = TR_TraceRayFilterEx(flOrigin, flDown, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, bTraceRayDontHitSelf, entity);
		if (TR_DidHit(hTrace))
		{
			float flUnits;
			TR_GetEndPosition(flPosition, hTrace);
			flUnits = flOrigin[2] - flPosition[2];
			delete hTrace;
			return flUnits;
		}
		delete hTrace;
	}
	return 0.0;
}

stock float flGetRayDistance(float pos[3], float angle[3], int entity, int trace)
{
	float flHitPos[3];
	iGetRayHitPos(pos, angle, flHitPos, entity, false, trace);
	return GetVectorDistance(pos, flHitPos);
}

stock float flSetFloatLimit(float value, float min, float max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

stock int iGetBotSurvivor()
{
	for (int iBot = MaxClients; iBot >= 1; iBot--)
	{
		if (bIsBotSurvivor(iBot))
		{
			return iBot;
		}
	}
	return -1;
}

stock int iGetHumanCount()
{
	int iHumanCount;
	for (int iHuman = 1; iHuman <= MaxClients; iHuman++)
	{
		if (bIsHumanSurvivor(iHuman))
		{
			iHumanCount++;
		}
	}
	return iHumanCount;
}

stock int iGetIdleBot(int client)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == client)
		{
			return iBot;
		}
	}
	return 0;
}

stock int iGetIdlePlayer(int client)
{
	if (bIsBotSurvivor(client))
	{
		char sClassname[12];
		GetEntityNetClass(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "SurvivorBot") == 0)
		{
			int iIdler = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
			if (iIdler > 0 && IsClientInGame(iIdler) && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}
	return 0;
}

stock int iGetNearestSurvivor(int client)
{
	float flDistance = 0.0;
	float flNearest = 0.0;
	float flPlayerPos[3];
	float flTargetPos[3];
	if (bIsValidClient(client))
	{
		GetClientAbsOrigin(client, flPlayerPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				GetClientAbsOrigin(iSurvivor, flTargetPos);
				flDistance = GetVectorDistance(flPlayerPos, flTargetPos);
				if (flNearest == 0.0 || flNearest > flDistance)
				{
					flNearest = flDistance;
				}
			}
		}
	}
	return RoundFloat(flDistance);
}

stock int iGetPlayerCount()
{
	int iPlayerCount;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidHumanClient(iPlayer))
		{
			iPlayerCount++;
		}
	}
	return iPlayerCount;
}

stock int iGetRandomSurvivor(int client)
{
	int iSurvivorCount;
	int iSurvivors[MAXPLAYERS + 1];
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && iSurvivor != client)
		{
			iSurvivors[iSurvivorCount++] = iSurvivor;
		}
	}
	return iSurvivors[GetRandomInt(0, iSurvivorCount - 1)];
}

stock int iGetRandomTarget(float pos[3], float angle[3])
{
	float flMin = 4.0;
	float flPos[3];
	float flAngle;
	int iTarget;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			GetClientEyePosition(iSurvivor, flPos);
			MakeVectorFromPoints(pos, flPos, flPos);
			flAngle = flGetAngle(angle, flPos);
			if (flAngle <= flMin)
			{
				flMin = flAngle;
				iTarget = iSurvivor;
			}
		}
	}
	return iTarget;
}

stock int iGetRayHitPos(float pos[3], float angle[3], float hitpos[3], int entity = 0, bool offset = false, int trace)
{
	int iHit = 0;
	Handle hTrace;
	switch (trace)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndPlayer, entity);
		case 3: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndSurvivor, entity);
	}
	if (TR_DidHit(hTrace))
	{
		TR_GetEndPosition(hitpos, hTrace);
		iHit = TR_GetEntityIndex(hTrace);
	}
	delete hTrace;
	if (offset)
	{
		float flVector[3];
		MakeVectorFromPoints(hitpos, pos, flVector);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, 15.0);
		AddVectors(hitpos, flVector, hitpos);
	}
	return iHit;
}

stock int iGetRGBColor(int red, int green, int blue) 
{
	return (blue * 65536) + (green * 256) + red;
}

stock int iGetWitchCount()
{
	int iWitchCount;
	int iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}
	return iWitchCount;
}

stock int iSetCellLimit(int value, int min, int max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

stock void vAttachParticle(int client, char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vCheatCommand(int client, char[] command, char[] arguments = "", any ...)
{
	int iCmdFlags = GetCommandFlags(command);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, iCmdFlags|FCVAR_CHEAT);
}

stock void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

stock void vCreateParticle(int client, char[] particlename, float time, float origin)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vDamage(int client, char[] damage)
{
	int iPointHurt = CreateEntityByName("point_hurt");
	if (bIsValidEntity(iPointHurt))
	{
		DispatchKeyValue(client, "targetname", "hurtme");
		DispatchKeyValue(iPointHurt, "Damage", damage);
		DispatchKeyValue(iPointHurt, "DamageTarget", "hurtme");
		DispatchKeyValue(iPointHurt, "DamageType", "2");
		DispatchSpawn(iPointHurt);
		AcceptEntityInput(iPointHurt, "Hurt", client);
		AcceptEntityInput(iPointHurt, "Kill");
		DispatchKeyValue(client, "targetname", "donthurtme");
	}
}

stock void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

stock void vFade(int client, int duration, int unknown, int red, int green, int blue)
{
	Handle hFadeTarget = StartMessageOne("Fade", client);
	if (hFadeTarget != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hFadeTarget);
		bfWrite.WriteShort(duration);
		bfWrite.WriteShort(unknown);
		bfWrite.WriteShort((0x0010|0x0001));
		bfWrite.WriteByte(red);
		bfWrite.WriteByte(green);
		bfWrite.WriteByte(blue);
		bfWrite.WriteByte(150);
		EndMessage();
	}
}

public void vGameMode(const char[] output, int caller, int activator, float delay)
{
	if (strcmp(output, "OnCoop") == 0)
	{
		g_iCurrentMode = 1;
	}
	else if (strcmp(output, "OnVersus") == 0)
	{
		g_iCurrentMode = 2;
	}
	else if (strcmp(output, "OnSurvival") == 0)
	{
		g_iCurrentMode = 4;
	}
	else if (strcmp(output, "OnScavenge") == 0)
	{
		g_iCurrentMode = 8;
	}
}

stock void vGetCurrentCount(char[] config)
{
	int iPlayerCount = iGetPlayerCount();
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iPlayerCount);
}

stock void vGetCurrentDay(char[] config)
{
	char sDay[9];
	char sDayNumber[2];
	FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
	int iDayNumber = StringToInt(sDayNumber);
	switch (iDayNumber)
	{
		case 6: sDay = "saturday";
		case 5: sDay = "friday";
		case 4: sDay = "thursday";
		case 3: sDay = "wednesday";
		case 2: sDay = "tuesday";
		case 1: sDay = "monday";
		default: sDay = "sunday";
	}
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/daily_configs/%s.cfg", sDay);
}

stock void vGetCurrentDifficulty(ConVar convar, char[] config)
{
	char sDifficulty[11];
	convar.GetString(sDifficulty, sizeof(sDifficulty));
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
}

stock void vGetCurrentMap(char[] config)
{
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	Format(config, strlen(config), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
}

stock void vGetCurrentMode(ConVar convar, char[] config)
{
	char sMode[64];
	convar.GetString(sMode, sizeof(sMode));
	Format(config, strlen(config), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
}

stock void vGhost(int client, int slot)
{
	if (bIsSurvivor(client) && GetPlayerWeaponSlot(client, slot) > 0)
	{
		SDKHooks_DropWeapon(client, GetPlayerWeaponSlot(client, slot), NULL_VECTOR, NULL_VECTOR);
	}
}

stock void vGhostDrop(int client, char[] slots, char[] number, int slot)
{
	if (StrContains(slots, number) != -1)
	{
		vGhost(client, slot);
	}
}

stock void vHeal(int client, int health, int extrahealth, int maxhealth)
{
	maxhealth = iSetCellLimit(maxhealth, 1, ST_MAXHEALTH);
	int iExtraHealth = (extrahealth > maxhealth) ? maxhealth : extrahealth;
	int iExtraHealth2 = (extrahealth < health) ? 1 : extrahealth;
	int iRealHealth = (extrahealth >= 0) ? iExtraHealth : iExtraHealth2;
	SetEntityHealth(client, iRealHealth);
}

stock void vMultiTargetFilters(int toggle)
{
	switch (toggle)
	{
		case 0:
		{
			RemoveMultiTargetFilter("@smokers", bSmokerFilter);
			RemoveMultiTargetFilter("@boomers", bBoomerFilter);
			RemoveMultiTargetFilter("@hunters", bHunterFilter);
			RemoveMultiTargetFilter("@spitters", bSpitterFilter);
			RemoveMultiTargetFilter("@jockeys", bJockeyFilter);
			RemoveMultiTargetFilter("@chargers", bChargerFilter);
			RemoveMultiTargetFilter("@tanks", bTankFilter);
		}
		case 1:
		{
			AddMultiTargetFilter("@smokers", bSmokerFilter, "all Smokers", false);
			AddMultiTargetFilter("@boomers", bBoomerFilter, "all Boomers", false);
			AddMultiTargetFilter("@hunters", bHunterFilter, "all Hunters", false);
			AddMultiTargetFilter("@spitters", bSpitterFilter, "all Spitters", false);
			AddMultiTargetFilter("@jockeys", bJockeyFilter, "all Jockeys", false);
			AddMultiTargetFilter("@chargers", bChargerFilter, "all Chargers", false);
			AddMultiTargetFilter("@tanks", bTankFilter, "all Tanks", false);
		}
	}
}

stock void vPrecacheParticle(char[] particlename)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(iParticle))
	{
		DispatchKeyValue(iParticle, "effect_name", particlename);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "Start");
		vSetEntityParent(iParticle, iParticle);
		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle);
	}
}

stock void vSetEntityParent(int entity, int parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}

stock void vSetVector(float target[3], float x, float y, float z)
{
	target[0] = x;
	target[1] = y;
	target[2] = z;
}

stock void vShake(int client, float duration = 1.0)
{
	Handle hShakeTarget = StartMessageOne("Shake", client);
	if (hShakeTarget != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hShakeTarget);
		bfWrite.WriteByte(0);
		bfWrite.WriteFloat(16.0);
		bfWrite.WriteFloat(0.5);
		bfWrite.WriteFloat(duration);
		EndMessage();
	}
}

stock void vSpawnInfected(int client, char[] infected)
{
	ChangeClientTeam(client, 3);
	vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", infected);
	KickClient(client);
}

stock void vSpecialAttack(int client, float pos[3], char[] model)
{
	int iProp = CreateEntityByName("prop_physics");
	if (bIsValidEntity(iProp))
	{
		DispatchKeyValue(iProp, "disableshadows", "1");
		SetEntityModel(iProp, model);
		pos[2] += 10.0;
		TeleportEntity(iProp, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iProp);
		SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(iProp, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
		SetEntProp(iProp, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iProp, 0, 0, 0, 0);
		AcceptEntityInput(iProp, "Break");
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
```

Commands:

```
1. sm_tank <type 1-*> *The maximum value is determined by the value of the "Maximum Types" KeyValue. (The highest value you can set is 2500 though.)
2. sm_tanklist
```

Additionally, there is also a setting called "Create Backup" which users can use to create a backup copy of the main config file in case they want to test or mess around with the settings.

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
**Machine** - For the original [Super Tanks](https://forums.alliedmods.net/showthread.php?t=165858) by [Machine](https://forums.alliedmods.net/member.php?u=74752).

**NgBUCKWANGS** - For the mapname.cfg code in his [ABM](https://forums.alliedmods.net/showthread.php?t=291562) plugin.

**Spirit_12** - For the L4D signatures for the gamedata file.

**honorcode** - For the [New Custom Commands](https://forums.alliedmods.net/showthread.php?p=1251446) plugin.

**panxiaohai** - For the [We Can Not Survive Alone](https://forums.alliedmods.net/showthread.php?t=167389), [Melee Weapon Tank](https://forums.alliedmods.net/showthread.php?t=166356), and [Tank's Power](https://forums.alliedmods.net/showthread.php?p=1262968) plugins.

**strontiumdog** - For the [Evil Admin: Mirror Damage](https://forums.alliedmods.net/showthread.php?p=702913), [Evil Admin: Pimp Slap](https://forums.alliedmods.net/showthread.php?p=702914), [Evil Admin: Rocket](https://forums.alliedmods.net/showthread.php?t=79617), and [Evil Admin: Vision](https://forums.alliedmods.net/showthread.php?p=702918) plugins.

**Marcus101RR** - For the code to set a player's weapon's ammo.

**AtomicStryker** - For the [SM Respawn Command](https://forums.alliedmods.net/showthread.php?p=862618) and [Boomer Splash Damage](https://forums.alliedmods.net/showthread.php?p=884839) plugins.

**ivailosp and V10** - For the [[L4D] Away](https://forums.alliedmods.net/showthread.php?p=760339) and [[L4D2] Away](https://forums.alliedmods.net/showthread.php?p=2005618) plugins.

**mi123645** - For the [4+ Survivor AFK Fix](https://forums.alliedmods.net/showthread.php?p=1239549) plugin.

**Farbror Godis** - For the [Curse](https://forums.alliedmods.net/showthread.php?p=2402076) plugin.

**ztar** - For the [Last Boss](https://forums.alliedmods.net/showthread.php?t=129013?t=129013) plugin.

**IxAvnoMonvAxI** - For the [Last Boss Extended](https://forums.alliedmods.net/showpost.php?p=1463486&postcount=2) plugin.

**Uncle Jessie** - For the Tremor Tank in his [Last Boss Extended revision](https://forums.alliedmods.net/showpost.php?p=2570108&postcount=73).

**Drixevel** - For the [Force Active Weapon](https://forums.alliedmods.net/showthread.php?p=2493284) plugin.

**pRED** - For the [SM Super Commands](https://forums.alliedmods.net/showthread.php?p=498802) plugin.

**sheo** - For the [Fix Frozen Tanks](https://forums.alliedmods.net/showthread.php?p=2133193) plugin.

**Silvers (Silvershot)** - For the code that allows users to enable/disable the plugin in certain game modes, help with gamedata signatures, the code to prevent Tanks from damaging themselves and other infected with their own abilities, and helping to optimize/fix various parts of the code.

**Lux** - For helping to optimize/fix various parts of the code.

**Milo|** - For the code that automatically generates config files for each day and each map installed on a server.

**hmmmmm** - For showing me how to pick a random character out of a dynamic string.

**Mi.Cura** - For reporting issues, giving me ideas, and overall support.

**KasperH** - For reporting issues, giving me ideas, and overall support.

**emsit** - For reporting issues and helping with parts of the code.

**ReCreator** - For reporting issues.

**AngelAce113** - For the default colors, testing each Tank type, giving me ideas, and overall support.

**Sipow** - For the default colors and overall support.

**SourceMod Team** - For the beacon, blind, drug, and ice source codes.

# Contact Me
If you wish to contact me for any questions, concerns, suggestions, or criticism, I can be found here:
- [AlliedModders Forum](https://forums.alliedmods.net/member.php?u=181166)
- [Steam](https://steamcommunity.com/profiles/76561198056665335)
- Psyk0tik#7757 on Discord

# 3rd-Party Revisions Notice
If you would like to share your own revisions of this plugin, please rename the files! I do not want to create confusion for end-users and it will avoid conflict and negative feedback on the official versions of my work. If you choose to keep the same file names for your revisions, it will cause users to assume that the official versions are the source of any problems your revisions may have. This is to protect you (the reviser) and me (the developer)! Thank you!

# Donate
- [Donate to SourceMod](https://www.sourcemod.net/donate.php)

Thank you very much! :)