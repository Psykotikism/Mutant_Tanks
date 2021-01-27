/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if defined _mutanttanks_included
	#endinput
#endif
#define _mutanttanks_included

#include <sdktools>

public SharedPlugin __pl_mutanttanks = 
{
	name = "mutant_tanks",
	file = "mutant_tanks.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_mutanttanks_SetNTVOptional()
{
	MarkNativeAsOptional("MT_CanTypeSpawn");
	MarkNativeAsOptional("MT_DetonateTankRock");
	MarkNativeAsOptional("MT_DoesTypeRequireHumans");
	MarkNativeAsOptional("MT_GetAccessFlags");
	MarkNativeAsOptional("MT_GetCombinationSetting");
	MarkNativeAsOptional("MT_GetCurrentFinaleWave");
	MarkNativeAsOptional("MT_GetGlowRange");
	MarkNativeAsOptional("MT_GetGlowType");
	MarkNativeAsOptional("MT_GetImmunityFlags");
	MarkNativeAsOptional("MT_GetMaxType");
	MarkNativeAsOptional("MT_GetMinType");
	MarkNativeAsOptional("MT_GetPropColors");
	MarkNativeAsOptional("MT_GetRunSpeed");
	MarkNativeAsOptional("MT_GetScaledDamage");
	MarkNativeAsOptional("MT_GetSpawnType");
	MarkNativeAsOptional("MT_GetTankColors");
	MarkNativeAsOptional("MT_GetTankName");
	MarkNativeAsOptional("MT_GetTankType");
	MarkNativeAsOptional("MT_HasAdminAccess");
	MarkNativeAsOptional("MT_HasChanceToSpawn");
	MarkNativeAsOptional("MT_HideEntity");
	MarkNativeAsOptional("MT_IsAdminImmune");
	MarkNativeAsOptional("MT_IsCorePluginEnabled");
	MarkNativeAsOptional("MT_IsCustomTankSupported");
	MarkNativeAsOptional("MT_IsFinaleType");
	MarkNativeAsOptional("MT_IsGlowEnabled");
	MarkNativeAsOptional("MT_IsGlowFlashing");
	MarkNativeAsOptional("MT_IsNonFinaleType");
	MarkNativeAsOptional("MT_IsTankIdle");
	MarkNativeAsOptional("MT_IsTankSupported");
	MarkNativeAsOptional("MT_IsTypeEnabled");
	MarkNativeAsOptional("MT_LogMessage");
	MarkNativeAsOptional("MT_SetTankType");
	MarkNativeAsOptional("MT_SpawnTank");
	MarkNativeAsOptional("MT_TankMaxHealth");
}
#endif

// Core plugin information
#define MT_NAME "Mutant Tanks"
#define MT_AUTHOR "Psyk0tik (Crasher_3637)"
#define MT_DESCRIPTION "Mutant Tanks enhances the fun and excitement players get from Tank fights by creating a unique experience with every Tank."
#define MT_VERSION "8.83"
#define MT_URL "https://forums.alliedmods.net/showthread.php?t=302140"

// Chat tags
#define MT_TAG "[MT]"
#define MT_TAG2 "\x04[MT]\x01"
#define MT_TAG3 "\x04[MT]\x03"
#define MT_TAG4 "\x04[MT]\x05"

// Constants
#define MT_MAXABILITIES 100
#define MT_MAXTYPES 500
#define MT_MAXHEALTH 1000000
#define MT_MAX_HEALTH_REDUCTION -1000000

// Buttons
#define MT_MAIN_KEY IN_USE
#define MT_SUB_KEY IN_RELOAD
#define MT_SPECIAL_KEY IN_ZOOM
#define MT_SPECIAL_KEY2 IN_DUCK

// Client check flags
#define MT_CHECK_INDEX (1 << 0) // check 0 < client <= MaxClients
#define MT_CHECK_CONNECTED (1 << 1) // check IsClientConnected(client)
#define MT_CHECK_INGAME (1 << 2) // check IsClientInGame(client)
#define MT_CHECK_ALIVE (1 << 3) // check IsPlayerAlive(client)
#define MT_CHECK_INKICKQUEUE (1 << 4) // check IsClientInKickQueue(client)
#define MT_CHECK_FAKECLIENT (1 << 5) // check IsFakeClient(client)

// Attack flags
#define MT_ATTACK_CLAW (1 << 0) // weapon_tank_claw/tank_rock
#define MT_ATTACK_MELEE (1 << 1) // weapon_melee
#define MT_ATTACK_RANGE (1 << 2) // range ability

// Logging flags
#define MT_LOG_LIFE (1 << 0) // spawned or died
#define MT_LOG_CHANGE (1 << 1) // mutant type changed
#define MT_LOG_ABILITY (1 << 2) // ability activated
#define MT_LOG_SERVER (1 << 3) // server notifications/confirmations
#define MT_LOG_CUSTOM (1 << 4) // custom message

// Message flags
#define MT_MESSAGE_MELEE (1 << 0) // weapon_tank_claw/tank_rock/weapon_melee
#define MT_MESSAGE_RANGE (1 << 1) // range ability
#define MT_MESSAGE_SPECIAL (1 << 2) // special ability
#define MT_MESSAGE_SPECIAL2 (1 << 3) // special ability #2

// Reward flags
#define MT_REWARD_HEALTH (1 << 0) // health reward
#define MT_REWARD_SPEEDBOOST (1 << 1) // speed boost reward
#define MT_REWARD_DAMAGEBOOST (1 << 2) // damage boost reward
#define MT_REWARD_AMMO (1 << 3) // ammo reward
#define MT_REWARD_ITEM (1 << 4) // item reward
#define MT_REWARD_GODMODE (1 << 5) // god mode reward
#define MT_REWARD_REFILL (1 << 6) // refill reward
#define MT_REWARD_RESPAWN (1 << 7) // respawn reward

// Combination types
#define MT_COMBO_MAINRANGE 0 // main/range ability
#define MT_COMBO_MELEEHIT 1 // weapon_tank_claw/weapon_melee
#define MT_COMBO_ROCKTHROW 2 // when rock is thrown
#define MT_COMBO_ROCKBREAK 3 // tank_rock; when rock breaks
#define MT_COMBO_POSTSPAWN 4 // after spawning
#define MT_COMBO_UPONDEATH 5 // when dying
#define MT_COMBO_UPONINCAP 6 // when incapacitated

// Forwards
/**
 * Called every second to trigger a Mutant Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param tank			Client index of the Tank.
 **/
forward void MT_OnAbilityActivated(int tank);

/**
 * Called before the config file is read.
 * Use this forward to store the different formats of the ability's section name.
 *
 * @param list			List to store the first format.
 * @param list2			List to store the second format.
 * @param list3			List to store the third format.
 * @param list4			List to store the fourth format.
 **/
forward void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4);

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
 * @param oldType		The Tank's previous Mutant Tank type.
 * @param newType		The Tank's new Mutant Tank type.
 * @param revert		True if reverting to a normal Tank, false otherwise.
 **/
forward void MT_OnChangeType(int tank, int oldType, int newType, bool revert);

/**
 * Called when a Mutant Tank's abilities are combined.
 * Use this forward to trigger any combinations.
 *
 * @param tank			Client index of the Tank.
 * @param type			0 = Main/range abilities, 1 = Hit abilities, 2 = Rock throw abilities, 3 = Rock break abilities,
 *					4 = Post-spawn abilities, 5 = Upon-death abilities, 6 = Upon-incap abilities
 * @param random		Random value to check against for chance to trigger combination.
 * @param combo			String containing the list of abilities to combine.
 * @param survivor		Client index of the survivor, if any.
 * @param weapon		Entity index of the weapon, if any.
 * @param classname		String containing the weapon classname, if any.
 **/
forward void MT_OnCombineAbilities(int tank, int type, float random, const char[] combo, int survivor, int weapon, const char[] classname);

/**
 * Called when the config file is about to load.
 * Use this forward to set default values for settings for the plugin.
 *
 * @param mode			1 = Load general settings, 2 = 1 + load type settings, 3 = Load admin settings
 **/
forward void MT_OnConfigsLoad(int mode);

/**
 * Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param subsection		The subsection the config parser is currently on.
 * @param key			The key the config parser is currently on.
 * @param value			The value the config parser is currently on.
 * @param type			The Mutant Tank type the config parser is currently on. (Used for Mutant Tank-specific settings.)
 * @param admin			Client index of an admin. (Used for admin-specific settings.)
 * @param mode			1 = Load general settings, 2 = 1 + load type settings, 3 = Load admin settings
 **/
forward void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode);

/**
 * Called when the Tank is passed on to another player or bot.
 * Use this forward to copy over any stats for the Tank's new owner.
 *
 * @param oldTank		Client index of the previous owner.
 * @param newTank		Client index of the new owner.
 **/
forward void MT_OnCopyStats(int oldTank, int newTank);

/**
 * Called when a player uses the "sm_st_info" command.
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
 * @param hooked		True if event was hooked, false otherwise.
 **/
forward void MT_OnHookEvent(bool hooked);

/**
 * Called when a message is about to be logged.
 * Use this forward to intercept a message.
 *
 * @param type			Type of message being logged.
 * @param message		Buffer containing the message.
 *
 * @return			Plugin_Handled to prevent the message from being logged, Plugin_Continue to allow.
 **/
forward Action MT_OnLogMessage(int type, const char[] message);

/**
 * Called when an item from the "Mutant Tanks Information" menu is displayed.
 * Use this forward to translate an item. The menu callback will redraw the item after this forward is called if the buffer isn't empty.
 *
 * @param client		Client index of the player the item is being displayed to.
 * @param info			String containing the name of the item.
 * @param buffer		String to store the translated item.
 * @param size			Size of the buffer.
 **/
forward void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size);

/**
 * Called when a player selects an item from the "Mutant Tanks Information" menu.
 * Use this forward to do anything when an item is selected.
 *
 * @param client		Client index of the player selecting the item.
 * @param info			String containing the name of the item.
 **/
forward void MT_OnMenuItemSelected(int client, const char[] info);

/**
 * Called before the config file is read.
 * Use this forward to officially register an ability's plugin.
 *
 * @param list			List to store plugin's name in.
 **/
forward void MT_OnPluginCheck(ArrayList &list);

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
 * Called when timers have been reset.
 * Use this forward for resetting repeating timers that use intervals set by config files. 
 *
 * @param mode			0 = No client index required, 1 = Client index required
 * @param tank			Client index of a Tank.
 **/
forward void MT_OnResetTimers(int mode, int tank);

/**
 * Called when a survivor is rewarded or their reward ends.
 * Use this forward to reward survivors or to reset their rewards.
 *
 * @param survivor		Client index of the survivor.
 * @param tank			Client index of the Tank.
 * @param type			1 = Health, 2 = Damage boost, 4 = Speed boost, 8 = Ammo, 16 = Item, 32 = God mode, 64 = Health and ammo refill, 128 = Respawn,
 *					255 = All eight rewards, 256-2147483647 = Reserved for third-party plugins
 * @param priority		1 = Killer, 2 = Assistant who did most damage, 3 = Teammate who helped
 * @param duration		The duration of the reward.
 * @param apply			True if the reward is given, false otherwise.
 **/
forward void MT_OnRewardSurvivor(int survivor, int tank, int type, int priority, float duration, bool apply);

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

/**
 * Called when all settings are cached.
 * Use this forward to cache settings for each player.
 *
 * @param tank			Client index of the Tank.
 * @param apply			True if player is a Tank and has access to the Mutant Tank type, and needs settings to be applied, false otherwise.
 * @param type			Mutant Tank type, 0 otherwise.
 **/
forward void MT_OnSettingsCached(int tank, bool apply, int type);

/**
 * Called when a Mutant Tank type has been chosen.
 * Use this forward to check or change the chosen type.
 *
 * @param type			Type chosen.
 * @param tank			Client index of the Tank if the type chosen is being applied directly, 0 otherwise.
 *
 * @return			Plugin_Handled to choose another type, Plugin_Stop to prevent the Tank from mutating,
 *					Plugin_Changed to change the chosen type, Plugin_Continue to allow.
 */
forward Action MT_OnTypeChosen(int &type, int tank);

// Natives
/**
 * Returns if a certain Mutant Tank type can spawn.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type can spawn, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_CanTypeSpawn(int type);

/**
 * Detonates a Tank rock on the next frame.
 *
 * @param rock			Entity index of the rock.
 * @error			Invalid entity index.
 **/
native void MT_DetonateTankRock(int rock);

/**
 * Returns if a certain Mutant Tank type requires human-controlled survivors to be present to be effective.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type requires human-controlled survivors to be present, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_DoesTypeRequireHumans(int type);

/**
 * Returns the current access flags set by the core plugin.
 *
 * @param mode			1 = Global flags, 2 = Type-specific flags, 3 = Global admin flags, 4 = Type-specific admin flags
 * @param type			Mutant Tank type. (Optional)
 * @param admin			Client index of an admin. (Optional)
 * @return			The current access flags.
 * @error			Invalid client index, client is not in-game, client is a bot, or type is 0 or less.
 **/
native int MT_GetAccessFlags(int mode, int type = 0, int admin = -1);

/**
 * Returns the value of a combination setting based on a position.
 *
 * @param tank			Client index of the Tank.
 * @param type			1 = Chance, 2 = Damage, 3 = Delay, 4 = Duration, 5 = Interval, 6 = Min radius, 7 = Max radius,
 *					8 = Range, 9 = Range Chance, 10 = Death range, 11 = Death range chance, 12 = Rock chance, 13 = Speed
 * @param pos			The position in the setting's array to retrieve the value from. (0-9)
 * @return			The value stored in the setting.
 * @error			Invalid client index or client is not in-game.
 **/
native float MT_GetCombinationSetting(int tank, int type, int pos);

/**
 * Returns the current finale wave.
 *
 * @return			The current finale wave.
 **/
native int MT_GetCurrentFinaleWave();

/**
 * Returns a Mutant Tank's glow outline range.
 *
 * @param tank			Client index of the Tank.
 * @param mode			True if looking for max range, false otherwise.
 * @return			The glow outline range of the Tank.
 * @error			Invalid client index or client is not in-game.
 **/
native int MT_GetGlowRange(int tank, bool mode);

/**
 * Returns a Mutant Tank's glow outline type.
 *
 * @param tank			Client index of the Tank.
 * @return			The glow outline type of the Tank.
 * @error			Invalid client index or client is not in-game.
 **/
native int MT_GetGlowType(int tank);

/**
 * Returns the current immunity flags set by the core plugin.
 *
 * @param mode			1 = Global flags, 2 = Type-specific flags, 3 = Global admin flags, 4 = Type-specific admin flags
 * @param type			Mutant Tank type. (Optional)
 * @param admin			Client index of an admin. (Optional)
 * @return			The current immunity flags.
 * @error			Invalid client index, client is not in-game, client is a bot, or type is 0 or less.
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
 * @param type			1 = Light color, 2 = Oxygen tank color, 3 = Oxygen tank flames color, 4 = Rock color,
 *					5 = Tire color, 6 = Propane tank color, 7 = Flashlight color, 8 = Crown color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 * @error			Invalid client index, client is not in-game, or type is less than 1 or greater than 8.
 **/
native void MT_GetPropColors(int tank, int type, int &red, int &green, int &blue, int &alpha);

/**
 * Returns a Mutant Tank's run speed.
 *
 * @param tank			Client index of the Tank.
 * @return			The run speed of the Tank.
 * @error			Invalid client index or client is not in-game.
 **/
native float MT_GetRunSpeed(int tank);

/**
 * Returns the scaled damage based on difficulty.
 *
 * @param damage		Base damage to scale.
 * @return			The scaled damage based on difficulty.
 **/
native float MT_GetScaledDamage(float damage);

/**
 * Returns a Mutant Tank's spawn type.
 *
 * @param tank			Client index of the Tank.
 * @return			The spawn type of the Tank.
 *					0 = Normal, 1 = Boss, 2 = Randomized, 3 = Transformation, 4 = Combined abilities
 * @error			Invalid client index, client is not in-game, or client is human.
 **/
native int MT_GetSpawnType(int tank);

/**
 * Returns the RGB colors given to a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param type			1 = Skin color, 2 = Glow outline color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 * @error			Invalid client index, client is not in-game, or type is less than 1 or greater than 2.
 **/
native void MT_GetTankColors(int tank, int type, int &red, int &green, int &blue, int &alpha);

/**
 * Returns the custom name given to a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param buffer		Buffer to store the custom name in.
 * @error			Invalid client index or client is not in-game.
 **/
native void MT_GetTankName(int tank, char[] buffer);

/**
 * Returns the type of a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @return			The Tank's Mutant Tank type.
 * @error			Invalid client index or client is not in-game.
 **/
native int MT_GetTankType(int tank);

/**
 * Returns if a human player has access to a Mutant Tank type.
 *
 * @param admin			Client index of the admin.
 * @return			True if the human player has access, false otherwise.
 * @error			Invalid client index, client is not in-game, or client is a bot.
 **/
native bool MT_HasAdminAccess(int admin);

/**
 * Returns if a certain Mutant Tank type has a chance of spawning.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type has a chance of spawning, false otherwise.
 * @error			Type is 0 or less.
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
 * @error			Invalid survivor index, survivor is not in-game, survivor is dead, survivor is a bot, survivor is idle,
 *					invalid Tank index, or Tank is not in-game.
 **/
native bool MT_IsAdminImmune(int survivor, int tank);

/**
 * Returns if the core plugin is enabled.
 *
 * @return			True if core plugin is enabled, false otherwise.
 **/
native bool MT_IsCorePluginEnabled();

/**
 * Returns if a custom Tank is allowed to be a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @return			True if the custom Tank is allowed to be a Mutant Tank, false otherwise.
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native bool MT_IsCustomTankSupported(int tank);

/**
 * Returns if a certain Mutant Tank type is only available on finale maps.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type is available, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_IsFinaleType(int type);

/**
 * Returns if a Mutant Tank type has a glow outline.
 *
 * @param tank			Client index of the Tank.
 * @return			True if the Tank has a glow outline, false otherwise.
 * @error			Invalid client index or client is not in-game.
 **/
native bool MT_IsGlowEnabled(int tank);

/**
 * Returns if a Mutant Tank type's glow outline is flashing.
 *
 * @param tank			Client index of the Tank.
 * @return			True if the Tank's glow outline is flashing, false otherwise.
 * @error			Invalid client index or client is not in-game.
 **/
native bool MT_IsGlowFlashing(int tank);

/**
 * Returns if a certain Mutant Tank type is only available on non-finale maps.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type is available, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_IsNonFinaleType(int type);

/**
 * Returns if a Tank is idle.
 *
 * @param tank			Client index of the Tank.
 * @param type			Idle mode of the Tank. 0 = Both, 1 = Idle (waiting for survivors), 2 = Bugged (no behavior)
 * @return			True if the Tank is idle, false otherwise.
 * @error			Invalid client index, client is not in-game, client is dead, or type is less than 0 or greater than 2.
 **/
native bool MT_IsTankIdle(int tank, int type = 0);

/**
 * Returns if a Tank is allowed to be a Mutant Tank.
 *
 * @param tank			Client index of the Tank.
 * @param flags			Checks to run.
 *					MT_CHECK_INDEX = client index, MT_CHECK_CONNECTED = connection, MT_CHECK_INGAME = in-game status,
 *					MT_CHECK_ALIVE = life state, MT_CHECK_INKICKQUEUE = kick status, MT_CHECK_FAKECLIENT = bot check
 *					Default: MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE
 * @return			True if the Tank is allowed to be a Mutant Tank, false otherwise.
 * @error			Invalid client index, client is not in-game, or client is dead.
 **/
native bool MT_IsTankSupported(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE);

/**
 * Returns if a certain Mutant Tank type is enabled.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type is enabled, false otherwise.
 * @error			Type is 0 or less.
 **/
native bool MT_IsTypeEnabled(int type);

/**
 * Logs a message.
 *
 * @param type			Type of message to be logged.
 * @param message		Buffer containing the message.
 * @param ...			Variable number of format parameters.
 **/
native void MT_LogMessage(int type = MT_LOG_CUSTOM, const char[] message, any ...);

/**
 * Sets a Tank's Mutant Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 * @param mode			True if the Tank should transform physically into the new Mutant Tank type, false otherwise.
 * @error			Invalid client index, client is not in-game, client is dead, or type is 0 or less.
 **/
native void MT_SetTankType(int tank, int type, bool mode);

/**
 * Spawns a Tank with the specified Mutant Tank type.
 *
 * @param tank			Client index of the Tank.
 * @param type			Mutant Tank type.
 * @error			Invalid client index, client is not in-game, or type is 0 or less.
 **/
native void MT_SpawnTank(int tank, int type);

/**
 * Get or set a Tank's max health.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Get the Tank's max health, 2 = Get the Tank's stored max health,
 *					3 = Set the Tank's max health without storing it, 4 = Set the Tank's max health and store it
 * @param newHealth		The Tank's new max health.
 **/
native int MT_TankMaxHealth(int tank, int mode, int newHealth = 0);

/* Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param client		Client index of the Tank.
 */
#pragma deprecated Use MT_OnAbilityActivated() instead.
forward void ST_Ability(int client);

/* Called when a Tank is about to throw a rock.
 * Use this forward to trigger anything when
 * the Tank is gonna throw a rock.
 *
 * @param client		Client index of the Tank.
 */
#pragma deprecated Use MT_OnRockThrow() instead.
forward void ST_AbilityThrow(int client);

/* Called when the Super Tank evolves.
 * Use this forward to trigger any features/abilities/settings
 * when a Super Tank evolves.
 *
 * @param client		Client index of the Tank.
 */
#pragma deprecated Use MT_OnChangeType() instead.
forward void ST_BossStage(int client);

/**
 * Called when the Super Tank changes types.
 * Use this forward to trigger any features/abilities/settings when a Super Tank changes types.
 *
 * @param tank			Client index of the Tank.
 **/
#pragma deprecated Use MT_OnChangeType() instead.
forward void ST_ChangeType(int tank);

/* Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param limit			The limit for how many Super Tank types' settings to check for.
 * @param main			Checks whether the main config or a custom config is being used.
 */
#pragma deprecated Use MT_OnConfigsLoaded() instead.
forward void ST_Configs(char[] savepath, int limit, bool main);

/* Called when someone dies.
 * Use this forward to execute anything when
 * a survivor or Tank dies.
 * Use ST_Death2 if you also want to get the attacker's ID.
 *
 * @param client		Client index of the victim.
 */
#pragma deprecated Use the MT_OnEventFired() forward to catch the death event instead.
forward void ST_Death(int client);

/* Called when someone dies.
 * Use this forward to execute anything when
 * a survivor or Tank dies.
 * Use ST_Death if you just want to get the victim's ID.
 *
 * @param enemy			Client index of the attacker.
 * @param client		Client index of the victim.
 */
#pragma deprecated Use the MT_OnEventFired() forward to catch the death event instead.
forward void ST_Death2(int enemy, int client);

/* Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 */
#pragma deprecated Use MT_OnEventFired() instead.
forward void ST_Event(Event event, const char[] name);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast		True if event was not broadcast to clients, false otherwise.
 **/
#pragma deprecated Use MT_OnEventFired() instead.
forward void ST_EventHandler(Event event, const char[] name, bool dontBroadcast);

/* Called when a Tank is incapacitated.
 * Use this forward to execute anything when
 * a Tank is about to die.
 *
 * @param client		Client index of the Tank.
 */
#pragma deprecated Use the MT_OnEventFired() forward to catch the incap event instead.
forward void ST_Incap(int client);

/**
 * Called when the Tank spawns.
 * Use this forward for any on-spawn presets.
 * If you plan on using this to activate an ability, use ST_Ability() instead.
 *
 * @param tank			Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnPostTankSpawn() instead.
forward void ST_OnPreset(int tank);

/**
 * Called when the Tank spawns.
 * Use this forward for any on-spawn presets.
 * If you plan on using this to activate an ability, use ST_Ability() instead.
 *
 * @param tank			Client index of the Tank.
 **/
#pragma deprecated Use the MT_OnPostTankSpawn() instead.
forward void ST_Preset(int tank);

/* Called when the Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 */
#pragma deprecated Use MT_OnRockBreak() instead.
forward void ST_RockBreak(int client, int entity);

/* Called when the Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param client		Client index of the Tank.
 * @param entity		Entity index of the rock.
 */
#pragma deprecated Use MT_OnRockThrow() instead.
forward void ST_RockThrow(int client, int entity);

/* Called when the round starts.
 * Use this forward for setting something when
 * the round starts.
 */
#pragma deprecated Use the MT_OnEventFired() forward to catch the round start event instead.
forward void ST_RoundStart();

/* Called when the Tank spawns.
 * Use this forward for any one-time abilities
 * or on-spawn presets.
 *
 * @param client		Client index of the Tank.
 */
#pragma deprecated Use the MT_OnPostTankSpawn() instead.
forward void ST_Spawn(int client);

/**
 * Returns if a certain Mutant Tank type can spawn.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type can spawn, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use MT_CanTypeSpawn() instead.
stock bool MT_CanTankSpawn(int type)
{
	return MT_CanTypeSpawn(type);
}

/**
 * Returns if a certain Mutant Tank type is only available on finale maps.
 *
 * @param type			Mutant Tank type.
 * @return			True if the type is available, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use MT_IsFinaleType() instead.
stock bool MT_IsFinaleTank(int type)
{
	return MT_IsFinaleType(type);
}

/* Returns the value of the "Maximum Types" setting.
 *
 * @return			The value of the "Maximum Types" setting.
 */
#pragma deprecated Use MT_GetMaxType() instead.
stock int ST_MaxTypes()
{
	return MT_GetMaxType();
}

/* Returns the maximum value of the "Type Range" setting.
 *
 * @return			The maximum value of the "Type Range" setting.
 */
#pragma deprecated Use MT_GetMaxType() instead.
stock int ST_MaxType()
{
	return MT_GetMaxType();
}

/* Returns the minimum value of the "Type Range" setting.
 *
 * @return			The minimum value of the "Type Range" setting.
 */
#pragma deprecated Use MT_GetMinType() instead.
stock int ST_MinType()
{
	return MT_GetMinType();
}

/* Returns the status of the core plugin.
 *
 * @return			True on success, false if core plugin is disabled.
 */
#pragma deprecated Use MT_IsCorePluginEnabled() instead.
stock bool ST_PluginEnabled()
{
	return MT_IsCorePluginEnabled();
}

/**
 * Returns the RGBA colors given to a Tank's props.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Light color, 2 = Oxygen tank color, 3 = Oxygen tank flames color,
 *					4 = Rock color, 5 = Tire color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 * @error			Invalid client index.
 **/
#pragma deprecated Use MT_GetPropColors() instead.
stock void ST_PropsColors(int tank, int mode, int &red, int &green, int &blue, int &alpha)
{
	MT_GetPropColors(tank, mode, red, green, blue, alpha);
}

/**
 * Returns if a certain Super Tank type can be spawned.
 *
 * @param type			Super Tank type.
 * @return			True if the type can be spawned, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use MT_CanTypeSpawn() instead.
stock bool ST_SpawnEnabled(int type)
{
	return MT_CanTypeSpawn(type);
}

/* Returns the status of the "Human Super Tanks" setting.
 *
 * @param client		Client index of the Tank.
 *
 * @return			True on success, false if the setting is disabled.
 */
#pragma deprecated Use MT_IsTankSupported() instead.
stock bool ST_TankAllowed(int client)
{
	return MT_IsTankSupported(client);
}

/**
 * Returns if a certain Super Tank type has a chance of spawning.
 *
 * @param type			Super Tank type.
 * @return			True if the type has a chance of spawning, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use MT_HasChanceToSpawn() instead.
stock bool ST_TankChance(int type)
{
	return MT_HasChanceToSpawn(type);
}

/**
 * Returns the RGB colors given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param mode			1 = Skin color, 2 = Glow outline color
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 * @error			Invalid client index.
 **/
#pragma deprecated Use MT_GetTankColors() instead.
stock void ST_TankColors(int tank, int mode, int &red, int &green, int &blue, int &alpha)
{
	MT_GetTankColors(tank, type, red, green, blue, alpha);
}

/**
 * Returns the custom name given to a Tank.
 *
 * @param tank			Client index of the Tank.
 * @param buffer		Buffer to store the custom name in.
 * @error			Invalid client index.
 **/
#pragma deprecated Use MT_GetTankName() instead.
stock void ST_TankName(int tank, char[] buffer)
{
	MT_GetTankName(tank, buffer);
}

/* Returns the Super Tank type of the Tank.
 *
 * @param client		Client index of the Tank.
 *
 * @return			The Tank's Super Tank type.
 */
#pragma deprecated Use MT_GetTankType() instead.
stock int ST_TankType(int client)
{
	return MT_GetTankType(client);
}

/* Returns the current finale wave.
 *
 * @return			The current finale wave.
 */
#pragma deprecated Use MT_GetCurrentFinaleWave() instead.
stock int ST_TankWave()
{
	return MT_GetCurrentFinaleWave();
}

/**
 * Returns if a certain Super Tank type is enabled.
 *
 * @param type			Super Tank type.
 * @return			True if the type is enabled, false otherwise.
 * @error			Type is 0.
 **/
#pragma deprecated Use MT_IsTypeEnabled() instead.
stock bool ST_TypeEnabled(int type)
{
	return MT_IsTypeEnabled(type);
}

// Functions
stock void vAttachParticle(int entity, const char[] particlename, float duration = 0.0, float origin = 0.0)
{
	if (bIsValidClient(entity) || bIsValidEntity(entity))
	{
		static int iParticle;
		iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
		{
			static float flPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;

			DispatchKeyValue(iParticle, "effect_name", particlename);
			vSetEntityParent(iParticle, entity);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Start");

			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, duration);
		}
	}
}

stock void vAttachParticle2(float pos[3], float angle[3], const char[] particlename, float duration = 0.0)
{
	static int iParticle;
	iParticle = CreateEntityByName("info_particle_system");
	if (bIsValidEntity(iParticle))
	{
		DispatchKeyValue(iParticle, "effect_name", particlename); 
		TeleportEntity(iParticle, pos, angle, NULL_VECTOR);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "Start");

		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle, duration);
	}
}

stock void vCheatCommand(int player, const char[] command, const char[] arguments = "")
{
	static int iCmdFlags, iFlagBits;
	iFlagBits = GetUserFlagBits(player);
	iCmdFlags = GetCommandFlags(command);
	SetUserFlagBits(player, ADMFLAG_ROOT);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(player, "%s %s", command, arguments);
	SetUserFlagBits(player, iFlagBits);
	SetCommandFlags(command, iCmdFlags|FCVAR_CHEAT);
}

stock void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

stock void vCreateConfigFile(const char[] folder, const char[] filename, any ...)
{
	static char sConfigFilename[PLATFORM_MAX_PATH], sFilename[PLATFORM_MAX_PATH];
	VFormat(sFilename, sizeof(sFilename), filename, 3);
	BuildPath(Path_SM, sConfigFilename, sizeof(sConfigFilename), "data/mutant_tanks/%s%s.cfg", folder, sFilename);
	if (FileExists(sConfigFilename))
	{
		return;
	}

	File fFilename = OpenFile(sConfigFilename, "w+");
	if (fFilename != null)
	{
		fFilename.WriteLine("// This config file was auto-generated by %s v%s (%s)", MT_NAME, MT_VERSION, MT_URL);
		fFilename.WriteLine("\n");

		delete fFilename;
	}
}

stock int iCreateParticle(int player, const char[] particlename, float pause, float duration, bool fireUser2)
{
	static int iEffect;
	iEffect = CreateEntityByName("info_particle_system");
	if (bIsValidEntity(iEffect))
	{
		DispatchKeyValue(iEffect, "effect_name", particlename);
		vSetEntityParent(iEffect, player);
		TeleportEntity(iEffect, view_as<float>({0.0, 0.0, 50.0}), NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iEffect);
		ActivateEntity(iEffect);
		AcceptEntityInput(iEffect, "Start");

		static char sVariant[64];
		SetVariantString("OnUser1 !self:Start::0.0:-1");
		AcceptEntityInput(iEffect, "AddOutput");

		FormatEx(sVariant, sizeof(sVariant), "OnUser2 !self:Stop::%f:-1", pause);
		SetVariantString(sVariant);
		AcceptEntityInput(iEffect, "AddOutput");

		FormatEx(sVariant, sizeof(sVariant), "OnUser2 !self:FireUser1::%f:-1", pause + 0.1);
		SetVariantString(sVariant);
		AcceptEntityInput(iEffect, "AddOutput");

		if (fireUser2)
		{
			FormatEx(sVariant, sizeof(sVariant), "OnUser2 !self:FireUser2::%f:-1", pause + 0.1);
			SetVariantString(sVariant);
			AcceptEntityInput(iEffect, "AddOutput");
		}

		AcceptEntityInput(iEffect, "FireUser1");
		AcceptEntityInput(iEffect, "FireUser2");

		FormatEx(sVariant, sizeof(sVariant), "OnUser3 !self:Kill::%f:-1", duration);
		SetVariantString(sVariant);
		AcceptEntityInput(iEffect, "AddOutput");
		AcceptEntityInput(iEffect, "FireUser3");

		return iEffect;
	}

	return -1;
}

stock void vDamagePlayer(int victim, int attacker, float damage, const char[] damagetype = "0")
{
	static int iPointHurt;
	iPointHurt = CreateEntityByName("point_hurt");
	if (bIsValidEntity(iPointHurt))
	{
		static char sTargetName[32];
		FormatEx(sTargetName, sizeof(sTargetName), "mt_target_%i", GetClientUserId(victim));
		DispatchKeyValue(victim, "targetname", sTargetName);

		DispatchKeyValueFloat(iPointHurt, "Damage", damage);
		DispatchKeyValue(iPointHurt, "DamageTarget", sTargetName);
		DispatchKeyValue(iPointHurt, "DamageType", damagetype);

		DispatchSpawn(iPointHurt);
		AcceptEntityInput(iPointHurt, "Hurt", attacker);
		RemoveEntity(iPointHurt);
	}
}

stock void vDeleteEntity(int ref, float duration = 0.1)
{
	if (bIsValidEntRef(ref))
	{
		static int iObject;
		iObject = EntRefToEntIndex(ref);
		if (bIsValidEntity(iObject))
		{
			static char sVariant[64];
			FormatEx(sVariant, sizeof(sVariant), "OnUser1 !self:ClearParent::%f:-1", duration);
			SetVariantString(sVariant);
			AcceptEntityInput(iObject, "AddOutput");
			AcceptEntityInput(iObject, "FireUser1");

			FormatEx(sVariant, sizeof(sVariant), "OnUser1 !self:Kill::%f:-1", duration + 0.1);
			SetVariantString(sVariant);
			AcceptEntityInput(iObject, "AddOutput");
			AcceptEntityInput(iObject, "FireUser1");
		}
	}
}

stock void vEffect(int survivor, int tank, int mode, int flags = MT_ATTACK_MELEE|MT_ATTACK_CLAW)
{
	if (mode & flags)
	{
		static int iColor[4];
		MT_GetTankColors(tank, GetRandomInt(1, 2), iColor[0], iColor[1], iColor[2], iColor[3]);

		static Handle hFadeTarget;
		hFadeTarget = StartMessageOne("Fade", survivor);

		static BfWrite bfWrite;
		bfWrite = UserMessageToBfWrite(hFadeTarget);
		bfWrite.WriteShort(800);
		bfWrite.WriteShort(300);
		bfWrite.WriteShort((0x0010|0x0001));

		for (int iPos = 0; iPos < sizeof(iColor) - 1; iPos++)
		{
			bfWrite.WriteByte(iColor[iPos]);
		}

		bfWrite.WriteByte(150);

		EndMessage();
	}
}

stock void vExternalView(int player, float time)
{
	if (GetEngineVersion() == Engine_Left4Dead2 && GetEntPropFloat(player, Prop_Send, "m_TimeForceExternalView") != 99999.3)
	{
		SetEntPropFloat(player, Prop_Send, "m_TimeForceExternalView", GetGameTime() + time);
	}
}

stock void vGetSettingValue(bool apply, bool human, char[] buffer, int size = 0, const char[] playerVal = "", const char[] typeVal = "")
{
	switch (apply)
	{
		case true: Format(buffer, size, "%s", ((human && playerVal[0] != '\0') ? playerVal : typeVal));
		case false: buffer[0] = '\0';
	}
}

stock void vMultiTargetFilters(bool toggle)
{
	switch (toggle)
	{
		case true:
		{
			AddMultiTargetFilter("@smokers", bSmokerFilter, "all Smokers", false);
			AddMultiTargetFilter("@boomers", bBoomerFilter, "all Boomers", false);
			AddMultiTargetFilter("@hunters", bHunterFilter, "all Hunters", false);
			AddMultiTargetFilter("@spitters", bSpitterFilter, "all Spitters", false);
			AddMultiTargetFilter("@jockeys", bJockeyFilter, "all Jockeys", false);
			AddMultiTargetFilter("@chargers", bChargerFilter, "all Chargers", false);
			AddMultiTargetFilter("@tanks", bTankFilter, "all Tanks", false);
			AddMultiTargetFilter("@special", bSpecialFilter, "all Special Infected", false);
			AddMultiTargetFilter("@infected", bInfectedFilter, "all Infected", false);
			AddMultiTargetFilter("@mutants", bMutantFilter, "all Mutant Tanks", false);
			AddMultiTargetFilter("@mtanks", bMutantFilter, "all Mutant Tanks", false);
			AddMultiTargetFilter("@psytanks", bMutantFilter, "all Mutant Tanks", false);
		}
		case false:
		{
			RemoveMultiTargetFilter("@smokers", bSmokerFilter);
			RemoveMultiTargetFilter("@boomers", bBoomerFilter);
			RemoveMultiTargetFilter("@hunters", bHunterFilter);
			RemoveMultiTargetFilter("@spitters", bSpitterFilter);
			RemoveMultiTargetFilter("@jockeys", bJockeyFilter);
			RemoveMultiTargetFilter("@chargers", bChargerFilter);
			RemoveMultiTargetFilter("@tanks", bTankFilter);
			RemoveMultiTargetFilter("@special", bSpecialFilter);
			RemoveMultiTargetFilter("@infected", bInfectedFilter);
			RemoveMultiTargetFilter("@mutants", bMutantFilter);
			RemoveMultiTargetFilter("@mtanks", bMutantFilter);
			RemoveMultiTargetFilter("@psytanks", bMutantFilter);
		}
	}
}

stock void vPushNearbyEntities(int tank, float pos[3], float magnitude = 600.0, float radius = 200.0)
{
	static int iPointPush;
	iPointPush = CreateEntityByName("point_push");
	if (bIsValidEntity(iPointPush))
	{
		SetEntPropEnt(iPointPush, Prop_Send, "m_hOwnerEntity", tank);
		DispatchKeyValueFloat(iPointPush, "magnitude", magnitude);
		DispatchKeyValueFloat(iPointPush, "radius", radius);
		DispatchKeyValue(iPointPush, "spawnflags", "8");

		TeleportEntity(iPointPush, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iPointPush);
		AcceptEntityInput(iPointPush, "Enable");

		iPointPush = EntIndexToEntRef(iPointPush);
		vDeleteEntity(iPointPush, 0.5);
	}
}

stock void vRemoveWeapons(int survivor)
{
	int iWeapon = 0;
	for (int iSlot = 0; iSlot < 5; iSlot++)
	{
		iWeapon = GetPlayerWeaponSlot(survivor, iSlot);
		if (iWeapon > MaxClients)
		{
			RemovePlayerItem(survivor, iWeapon);
			RemoveEntity(iWeapon);
		}
	}
}

stock void vSetEntityParent(int entity, int parent, bool owner = false)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);

	if (owner)
	{
		SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", parent);
	}
}

stock void vSetVector(float target[3], float x, float y, float z)
{
	target[0] = x;
	target[1] = y;
	target[2] = z;
}

stock void vSetWounds(int common, int type = -1)
{
	if (bIsCommonInfected(common) && HasEntProp(common, Prop_Send, "m_iRequestedWound1"))
	{
		SetEntProp(common, Prop_Send, "m_iRequestedWound1", type);
		SetEntProp(common, Prop_Send, "m_iRequestedWound2", type);
	}
}

stock void vSpawnBreakProp(int tank, float pos[3], float offset, const char[] model)
{
	int iProp = CreateEntityByName("prop_physics");
	if (bIsValidEntity(iProp))
	{
		DispatchKeyValue(iProp, "disableshadows", "1");
		SetEntityModel(iProp, model);

		pos[2] += offset;
		TeleportEntity(iProp, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iProp);

		SetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity", tank);
		SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", tank);
		SetEntPropFloat(iProp, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());

		SetEntProp(iProp, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iProp, 0, 0, 0, 0);

		AcceptEntityInput(iProp, "Break", tank);
	}
}

stock void vShakePlayerScreen(int player, float duration = 1.0)
{
	static Handle hTarget;
	hTarget = StartMessageOne("Shake", player);

	static BfWrite bfWrite;
	bfWrite = UserMessageToBfWrite(hTarget);
	bfWrite.WriteByte(0);
	bfWrite.WriteFloat(16.0);
	bfWrite.WriteFloat(0.5);
	bfWrite.WriteFloat(duration);

	EndMessage();
}

stock void vStopSound(int client, const char[] sound)
{
	StopSound(client, SNDCHAN_REPLACE, sound);
	StopSound(client, SNDCHAN_AUTO, sound);
	StopSound(client, SNDCHAN_WEAPON, sound);
	StopSound(client, SNDCHAN_VOICE, sound);
	StopSound(client, SNDCHAN_ITEM, sound);
	StopSound(client, SNDCHAN_BODY, sound);
	StopSound(client, SNDCHAN_STREAM, sound);
	StopSound(client, SNDCHAN_STATIC, sound);
	StopSound(client, SNDCHAN_VOICE_BASE, sound);
	StopSound(client, SNDCHAN_USER_BASE, sound);
}

// Chat
stock void MT_PrintToChat(int client, const char[] message, any ...)
{
	if (!bIsValidClient(client, MT_CHECK_INDEX))
	{
		ThrowError("Invalid client index %i", client);
	}

	if (!bIsValidClient(client, MT_CHECK_INGAME))
	{
		ThrowError("Client %i is not in game", client);
	}

	static char sBuffer[255], sMessage[255];
	SetGlobalTransTarget(client);
	FormatEx(sBuffer, sizeof(sBuffer), "\x01%s", message);
	VFormat(sMessage, sizeof(sMessage), sBuffer, 3);

	ReplaceString(sMessage, sizeof(sMessage), "{default}", "\x01");
	ReplaceString(sMessage, sizeof(sMessage), "{mint}", "\x03");
	ReplaceString(sMessage, sizeof(sMessage), "{yellow}", "\x04");
	ReplaceString(sMessage, sizeof(sMessage), "{olive}", "\x05");
	ReplaceString(sMessage, sizeof(sMessage), "{percent}", "%%");

	PrintToChat(client, sMessage);
}

stock void MT_PrintToChatAll(const char[] message, any ...)
{
	static char sBuffer[255];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
		{
			SetGlobalTransTarget(iPlayer);
			VFormat(sBuffer, sizeof(sBuffer), message, 2);
			MT_PrintToChat(iPlayer, sBuffer);
		}
	}
}

stock void MT_ReplyToCommand(int client, const char[] message, any ...)
{
	static char sBuffer[255];
	SetGlobalTransTarget(client);
	VFormat(sBuffer, sizeof(sBuffer), message, 3);

	if (GetCmdReplySource() == SM_REPLY_TO_CONSOLE)
	{
		ReplaceString(sBuffer, sizeof(sBuffer), "{default}", "");
		ReplaceString(sBuffer, sizeof(sBuffer), "{mint}", "");
		ReplaceString(sBuffer, sizeof(sBuffer), "{yellow}", "");
		ReplaceString(sBuffer, sizeof(sBuffer), "{olive}", "");
		ReplaceString(sBuffer, sizeof(sBuffer), "{percent}", "%%");

		switch (client == 0)
		{
			case true: PrintToServer(sBuffer);
			case false: PrintToConsole(client, sBuffer);
		}
	}
	else
	{
		MT_PrintToChat(client, sBuffer);
	}
}

// Checks
stock bool bHasAdminAccess(int admin, int flags, int flags2)
{
	if (!bIsValidClient(admin, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	static int iTypePlayerFlags, iPlayerFlags, iAdminFlags, iTypeFlags, iGlobalFlags;
	iTypePlayerFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	iPlayerFlags = MT_GetAccessFlags(3, 0, admin);
	iAdminFlags = GetUserFlagBits(admin);
	iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	iGlobalFlags = MT_GetAccessFlags(1);
	if ((flags != 0 && ((!(flags & flags2) && !(flags2 & flags)) || (!(flags & iTypePlayerFlags) && !(iTypePlayerFlags & flags)) || (!(flags & iPlayerFlags) && !(iPlayerFlags & flags)) || (!(flags & iAdminFlags) && !(iAdminFlags & flags))))
		|| (iTypeFlags != 0 && !(iTypeFlags & flags2) && !(flags2 & iTypeFlags)) || (iGlobalFlags != 0 && !(iGlobalFlags & flags2) && !(flags2 & iGlobalFlags)))
	{
		return false;
	}

	return true;
}

stock bool bHasIdlePlayer(int survivor)
{
	static char sClassname[32];
	GetEntityNetClass(survivor, sClassname, sizeof(sClassname));
	if (StrEqual(sClassname, "SurvivorBot"))
	{
		static int iSpectatorUserId;
		iSpectatorUserId = GetEntProp(survivor, Prop_Send, "m_humanSpectatorUserID");
		if (iSpectatorUserId > 0)
		{
			static int iIdler;
			iIdler = GetClientOfUserId(iSpectatorUserId);
			return iIdler > 0 && bIsValidClient(iIdler, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && GetClientTeam(iIdler) != 2;
		}
	}

	return false;
}

stock bool bIsAdminImmune(int admin, int type, int flags, int flags2)
{
	if (!bIsHumanSurvivor(admin))
	{
		return false;
	}

	static int iTypePlayerFlags, iPlayerFlags, iAdminFlags, iTypeFlags, iGlobalFlags;
	iTypePlayerFlags = MT_GetImmunityFlags(4, type, admin);
	iPlayerFlags = MT_GetImmunityFlags(3, 0, admin);
	iAdminFlags = GetUserFlagBits(admin);
	iTypeFlags = MT_GetImmunityFlags(2, type);
	iGlobalFlags = MT_GetImmunityFlags(1);

	return (flags != 0 && ((flags2 != 0 && ((flags & flags2) || (flags2 & flags))) || (iTypePlayerFlags != 0 && ((flags & iTypePlayerFlags) || (iTypePlayerFlags & flags)))
		|| (iPlayerFlags != 0 && ((flags & iPlayerFlags) || (iPlayerFlags & flags))) || (iAdminFlags != 0 && ((flags & iAdminFlags) || (iAdminFlags & flags)))))
		|| (iTypeFlags != 0 && ((iTypeFlags & flags2) || (flags2 & iTypeFlags))) || (iGlobalFlags != 0 && ((iGlobalFlags & flags2) || (flags2 & iGlobalFlags)));
}

stock bool bIsAreaNarrow(int tank, float range = 150.0)
{
	if (range > 0.0)
	{
		static float flOrigin[3], flPos[3], flAngles[3];
		flAngles[0] = -89.0;
		GetClientEyePosition(tank, flOrigin);

		static Handle hTrace;
		hTrace = TR_TraceRayFilterEx(flOrigin, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
		if (hTrace != null)
		{
			if (TR_DidHit(hTrace))
			{
				TR_GetEndPosition(flPos, hTrace); 
				if (GetVectorDistance(flPos, flOrigin) <= range)
				{
					delete hTrace;

					return true;
				}
			}

			delete hTrace;
		}
	}

	return false;
}

stock bool bIsBoomer(int boomer, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsInfected(boomer, flags) && GetEntProp(boomer, Prop_Send, "m_zombieClass") == 2;
}

stock bool bIsBotIdle(int bot, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsSurvivor(bot, flags) && !bIsValidClient(bot, MT_CHECK_FAKECLIENT) && bHasIdlePlayer(bot);
}

stock bool bIsBotIdleSurvivor(int bot, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsSurvivor(bot, flags) && !bIsValidClient(bot, MT_CHECK_FAKECLIENT) && !bHasIdlePlayer(bot);
}

stock bool bIsBotSurvivor(int bot, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsSurvivor(bot, flags) && !bIsValidClient(bot, MT_CHECK_FAKECLIENT);
}

stock bool bIsCharger(int charger, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsInfected(charger, flags) && GetEntProp(charger, Prop_Send, "m_zombieClass") == 6;
}

stock bool bIsCommonInfected(int common)
{
	if (bIsValidEntity(common))
	{
		static char sClassname[32];
		GetEntityClassname(common, sClassname, sizeof(sClassname));
		return StrEqual(sClassname, "infected");
	}

	return false;
}

stock bool bIsEntityGrounded(int entity)
{
	return (HasEntProp(entity, Prop_Send, "m_fFlags") && (GetEntProp(entity, Prop_Send, "m_fFlags") & FL_ONGROUND)) || (HasEntProp(entity, Prop_Send, "m_hGroundEntity") && GetEntPropEnt(entity, Prop_Send, "m_hGroundEntity") == 0);
}

stock bool bIsGunWeapon(int survivor)
{
	static char sWeapon[32];
	GetClientWeapon(survivor, sWeapon, sizeof(sWeapon));
	return GetPlayerWeaponSlot(survivor, 0) > MaxClients || (GetPlayerWeaponSlot(survivor, 1) > MaxClients && StrContains(sWeapon, "pistol", false) != -1);
}

stock bool bIsHumanSurvivor(int survivor, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	flags |= MT_CHECK_FAKECLIENT;
	return bIsSurvivor(survivor, flags) && !bHasIdlePlayer(survivor) && !bIsPlayerIdle(survivor);
}

stock bool bIsHunter(int hunter, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsInfected(hunter, flags) && GetEntProp(hunter, Prop_Send, "m_zombieClass") == 3;
}

stock bool bIsIdlePlayer(int bot, int survivor, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT)
{
	return bIsValidClient(survivor, flags) && GetClientTeam(bot) == 2;
}

stock bool bIsInfected(int infected, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsValidClient(infected, flags) && GetClientTeam(infected) == 3;
}

stock bool bIsInfectedGhost(int infected)
{
	return GetEntProp(infected, Prop_Send, "m_isGhost") == 1;
}

stock bool bIsJockey(int jockey, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsInfected(jockey, flags) && GetEngineVersion() == Engine_Left4Dead2 && GetEntProp(jockey, Prop_Send, "m_zombieClass") == 5;
}

stock bool bIsPlayerBurning(int player)
{
	return GetEntPropFloat(player, Prop_Send, "m_burnPercent") > 0.0 || GetEntProp(player, Prop_Data, "m_fFlags") & FL_ONFIRE;
}

stock bool bIsPlayerDisabled(int survivor)
{
	return bIsPlayerHanging(survivor) || bIsPlayerIncapacitated(survivor);
}

stock bool bIsPlayerHanging(int survivor)
{
	return GetEntProp(survivor, Prop_Send, "m_isHangingFromLedge") == 1 || GetEntProp(survivor, Prop_Send, "m_isFallingFromLedge") == 1;
}

stock bool bIsPlayerIdle(int survivor)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!bIsValidClient(iPlayer, MT_CHECK_INGAME) || bIsValidClient(iPlayer, MT_CHECK_FAKECLIENT) || !bHasIdlePlayer(iPlayer) || GetClientTeam(iPlayer) != 2)
		{
			continue;
		}

		static char sClassname[32];
		GetEntityNetClass(iPlayer, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "SurvivorBot"))
		{
			static int iSpectatorUserId;
			iSpectatorUserId = GetEntProp(iPlayer, Prop_Send, "m_humanSpectatorUserID");
			if (iSpectatorUserId > 0)
			{
				static int iIdler;
				iIdler = GetClientOfUserId(iSpectatorUserId);
				return iIdler == survivor;
			}
		}
	}

	return false;
}

stock bool bIsPlayerIncapacitated(int survivor)
{
	return GetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1) == 1;
}

stock bool bIsSmoker(int smoker, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsInfected(smoker, flags) && GetEntProp(smoker, Prop_Send, "m_zombieClass") == 1;
}

stock bool bIsSpecialInfected(int infected, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsSmoker(infected, flags) || bIsBoomer(infected, flags) || bIsHunter(infected, flags) || bIsSpitter(infected, flags) || bIsJockey(infected, flags) || bIsCharger(infected, flags);
}

stock bool bIsSpitter(int spitter, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	return bIsInfected(spitter, flags) && GetEntProp(spitter, Prop_Send, "m_zombieClass") == 4;
}

stock bool bIsSurvivor(int survivor, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	return bIsValidClient(survivor, flags) && GetClientTeam(survivor) == 2;
}

stock bool bIsSurvivorCaught(int survivor)
{
	static int iSpecial;
	iSpecial = GetEntPropEnt(survivor, Prop_Send, "m_pounceAttacker");
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_tongueOwner") : iSpecial;
	if (GetEngineVersion() == Engine_Left4Dead2)
	{
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pummelAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_carryAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_jockeyAttacker") : iSpecial;
	}

	return iSpecial > 0;
}

stock bool bIsTank(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE)
{
	int iClass = (GetEngineVersion() == Engine_Left4Dead2) ? 8 : 5;
	return bIsInfected(tank, flags) && GetEntProp(tank, Prop_Send, "m_zombieClass") == iClass;
}

stock bool bIsTankStasis(int tank)
{
	return GetEntProp(tank, Prop_Data, "m_bIsInStasis") == 1;
}

stock bool bIsTankThirdPerson(int tank, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT)
{
	if (bIsTank(tank, flags))
	{
		switch (GetEntProp(tank, Prop_Send, "m_nSequence"))
		{
			case 28, 29, 30, 31, 47, 48, 49, 50, 51, 73, 74, 75, 76, 77: return true;
		}
	}

	return bIsPlayerIncapacitated(tank) || (GetEngineVersion() == Engine_Left4Dead2 && GetEntPropFloat(tank, Prop_Send, "m_TimeForceExternalView") > GetGameTime()) || GetEntPropFloat(tank, Prop_Send, "m_staggerTimer", 1) > -1.0 || GetEntPropEnt(tank, Prop_Send, "m_hViewEntity") > 0;
}

stock bool bIsValidClient(int player, int flags = MT_CHECK_INDEX|MT_CHECK_INGAME)
{
	if (((flags & MT_CHECK_INDEX) && (player <= 0 || player > MaxClients)) || ((flags & MT_CHECK_CONNECTED) && !IsClientConnected(player))
		|| ((flags & MT_CHECK_INGAME) && !IsClientInGame(player)) || ((flags & MT_CHECK_ALIVE) && !IsPlayerAlive(player))
		|| ((flags & MT_CHECK_INKICKQUEUE) && IsClientInKickQueue(player)) || ((flags & MT_CHECK_FAKECLIENT) && IsFakeClient(player)))
	{
		return false;
	}

	return true;
}

stock bool bIsValidEntity(int entity)
{
	return entity > MaxClients && IsValidEntity(entity);
}

stock bool bIsValidEntRef(int ref)
{
	return ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE;
}

stock bool bIsWitch(int witch)
{
	if (bIsValidEntity(witch))
	{
		static char sClassname[32];
		GetEntityClassname(witch, sClassname, sizeof(sClassname));
		return StrEqual(sClassname, "witch");
	}

	return false;
}

public bool bBoomerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsBoomer(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
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
		if (bIsCharger(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
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
		if (bIsHunter(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			PushArrayCell(clients, iPlayer);
		}
	}

	return true;
}

public bool bInfectedFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
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
		if (bIsJockey(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			PushArrayCell(clients, iPlayer);
		}
	}

	return true;
}

public bool bMutantFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && MT_GetTankType(iPlayer) > 0)
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
		if (bIsSmoker(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			PushArrayCell(clients, iPlayer);
		}
	}

	return true;
}

public bool bSpecialFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpecialInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
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
		if (bIsSpitter(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
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
		if (bIsTank(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			PushArrayCell(clients, iPlayer);
		}
	}

	return true;
}

public bool bTraceRayDontHitSelf(int entity, int mask, any data)
{
	return entity != data;
}

public bool bTraceRayDontHitSelfAndCommons(int entity, int mask, any data)
{
	return entity != data && !bIsCommonInfected(entity);
}

public bool bTraceRayDontHitSelfAndInfected(int entity, int mask, any data)
{
	return entity != data && !bIsInfected(entity);
}

public bool bTraceRayDontHitSelfAndPlayer(int entity, int mask, any data)
{
	return entity != data && !bIsValidClient(entity, MT_CHECK_INDEX|MT_CHECK_INGAME);
}

public bool bTraceRayDontHitSelfAndSurvivor(int entity, int mask, any data)
{
	return entity != data && !bIsSurvivor(entity);
}

stock bool bVisiblePosition(float pos1[3], float pos2[3], int entity, int type)
{
	static Handle hTrace;

	switch (type)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndSurvivor, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndPlayer, entity);
	}

	if (hTrace != null)
	{
		if (TR_DidHit(hTrace))
		{
			delete hTrace;

			return false;
		}

		delete hTrace;
	}

	return true;
}

stock float flClamp(float value, float min, float max)
{
	if (value < min)
	{
		return min;
	}
	else if (value > max)
	{
		return max;
	}

	return value;
}

stock float flGetAngle(float angle1[3], float angle2[3])
{
	return ArcCosine(GetVectorDotProduct(angle1, angle2) / (GetVectorLength(angle1) * GetVectorLength(angle2)));
}

stock float flGetDistance(float pos[3], float angle[3], float offset1, float offset2, float force[3], int entity, int type)
{
	static float flAngle[3], flDistance;
	vCopyVector(angle, flAngle);
	flAngle[0] += offset1;
	flAngle[1] += offset2;
	GetAngleVectors(flAngle, force, NULL_VECTOR, NULL_VECTOR);
	flDistance = flGetRayDistance(pos, flAngle, entity, type);

	return flDistance;
}

stock float flGetGroundUnits(int entity)
{
	if (!(GetEntityFlags(entity) & FL_ONGROUND))
	{
		static float flOrigin[3], flPosition[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);

		static Handle hTrace;
		hTrace = TR_TraceRayFilterEx(flOrigin, view_as<float>({90.0, 0.0, 0.0}), CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, bTraceRayDontHitSelf, entity);
		if (hTrace != null)
		{
			if (TR_DidHit(hTrace))
			{
				static float flUnits;
				TR_GetEndPosition(flPosition, hTrace);
				flUnits = flOrigin[2] - flPosition[2];

				delete hTrace;

				return flUnits;
			}

			delete hTrace;
		}
	}

	return 0.0;
}

stock float flGetKeyValue(const char[] subsection, const char[] sub1, const char[] sub2, const char[] sub3, const char[] sub4, const char[] key, const char[] setting, const char[] setting2, const char[] setting3, const char[] setting4, float curVal, const char[] value, float min, float max)
{
	if (StrContains(subsection, ",") != -1)
	{
		static char sSet[16][16];
		ExplodeString(subsection, ",", sSet, sizeof(sSet), sizeof(sSet[]));
		for (int iPos = 0; iPos < sizeof(sSet); iPos++)
		{
			if (sSet[iPos][0] != '\0' && value[0] != '\0' && (StrEqual(sSet[iPos], "all", false) || StrEqual(sSet[iPos], sub1, false) || StrEqual(sSet[iPos], sub2, false) || StrEqual(sSet[iPos], sub3, false) || StrEqual(sSet[iPos], sub4, false))
				&& (StrEqual(key, setting, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
			{
				return flGetKeywordValue(key, curVal, value, min, max);
			}
		}
	}
	else if (value[0] != '\0' && (StrEqual(subsection, "all", false) || StrEqual(subsection, sub1, false) || StrEqual(subsection, sub2, false) || StrEqual(subsection, sub3, false) || StrEqual(subsection, sub4, false))
		&& (StrEqual(key, setting, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
	{
		return flGetKeywordValue(key, curVal, value, min, max);
	}

	return curVal;
}

stock float flGetKeywordValue(const char[] key, float curVal, const char[] value, float min, float max)
{
	if (StrEqual(value, "default", false))
	{
		return curVal;
	}
	else if (StrEqual(value, "min", false))
	{
		return min;
	}
	else if (StrEqual(value, "max", false))
	{
		return max;
	}
	else if (StrContains(key, "chance", false) != -1 && min == 0.0 && max == 100.0)
	{
		if (StrEqual(value, "never", false))
		{
			return min;
		}
		else if (StrEqual(value, "sometimes", false) || StrEqual(value, "unlikely", false) || StrEqual(value, "seldom", false))
		{
			return 33.3;
		}
		else if (StrEqual(value, "maybe", false))
		{
			return max / 2.0;
		}
		else if (StrEqual(value, "often", false) || StrEqual(value, "likely", false) || StrEqual(value, "frequently", false))
		{
			return 66.6;
		}
		else if (StrEqual(value, "always", false))
		{
			return max;
		}
	}
	else if ((min == -1.0 || min == 1.0) && max == 999999.0)
	{
		if (min == -1.0 && StrContains(key, "damage", false) != -1 && (StrEqual(value, "nodmg", false) || StrEqual(value, "friendly", false) || StrEqual(value, "harmless", false)))
		{
			return 0.0;
		}
		else if ((StrContains(key, "damage", false) != -1 && StrEqual(value, "weakest", false)) || (StrContains(key, "range", false) != -1 && StrEqual(value, "closest", false)))
		{
			return min;
		}
		else if ((StrContains(key, "damage", false) != -1 && StrEqual(value, "strongest", false)) || (StrContains(key, "range", false) != -1 && StrEqual(value, "farthest", false)))
		{
			return max;
		}
	}
	else if (StrContains(key, "open", false) == 0 && min == 0.0 && max == 999999.0)
	{
		if (StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false))
		{
			return min;
		}
		else if (StrEqual(value, "farthest", false))
		{
			return max;
		}
	}
	else if ((StrContains(key, "cooldown", false) != -1 || StrContains(key, "delay", false) != -1 || StrContains(key, "duration", false) != -1 || StrContains(key, "interval", false) != -1 || StrContains(key, "lifetime", false) != -1) && (min == -1.0 || min == 0.0 || min == 0.1) && max == 999999.0)
	{
		if (min == 0.0 && (StrEqual(value, "never", false) || StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false)))
		{
			return min;
		}
		else if (StrEqual(value, "milli", false) || StrEqual(value, "millisecond", false))
		{
			return (min == 0.1) ? min : 0.1;
		}
		else if (StrEqual(value, "second", false))
		{
			return 1.0;
		}
		else if (StrEqual(value, "minute", false))
		{
			return 60.0;
		}
		else if (StrEqual(value, "forever", false))
		{
			return max;
		}
	}
	else if (StrContains(key, "height", false) != -1 && min == 0.1 && max == 999999.0)
	{
		if (StrEqual(value, "shortest", false))
		{
			return min;
		}
		else if (StrEqual(value, "tallest", false))
		{
			return max;
		}
	}

	return flClamp(StringToFloat(value), min, max);
}

stock float flGetRayDistance(float pos[3], float angle[3], int entity, int type)
{
	static float flHitPos[3];
	iGetRayHitPos(pos, angle, flHitPos, entity, false, type);
	return GetVectorDistance(pos, flHitPos);
}

stock float flGetSettingValue(bool apply, bool human, float playerVal, float typeVal, int overrideLevel = 0, float overrideVal = 0.0)
{
	if (apply)
	{
		switch (overrideLevel)
		{
			case 0: return (human && playerVal > overrideVal) ? playerVal : typeVal;
			case 1: return (human && playerVal >= overrideVal) ? playerVal : typeVal;
			case 2: return (human && playerVal != overrideVal) ? playerVal : typeVal;
		}
	}

	return (overrideLevel == 1) ? -1.0 : 0.0;
}

stock float flGetTemporaryHealth(int player, float decay)
{
	static float flHealth;
	flHealth = GetEntPropFloat(player, Prop_Send, "m_healthBuffer");
	flHealth -= (GetGameTime() - GetEntPropFloat(player, Prop_Send, "m_healthBufferTime")) * decay;
	return (flHealth < 0.0) ? 0.0 : flHealth;
}

stock int iClamp(int value, int min, int max)
{
	if (value < min)
	{
		return min;
	}
	else if (value > max)
	{
		return max;
	}

	return value;
}

stock int iGetBotSurvivor()
{
	for (int iBot = MaxClients; iBot > 0; iBot--)
	{
		if (bIsBotSurvivor(iBot, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			return iBot;
		}
	}

	return -1;
}

stock int iGetHumanCount(bool infected = false)
{
	static bool bValidPlayer;
	bValidPlayer = false;
	static int iHumanCount;
	iHumanCount = 0;
	for (int iHuman = 1; iHuman <= MaxClients; iHuman++)
	{
		bValidPlayer = infected ? bIsInfected(iHuman, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) : bIsSurvivor(iHuman, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT);
		if (bValidPlayer)
		{
			iHumanCount++;
		}
	}

	return iHumanCount;
}

stock int iGetIdleBot(int bot)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == bot)
		{
			return iBot;
		}
	}

	return 0;
}

stock int iGetIdlePlayer(int bot)
{
	if (bIsBotSurvivor(bot))
	{
		static char sClassname[32];
		GetEntityNetClass(bot, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "SurvivorBot"))
		{
			static int iIdler;
			iIdler = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));
			if (iIdler > 0 && bIsValidClient(iIdler, MT_CHECK_INGAME) && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}

	return 0;
}

stock int iGetKeyValue(const char[] subsection, const char[] sub1, const char[] sub2, const char[] sub3, const char[] sub4, const char[] key, const char[] setting, const char[] setting2, const char[] setting3, const char[] setting4, int curVal, const char[] value, int min, int max)
{
	if (StrContains(subsection, ",") != -1)
	{
		static char sSet[16][16];
		ExplodeString(subsection, ",", sSet, sizeof(sSet), sizeof(sSet[]));
		for (int iPos = 0; iPos < sizeof(sSet); iPos++)
		{
			if (sSet[iPos][0] != '\0' && value[0] != '\0' && (StrEqual(sSet[iPos], "all", false) || StrEqual(sSet[iPos], sub1, false) || StrEqual(sSet[iPos], sub2, false) || StrEqual(sSet[iPos], sub3, false) || StrEqual(sSet[iPos], sub4, false))
				&& (StrEqual(key, setting, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
			{
				return iGetKeywordValue(key, curVal, value, min, max);
			}
		}
	}
	else if (value[0] != '\0' && (StrEqual(subsection, "all", false) || StrEqual(subsection, sub1, false) || StrEqual(subsection, sub2, false) || StrEqual(subsection, sub3, false) || StrEqual(subsection, sub4, false))
		&& (StrEqual(key, setting, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false)))
	{
		return iGetKeywordValue(key, curVal, value, min, max);
	}

	return curVal;
}

stock int iGetKeywordValue(const char[] key, int curVal, const char[] value, int min, int max)
{
	if (StrEqual(value, "default", false))
	{
		return curVal;
	}
	else if (StrEqual(value, "min", false))
	{
		return min;
	}
	else if (StrEqual(value, "max", false))
	{
		return max;
	}
	else if (min == 0 && max == 1)
	{
		if (StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false))
		{
			return min;
		}
		else if (StrEqual(value, "enabled", false) || StrEqual(value, "true", false) || StrEqual(value, "on", false) || StrEqual(value, "yes", false))
		{
			return max;
		}
	}
	else if ((StrContains(key, "hitmode", false) != -1 || StrContains(key, "hit mode", false) != -1 || StrContains(key, "hit_mode", false) != -1) && min == 0 && max == 2)
	{
		if (StrEqual(value, "both", false) || StrEqual(value, "all", false))
		{
			return min;
		}
		else if (StrEqual(value, "tank", false) || StrEqual(value, "attack", false))
		{
			return 1;
		}
		else if (StrEqual(value, "survivor", false) || StrEqual(value, "hurt", false))
		{
			return max;
		}
	}
	else if (StrContains(key, "effect", false) != -1 && min == 0 && max == 7)
	{
		if (StrEqual(value, "none", false) || StrEqual(value, "off", false))
		{
			return min;
		}
		else if (StrEqual(value, "attack", false))
		{
			return 1;
		}
		else if (StrEqual(value, "hurt", false))
		{
			return 2;
		}
		else if (StrEqual(value, "attack,hurt", false))
		{
			return 3;
		}
		else if (StrEqual(value, "range", false))
		{
			return 4;
		}
		else if (StrEqual(value, "attack,range", false))
		{
			return 5;
		}
		else if (StrEqual(value, "hurt,range", false))
		{
			return 6;
		}
		else if (StrEqual(value, "attack,hurt,range", false) || StrEqual(value, "all", false))
		{
			return max;
		}
	}
	else if (StrContains(key, "message", false) != -1 && min == 0 && (max == 3 || max == 7))
	{
		if (StrEqual(value, "none", false) || StrEqual(value, "off", false))
		{
			return min;
		}
		else if (StrEqual(value, "hit", false))
		{
			return 1;
		}
		else if (StrEqual(value, "ability", false))
		{
			return 2;
		}
		else if ((max == 3 && (StrEqual(value, "both", false) || StrEqual(value, "all", false))) || StrEqual(value, "hit,ability", false))
		{
			return (max == 3) ? max : 3;
		}
		else if (max == 7)
		{
			if (StrEqual(value, "rock", false))
			{
				return 4;
			}
			else if (StrEqual(value, "hit,rock", false))
			{
				return 5;
			}
			else if (StrEqual(value, "ability,rock", false))
			{
				return 6;
			}
			else if (StrEqual(value, "hit,ability,rock", false) || StrEqual(value, "all", false))
			{
				return max;
			}
		}
	}
	else if ((StrContains(key, "humanammo", false) != -1 || StrContains(key, "human ammo", false) != -1 || StrContains(key, "human_ammo", false) != -1 || StrContains(key, "hammo", false) != -1) && min == 0 && max == 999999)
	{
		if (StrEqual(value, "none", false) || StrEqual(value, "off", false))
		{
			return min;
		}
		else if (StrEqual(value, "infinite", false))
		{
			return max;
		}
	}
	else if ((StrContains(key, "cooldown", false) != -1 || StrContains(key, "delay", false) != -1 || StrContains(key, "duration", false) != -1 || StrContains(key, "interval", false) != -1 || StrContains(key, "lifetime", false) != -1) && (min == 0 || min == 1) && max == 999999)
	{
		if (min == 0 && (StrEqual(value, "never", false) || StrEqual(value, "disabled", false) || StrEqual(value, "false", false) || StrEqual(value, "off", false) || StrEqual(value, "no", false)))
		{
			return min;
		}
		else if (StrEqual(value, "second", false))
		{
			return (min == 1) ? min : 1;
		}
		else if (StrEqual(value, "minute", false))
		{
			return 60;
		}
		else if (StrEqual(value, "forever", false))
		{
			return max;
		}
	}

	return iClamp(StringToInt(value), min, max);
}

stock int iGetPlayerCount()
{
	static int iPlayerCount;
	iPlayerCount = 0;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
		{
			iPlayerCount++;
		}
	}

	return iPlayerCount;
}

stock int iGetRandomColor(int color)
{
	return (color == -1 || color < 0 || color > 255) ? GetRandomInt(0, 255) : color;
}

stock int iGetRandomSurvivor(int tank)
{
	static int iSurvivorCount, iSurvivors[MAXPLAYERS + 1];
	iSurvivorCount = 0;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (MT_IsAdminImmune(iSurvivor, tank) || !bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			continue;
		}

		iSurvivors[iSurvivorCount++] = iSurvivor;
	}

	return iSurvivors[GetRandomInt(0, iSurvivorCount - 1)];
}

stock int iGetRandomTank(int tank)
{
	static int iTankCount, iTanks[MAXPLAYERS + 1];
	iTankCount = 0;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && iTank != tank)
		{
			iTanks[iTankCount++] = iTank;
		}
	}

	return iTanks[GetRandomInt(0, iTankCount - 1)];
}

stock int iGetRayHitPos(float pos[3], float angle[3], float hitpos[3], int entity = 0, bool offset = false, int type)
{
	static Handle hTrace;
	switch (type)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndPlayer, entity);
		case 3: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndSurvivor, entity);
		case 4: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndInfected, entity);
		case 5: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndCommons, entity);
	}

	static int iHit;
	iHit = 0;
	if (hTrace != null)
	{
		if (TR_DidHit(hTrace))
		{
			TR_GetEndPosition(hitpos, hTrace);
			iHit = TR_GetEntityIndex(hTrace);
		}

		delete hTrace;
	}

	if (offset)
	{
		static float flVector[3];
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

stock int iGetSettingValue(bool apply, bool human, int playerVal, int typeVal, int overrideLevel = 0, int overrideVal = 0)
{
	if (apply)
	{
		switch (overrideLevel)
		{
			case 0: return (human && playerVal > overrideVal) ? playerVal : typeVal;
			case 1: return (human && playerVal >= overrideVal) ? playerVal : typeVal;
			case 2: return (human && playerVal != overrideVal) ? playerVal : typeVal;
		}
	}

	return (overrideLevel == 1) ? -1 : 0;
}

stock int iGetWeaponOffset(const char[] weapon)
{
	static bool bSecondGame;
	bSecondGame = GetEngineVersion() == Engine_Left4Dead2;
	if (StrEqual(weapon, "weapon_rifle") || StrEqual(weapon, "weapon_rifle_ak47") || StrEqual(weapon, "weapon_rifle_desert") || StrEqual(weapon, "weapon_rifle_sg552"))
	{
		return 3;
	}
	else if (StrEqual(weapon, "weapon_smg") || StrEqual(weapon, "weapon_smg_silenced") || StrEqual(weapon, "weapon_smg_mp5"))
	{
		return 5;
	}
	else if (StrEqual(weapon, "weapon_shotgun_chrome"))
	{
		return 7;
	}
	else if (StrEqual(weapon, "weapon_pumpshotgun"))
	{
		return bSecondGame ? 7 : 6;
	}
	else if (StrEqual(weapon, "weapon_shotgun_spas"))
	{
		return 8;
	}
	else if (StrEqual(weapon, "weapon_autoshotgun"))
	{
		return bSecondGame ? 8 : 6;
	}
	else if (StrEqual(weapon, "weapon_hunting_rifle"))
	{
		return bSecondGame ? 9 : 2;
	}
	else if (StrEqual(weapon, "weapon_sniper_military") || StrEqual(weapon, "weapon_sniper_scout") || StrEqual(weapon, "weapon_sniper_awp"))
	{
		return 10;
	}
	else if (StrEqual(weapon, "weapon_grenade_launcher"))
	{
		return 17;
	}

	return 0;
}

stock int iGetWitchCount()
{
	static int iWitchCount, iWitch;
	iWitchCount = 0;
	iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}

	return iWitchCount;
}

stock int iPrecacheParticle(const char[] particlename)
{
	static int iTable = INVALID_STRING_TABLE;
	if (iTable == INVALID_STRING_TABLE)
	{
		iTable = FindStringTable("ParticleEffectNames");
	}

	int iIndex = FindStringIndex(iTable, particlename);
	if (iIndex == INVALID_STRING_INDEX)
	{
		bool bSave = LockStringTables(false);
		AddToStringTable(iTable, particlename);
		LockStringTables(bSave);
		iIndex = FindStringIndex(iTable, particlename);
	}

	return iIndex;
}