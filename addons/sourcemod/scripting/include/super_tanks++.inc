/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if defined _supertanksplusplus_included
	#endinput
#endif
#define _supertanksplusplus_included

#include <sdktools>

#define ST_AUTHOR "Psyk0tik (Crasher_3637)"
#define ST_VERSION "8.50"
#define ST_URL "https://forums.alliedmods.net/showthread.php?t=302140"

#define ST_TAG "[ST++]"
#define ST_TAG2 "\x04[ST++]\x01"
#define ST_TAG3 "\x04[ST++]\x03"
#define ST_TAG4 "\x04[ST++]\x05"

#define ST_MAXTYPES 500
#define ST_MAXHEALTH 65535
#define ST_MAX_HEALTH_REDUCTION -65535

#define ST_MAIN_KEY IN_USE
#define ST_SUB_KEY IN_RELOAD
#define ST_SPECIAL_KEY IN_ZOOM
#define ST_SPECIAL_KEY2 IN_DUCK

static int g_iCurrentMode;

// Forwards
/**
 * Called every second to trigger the Super Tank's ability.
 * Use this forward for any passive abilities.
 *
 * @param tank			Client index of the Tank.
 **/
forward void ST_OnAbilityActivated(int tank);

/**
 * Called when a human-controlled Super Tank presses a button.
 * Use this forward to trigger abilities manually.
 *
 * @param tank			Client index of the Tank.
 * @param button		Button pressed.
 **/
forward void ST_OnButtonPressed(int tank, int button);

/**
 * Called when a human-controlled Super Tank releases a button.
 * Use this forward to trigger abilities manually.
 *
 * @param tank			Client index of the Tank.
 * @param button		Button released.
 **/
forward void ST_OnButtonReleased(int tank, int button);

/**
 * Called when the Super Tank changes types.
 * Use this forward to trigger any features/abilities/settings when a Super Tank changes types.
 *
 * @param tank			Client index of the Tank.
 **/
forward void ST_OnChangeType(int tank);

/**
 * Called when the config file is loaded.
 * Use this forward to load settings for the plugin.
 *
 * @param savepath		The savepath of the config.
 * @param main			Checks whether the main config or a custom config is being used.
 **/
forward void ST_OnConfigsLoaded(const char[] savepath, bool main);

/**
 * Called when a player uses the "sm_st_info" command.
 * Use this forward to add menu items.
 *
 * @param menu			Handle to the menu.
 **/
forward void ST_OnDisplayMenu(Menu menu);

/**
 * Called when an event hooked by the core plugin is fired.
 * Use this forward to trigger something on any of those events.
 *
 * @param event			Handle to the event.
 * @param name			String containing the name of the event.
 * @param dontBroadcast		True if event was not broadcast to clients, false otherwise.
 **/
forward void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast);

/**
 * Called when the core plugin is hooking/unhooking events.
 * Use this forward to hook/unhook events.
 *
 * @param mode			True if event was hooked, false otherwise.
 **/
forward void ST_OnHookEvent(bool mode);

/**
 * Called when a player selects an item from the "Super Tanks++ Information" menu.
 * Use this forward to do anything when an item is selected.
 *
 * @param client		Client index of the player selecting the item.
 * @param info			String containing the name of the item.
 **/
forward void ST_OnMenuItemSelected(int client, const char[] info);

/**
 * Called when the core plugin is unloaded/reloaded.
 * Use this forward to get rid of any modifications to Tanks or survivors.
 **/
forward void ST_OnPluginEnd();

/**
 * Called when the Tank spawns.
 * Use this forward for any on-spawn presets.
 * If you plan on using this to activate an ability, use ST_Ability() instead.
 *
 * @param tank			Client index of the Tank.
 **/
forward void ST_OnPreset(int tank);

/**
 * Called when the Tank's rock breaks.
 * Use this forward for any after-effects.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void ST_OnRockBreak(int tank, int rock);

/**
 * Called when the Tank throws a rock.
 * Use this forward for any throwing abilities.
 *
 * @param tank			Client index of the Tank.
 * @param rock			Entity index of the rock.
 **/
forward void ST_OnRockThrow(int tank, int rock);

// Natives
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
 * Returns the RGBA colors given to a Tank's props.
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
native void ST_PropsColors(int tank, int mode, int &red, int &green, int &blue, int &alpha);

/**
 * Returns if the core plugin is enabled.
 *
 * @return			True if core plugin is enabled, false otherwise.
 **/
native bool ST_PluginEnabled();

/**
 * Returns if a certain Super Tank type can spawn.
 *
 * @param type			Super Tank type.
 * @return			True if the type can spawn, false otherwise.
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
 * @param checks		Checks to run. 0 = client index, 1 = connection, 2 = in-game status,
 *				3 = life state, 4 = kick status, 5 = bot check
 *				Default: "0234"
 * @return			True if Tank is allowed to be a Super Tank, false otherwise.
 * @error			Invalid client index.
 **/
native bool ST_TankAllowed(int tank, const char[] checks = "0234");

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
 * @param red			Red color reference.
 * @param green			Green color reference.
 * @param blue			Blue color reference.
 * @param alpha			Alpha color reference.
 * @error			Invalid client index.
 **/
native void ST_TankColors(int tank, int mode, int &red, int &green, int &blue, int &alpha);

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

// Functions
stock void vAttachParticle(int player, const char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(player, "0234"))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(player, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;

			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);

			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, player);

			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vCheatCommand(int player, const char[] command, const char[] arguments = "")
{
	int iCmdFlags = GetCommandFlags(command);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(player, "%s %s", command, arguments);
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
	char sConfigFilename[PLATFORM_MAX_PATH], sFilename[PLATFORM_MAX_PATH];
	VFormat(sFilename, sizeof(sFilename), filename, 3);
	BuildPath(Path_SM, sConfigFilename, sizeof(sConfigFilename), "data/super_tanks++/%s%s.cfg", folder, sFilename);
	if (FileExists(sConfigFilename))
	{
		return;
	}

	File fFilename = OpenFile(sConfigFilename, "w+");
	if (fFilename != null)
	{
		fFilename.WriteLine("// This config file was auto-generated by Super Tanks++ v%s (%s)", ST_VERSION, ST_URL);
		fFilename.WriteLine("\n");

		delete fFilename;
	}
}

stock void vCreateParticle(int player, const char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(player, "0234"))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (bIsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(player, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;

			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);

			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, player);

			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vDamageEntity(int victim, int attacker, float damage, const char[] damagetype = "0")
{
	int iPointHurt = CreateEntityByName("point_hurt");
	if (bIsValidEntity(iPointHurt))
	{
		char sTargetName[32];
		Format(sTargetName, sizeof(sTargetName), "target%d", EntIndexToEntRef(victim));
		DispatchKeyValue(victim, "targetname", sTargetName);

		DispatchKeyValueFloat(iPointHurt, "Damage", damage);
		DispatchKeyValue(iPointHurt, "DamageTarget", sTargetName);
		DispatchKeyValue(iPointHurt, "DamageType", damagetype);

		DispatchSpawn(iPointHurt);
		AcceptEntityInput(iPointHurt, "Hurt", attacker);

		RemoveEntity(iPointHurt);
	}
}

stock void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];

		Format(sVariant, sizeof(sVariant), "OnUser1 !self:ClearParent::%f:1", time);
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");

		Format(sVariant, sizeof(sVariant), "OnUser1 !self:Kill::%f:1", time + 0.1);
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");

		AcceptEntityInput(entity, "FireUser1");
	}
}

stock void vEffect(int survivor, int tank, const char[] enabled, const char[] mode)
{
	if (StrContains(enabled, mode) != -1)
	{
		int iRed, iGreen, iBlue, iAlpha;
		ST_TankColors(tank, GetRandomInt(1, 2), iRed, iGreen, iBlue, iAlpha);

		Handle hFadeTarget = StartMessageOne("Fade", survivor);
		if (hFadeTarget != null)
		{
			BfWrite bfWrite = UserMessageToBfWrite(hFadeTarget);
			bfWrite.WriteShort(800);
			bfWrite.WriteShort(300);
			bfWrite.WriteShort((0x0010|0x0001));
			bfWrite.WriteByte(iRed);
			bfWrite.WriteByte(iGreen);
			bfWrite.WriteByte(iBlue);
			bfWrite.WriteByte(150);

			EndMessage();
		}
	}
}

stock void vExternalView(int player, float time)
{
	if (bIsValidGame() && GetEntPropFloat(player, Prop_Send, "m_TimeForceExternalView") != 99999.3)
	{
		SetEntPropFloat(player, Prop_Send, "m_TimeForceExternalView", GetGameTime() + time);
	}
}

public void vGameMode(const char[] output, int caller, int activator, float delay)
{
	if (StrEqual(output, "OnCoop"))
	{
		g_iCurrentMode = 1;
	}
	else if (StrEqual(output, "OnVersus"))
	{
		g_iCurrentMode = 2;
	}
	else if (StrEqual(output, "OnSurvival"))
	{
		g_iCurrentMode = 4;
	}
	else if (StrEqual(output, "OnScavenge"))
	{
		g_iCurrentMode = 8;
	}
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
			RemoveMultiTargetFilter("@special", bSpecialFilter);
			RemoveMultiTargetFilter("@infected", bInfectedFilter);
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
			AddMultiTargetFilter("@special", bSpecialFilter, "all Special Infected", false);
			AddMultiTargetFilter("@infected", bInfectedFilter, "all Infected", false);
		}
	}
}

stock void vPrecacheParticle(const char[] particlename)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (bIsValidEntity(iParticle))
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

stock void vSpawnInfected(int tank, const char[] infected)
{
	ChangeClientTeam(tank, 3);
	vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", infected);
	KickClient(tank);
}

stock void vSpecialAttack(int tank, float pos[3], float offset, const char[] model)
{
	int iProp = CreateEntityByName("prop_physics");
	if (bIsValidEntity(iProp))
	{
		DispatchKeyValue(iProp, "disableshadows", "1");
		SetEntityModel(iProp, model);

		pos[2] += offset;
		TeleportEntity(iProp, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iProp);

		SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", tank);
		SetEntPropFloat(iProp, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());

		SetEntProp(iProp, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iProp, 0, 0, 0, 0);

		AcceptEntityInput(iProp, "Break");
	}
}

// Chat
stock void ST_PrintToChat(int client, char[] message, any ...)
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

stock void ST_PrintToChatAll(char[] message, any ...)
{
	char sBuffer[255];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "25"))
		{
			SetGlobalTransTarget(iPlayer);
			VFormat(sBuffer, sizeof(sBuffer), message, 2);

			ST_PrintToChat(iPlayer, sBuffer);
		}
	}
}

// Checks
stock bool bHasIdlePlayer(int survivor)
{
	char sClassname[32];
	GetEntityNetClass(survivor, sClassname, sizeof(sClassname));

	if (StrEqual(sClassname, "SurvivorBot"))
	{
		int iSpectatorUserId = GetEntProp(survivor, Prop_Send, "m_humanSpectatorUserID");
		if (iSpectatorUserId > 0)
		{
			int iIdler = GetClientOfUserId(iSpectatorUserId);
			if (iIdler > 0 && bIsValidClient(iIdler, "25") && GetClientTeam(iIdler) != 2)
			{
				return true;
			}
		}
	}

	return false;
}

stock bool bIsBoomer(int boomer, const char[] mode = "024")
{
	return bIsInfected(boomer, mode) && GetEntProp(boomer, Prop_Send, "m_zombieClass") == 2;
}

stock bool bIsBotIdle(int bot, const char[] mode = "0234")
{
	return bIsSurvivor(bot, mode) && !bIsValidClient(bot, "5") && bHasIdlePlayer(bot);
}

stock bool bIsBotIdleSurvivor(int bot, const char[] mode = "0234")
{
	return bIsSurvivor(bot, mode) && !bIsValidClient(bot, "5") && !bHasIdlePlayer(bot);
}

stock bool bIsBotSurvivor(int bot, const char[] mode = "0234")
{
	return bIsSurvivor(bot, mode) && !bIsValidClient(bot, "5");
}

stock bool bIsCharger(int charger, const char[] mode = "024")
{
	return bIsInfected(charger, mode) && GetEntProp(charger, Prop_Send, "m_zombieClass") == 6;
}

stock bool bIsEntityGrounded(int entity)
{
	if ((HasEntProp(entity, Prop_Send, "m_fFlags") && (GetEntProp(entity, Prop_Send, "m_fFlags") & FL_ONGROUND)) || (HasEntProp(entity, Prop_Send, "m_hGroundEntity") && GetEntPropEnt(entity, Prop_Send, "m_hGroundEntity") == 0))
	{
		return true;
	}

	return false;
}

stock bool bIsFinaleMap()
{
	return FindEntityByClassname(-1, "trigger_finale") != -1;
}

stock bool bIsGunWeapon(int survivor)
{
	char sWeapon[32];
	GetClientWeapon(survivor, sWeapon, sizeof(sWeapon));

	if (GetPlayerWeaponSlot(survivor, 0) > 0 || (GetPlayerWeaponSlot(survivor, 1) > 0 && StrContains(sWeapon, "pistol", false) != -1))
	{
		return true;
	}

	return false;
}

stock bool bIsHumanSurvivor(int survivor, const char[] mode = "02345")
{
	return bIsSurvivor(survivor, mode) && !bHasIdlePlayer(survivor) && !bIsPlayerIdle(survivor);
}

stock bool bIsHunter(int hunter, const char[] mode = "024")
{
	return bIsInfected(hunter, mode) && GetEntProp(hunter, Prop_Send, "m_zombieClass") == 3;
}

stock bool bIsIdlePlayer(int bot, int survivor, const char[] mode = "0245")
{
	return bIsValidClient(survivor, mode) && GetClientTeam(bot) == 2;
}

stock bool bIsInfected(int infected, const char[] mode = "024")
{
	return bIsValidClient(infected, mode) && GetClientTeam(infected) == 3;
}

stock bool bIsJockey(int jockey, const char[] mode = "024")
{
	return bIsInfected(jockey, mode) && bIsValidGame() && GetEntProp(jockey, Prop_Send, "m_zombieClass") == 5;
}

stock bool bIsPlayerBurning(int player)
{
	if (GetEntPropFloat(player, Prop_Send, "m_burnPercent") > 0.0 || GetEntProp(player, Prop_Data, "m_fFlags") & FL_ONFIRE)
	{
		return true;
	}

	return false;
}

stock bool bIsPlayerIdle(int survivor)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!bIsValidClient(iPlayer, "2") || bIsValidClient(iPlayer, "5") || !bHasIdlePlayer(iPlayer) || GetClientTeam(iPlayer) != 2)
		{
			continue;
		}

		char sClassname[32];
		GetEntityNetClass(iPlayer, sClassname, sizeof(sClassname));

		if (StrEqual(sClassname, "SurvivorBot"))
		{
			int iSpectatorUserId = GetEntProp(iPlayer, Prop_Send, "m_humanSpectatorUserID");
			if (iSpectatorUserId > 0)
			{
				int iIdler = GetClientOfUserId(iSpectatorUserId);
				if (iIdler == survivor)
				{
					return true;
				}
			}
		}
	}

	return false;
}

stock bool bIsPlayerIncapacitated(int survivor)
{
	if (GetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1))
	{
		return true;
	}

	return false;
}

stock bool bIsPluginEnabled(ConVar gamemode, int mode, char[] enabled, char[] disabled)
{
	if (gamemode == null)
	{
		return false;
	}

	if (mode != 0)
	{
		g_iCurrentMode = 0;

		int iGameMode = CreateEntityByName("info_gamemode");
		if (bIsValidEntity(iGameMode))
		{
			DispatchSpawn(iGameMode);

			HookSingleEntityOutput(iGameMode, "OnCoop", vGameMode, true);
			HookSingleEntityOutput(iGameMode, "OnSurvival", vGameMode, true);
			HookSingleEntityOutput(iGameMode, "OnVersus", vGameMode, true);
			HookSingleEntityOutput(iGameMode, "OnScavenge", vGameMode, true);

			ActivateEntity(iGameMode);
			AcceptEntityInput(iGameMode, "PostSpawnActivate");
			RemoveEntity(iGameMode);
		}

		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}

	char sGameMode[32], sGameModes[513];
	gamemode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	if (!StrEqual(enabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", enabled);
		if (StrContains(sGameModes, sGameMode, false) == -1)
		{
			return false;
		}
	}

	if (!StrEqual(disabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", disabled);
		if (StrContains(sGameModes, sGameMode, false) != -1)
		{
			return false;
		}
	}

	return true;
}

stock bool bIsSmoker(int smoker, const char[] mode = "024")
{
	return bIsInfected(smoker, mode) && GetEntProp(smoker, Prop_Send, "m_zombieClass") == 1;
}

stock bool bIsSpecialInfected(int infected, const char[] mode = "024")
{
	return bIsSmoker(infected, mode) || bIsBoomer(infected, mode) || bIsHunter(infected, mode) || bIsSpitter(infected, mode) || bIsJockey(infected, mode) || bIsCharger(infected, mode);
}

stock bool bIsSpitter(int spitter, const char[] mode = "024")
{
	return bIsInfected(spitter, mode) && GetEntProp(spitter, Prop_Send, "m_zombieClass") == 4;
}

stock bool bIsSurvivor(int survivor, const char[] mode = "0234")
{
	return bIsValidClient(survivor, mode) && GetClientTeam(survivor) == 2;
}

stock bool bIsTank(int tank, const char[] mode = "0234")
{
	return bIsInfected(tank, mode) && (bIsValidGame() ? GetEntProp(tank, Prop_Send, "m_zombieClass") == 8 : GetEntProp(tank, Prop_Send, "m_zombieClass") == 5);
}

stock bool bIsTankThirdPerson(int tank, const char[] mode = "02345")
{
	if ((bIsValidGame() && GetEntPropFloat(tank, Prop_Send, "m_TimeForceExternalView") > GetGameTime()) || GetEntPropFloat(tank, Prop_Send, "m_staggerTimer", 1) > -1.0 || GetEntPropEnt(tank, Prop_Send, "m_hViewEntity") > 0)
	{
		return true;
	}

	if (bIsTank(tank, mode))
	{
		switch (GetEntProp(tank, Prop_Send, "m_nSequence"))
		{
			case 28, 29, 30, 31, 49, 50, 51, 73, 74, 75, 76, 77: return true;
		}
	}
	
	return false;
}

stock bool bIsValidClient(int player, const char[] mode = "024")
{
	if (StrContains(mode, "0") != -1 && (player <= 0 || player > MaxClients))
	{
		return false;
	}

	if (StrContains(mode, "1") != -1 && !IsClientConnected(player))
	{
		return false;
	}

	if (StrContains(mode, "2") != -1 && !IsClientInGame(player))
	{
		return false;
	}

	if (StrContains(mode, "3") != -1 && !IsPlayerAlive(player))
	{
		return false;
	}

	if (StrContains(mode, "4") != -1 && IsClientInKickQueue(player))
	{
		return false;
	}

	if (StrContains(mode, "5") != -1 && IsFakeClient(player))
	{
		return false;
	}

	return true;
}

stock bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

stock bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

stock bool bIsValidGame(bool l4d2 = true)
{
	EngineVersion evEngine = GetEngineVersion();

	return l4d2 ? evEngine == Engine_Left4Dead2 : evEngine == Engine_Left4Dead;
}

stock bool bIsWitch(int witch)
{
	if (bIsValidEntity(witch))
	{
		char sClassname[32];
		GetEntityClassname(witch, sClassname, sizeof(sClassname));

		if (StrEqual(sClassname, "witch"))
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
		if (bIsBoomer(iPlayer, "234"))
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
		if (bIsCharger(iPlayer, "234"))
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
		if (bIsHunter(iPlayer, "234"))
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
		if (bIsInfected(iPlayer, "234"))
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
		if (bIsJockey(iPlayer, "234"))
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
		if (bIsSmoker(iPlayer, "234"))
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
		if (bIsSpecialInfected(iPlayer, "234"))
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
		if (bIsSpitter(iPlayer, "234"))
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
		if (bIsTank(iPlayer, "234"))
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
	if (entity == data || bIsValidClient(entity, "024"))
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

// Values
stock float flClamp(float value, float min, float max)
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
		float flOrigin[3], flPosition[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);

		Handle hTrace = TR_TraceRayFilterEx(flOrigin, view_as<float>({90.0, 0.0, 0.0}), CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, bTraceRayDontHitSelf, entity);
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

stock float flGetNearestSurvivor(int tank)
{
	float flDistance;
	if (bIsTank(tank))
	{
		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);

				break;
			}
		}
	}

	return flDistance;
}

stock float flGetRayDistance(float pos[3], float angle[3], int entity, int trace)
{
	float flHitPos[3];
	iGetRayHitPos(pos, angle, flHitPos, entity, false, trace);

	return GetVectorDistance(pos, flHitPos);
}

stock int iClamp(int value, int min, int max)
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
	for (int iBot = MaxClients; iBot > 0; iBot--)
	{
		if (bIsBotSurvivor(iBot, "234"))
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
		if (bIsHumanSurvivor(iHuman, "2345"))
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
		char sClassname[32];
		GetEntityNetClass(bot, sClassname, sizeof(sClassname));

		if (StrEqual(sClassname, "SurvivorBot"))
		{
			int iIdler = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));
			if (iIdler > 0 && bIsValidClient(iIdler, "2") && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}

	return 0;
}

stock int iGetPlayerCount()
{
	int iPlayerCount;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "245"))
		{
			iPlayerCount++;
		}
	}

	return iPlayerCount;
}

stock int iGetRandomSurvivor(int survivor)
{
	int iSurvivorCount, iSurvivors[MAXPLAYERS + 1];
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234") && iSurvivor != survivor)
		{
			iSurvivors[iSurvivorCount++] = iSurvivor;
		}
	}

	return iSurvivors[GetRandomInt(0, iSurvivorCount - 1)];
}

stock int iGetRandomTarget(float pos[3], float angle[3])
{
	float flMin = 4.0, flPos[3], flAngle;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234"))
		{
			GetClientEyePosition(iSurvivor, flPos);
			MakeVectorFromPoints(pos, flPos, flPos);
			flAngle = flGetAngle(angle, flPos);

			if (flAngle <= flMin)
			{
				flMin = flAngle;
				return iSurvivor;
			}
		}
	}

	return 0;
}

stock int iGetRayHitPos(float pos[3], float angle[3], float hitpos[3], int entity = 0, bool offset = false, int trace)
{
	Handle hTrace;
	switch (trace)
	{
		case 1: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, entity);
		case 2: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndPlayer, entity);
		case 3: hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndSurvivor, entity);
	}

	int iHit = 0;
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
	int iWitchCount, iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}

	return iWitchCount;
}

public SharedPlugin __pl_supertanksplusplus = 
{
	name = "super_tanks++",
	file = "super_tanks++.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_supertanksplusplus_SetNTVOptional()
{
	MarkNativeAsOptional("ST_MaxType");
	MarkNativeAsOptional("ST_MinType");
	MarkNativeAsOptional("ST_PluginEnabled");
	MarkNativeAsOptional("ST_PropsColors");
	MarkNativeAsOptional("ST_SpawnEnabled");
	MarkNativeAsOptional("ST_SpawnTank");
	MarkNativeAsOptional("ST_TankAllowed");
	MarkNativeAsOptional("ST_TankChance");
	MarkNativeAsOptional("ST_TankColors");
	MarkNativeAsOptional("ST_TankName");
	MarkNativeAsOptional("ST_TankType");
	MarkNativeAsOptional("ST_TankWave");
	MarkNativeAsOptional("ST_TypeEnabled");
}
#endif