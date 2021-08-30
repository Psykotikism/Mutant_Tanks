/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2021  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <dhooks>
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#tryinclude <adminmenu>
#tryinclude <clientprefs>
#tryinclude <left4dhooks>
#tryinclude <mt_clone>
#tryinclude <ThirdPersonShoulder_Detect>
#tryinclude <WeaponHandling>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = MT_NAME,
	author = MT_AUTHOR,
	description = MT_DESCRIPTION,
	version = MT_VERSION,
	url = MT_URL
};

#define MT_CORE_MAIN

bool g_bDedicated, g_bLateLoad, g_bSecondGame;

Handle g_hPluginHandle;

#undef REQUIRE_PLUGIN
#tryinclude "mutant_tanks/main/mt_defines.sp"
#tryinclude "mutant_tanks/main/mt_enumstructs.sp"
#tryinclude "mutant_tanks/main/mt_configs.sp"
#tryinclude "mutant_tanks/main/mt_gamedata.sp"
#tryinclude "mutant_tanks/main/mt_dependencies.sp"
#tryinclude "mutant_tanks/main/mt_patches.sp"
#tryinclude "mutant_tanks/main/mt_callbacks.sp"
#tryinclude "mutant_tanks/main/mt_commands.sp"
#tryinclude "mutant_tanks/main/mt_convars.sp"
#tryinclude "mutant_tanks/main/mt_detours.sp"
#tryinclude "mutant_tanks/main/mt_events.sp"
#tryinclude "mutant_tanks/main/mt_helpers.sp"
#tryinclude "mutant_tanks/main/mt_library.sp"
#tryinclude "mutant_tanks/main/mt_menus.sp"
#tryinclude "mutant_tanks/main/mt_parsers.sp"
#tryinclude "mutant_tanks/main/mt_rewards.sp"
#tryinclude "mutant_tanks/main/mt_survivors.sp"
#tryinclude "mutant_tanks/main/mt_tanks.sp"
#tryinclude "mutant_tanks/main/mt_timers.sp"
#define REQUIRE_PLUGIN

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"Mutant Tanks\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	vRegisterNatives();
	RegPluginLibrary("mutant_tanks");

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;
	g_hPluginHandle = myself;

	return APLRes_Success;
}

public void OnPluginStart()
{
	vRegisterForwards();
	vRegisterCommands();
	vRegisterConVars();

	for (int iDeveloper = 1; iDeveloper <= MaxClients; iDeveloper++)
	{
		vDeveloperSettings(iDeveloper);
	}

	vMultiTargetFilters(true);

	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

#if defined _clientprefs_included
	char sName[12], sDescription[36];
	for (int iPos = 0; iPos < sizeof esGeneral::g_ckMTAdmin; iPos++)
	{
		FormatEx(sName, sizeof sName, "MTAdmin%i", iPos + 1);
		FormatEx(sDescription, sizeof sDescription, "Mutant Tanks Admin Preference #%i", iPos + 1);
		g_esGeneral.g_ckMTAdmin[iPos] = new Cookie(sName, sDescription, CookieAccess_Private);
	}

	g_esGeneral.g_ckMTPrefs = new Cookie("MTPrefs", "Mutant Tanks Preferences", CookieAccess_Private);
#endif
	char sDate[32];
	FormatTime(sDate, sizeof sDate, "%Y-%m-%d", GetTime());
	BuildPath(Path_SM, g_esGeneral.g_sLogFile, sizeof esGeneral::g_sLogFile, "logs/mutant_tanks_%s.log", sDate);

	char sSMPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sSMPath, sizeof sSMPath, MT_CONFIG_PATH);
	CreateDirectory(sSMPath, 511);
	FormatEx(g_esGeneral.g_sSavePath, sizeof esGeneral::g_sSavePath, "%s%s", sSMPath, MT_CONFIG_FILE);

	switch (MT_FileExists(MT_CONFIG_PATH, MT_CONFIG_FILE, g_esGeneral.g_sSavePath, g_esGeneral.g_sSavePath, sizeof esGeneral::g_sSavePath))
	{
		case true: g_esGeneral.g_iFileTimeOld[0] = GetFileTime(g_esGeneral.g_sSavePath, FileTime_LastChange);
		case false: SetFailState("Unable to load the \"%s\" config file.", g_esGeneral.g_sSavePath);
	}

	vHookGlobalEvents();
	HookUserMessage(GetUserMessageId("SayText2"), umNameChange, true);
	vReadGameData();

	g_esGeneral.g_alFilePaths = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	if (g_bLateLoad)
	{
#if defined _adminmenu_included
		TopMenu tmAdminMenu = null;

		if (LibraryExists("adminmenu") && ((tmAdminMenu = GetAdminTopMenu()) != null))
		{
			OnAdminMenuReady(tmAdminMenu);
		}
#endif
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
			{
				OnClientPutInServer(iPlayer);
				OnClientPostAdminCheck(iPlayer);
#if defined _clientprefs_included
				if (bIsValidClient(iPlayer, MT_CHECK_FAKECLIENT) && AreClientCookiesCached(iPlayer))
				{
					OnClientCookiesCached(iPlayer);
				}
#endif
				if (bIsTank(iPlayer, MT_CHECK_ALIVE))
				{
					SDKHook(iPlayer, SDKHook_PostThinkPost, OnTankPostThinkPost);
				}
			}
		}

		int iEntity = -1;
		while ((iEntity = FindEntityByClassname(iEntity, "infected")) != INVALID_ENT_REFERENCE)
		{
			SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakePlayerDamage);
			SDKHook(iEntity, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
			SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}

		iEntity = -1;
		while ((iEntity = FindEntityByClassname(iEntity, "witch")) != INVALID_ENT_REFERENCE)
		{
			SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakePlayerDamage);
			SDKHook(iEntity, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
			SDKHook(iEntity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	g_esGeneral.g_bFinalMap = bIsFinalMap();
	g_esGeneral.g_bMapStarted = true;
	g_esGeneral.g_bNormalMap = bIsNormalMap();
	g_esGeneral.g_bSameMission = bGetMissionName();
	g_iBossBeamSprite = PrecacheModel("sprites/laserbeam.vmt", true);
	g_iBossHaloSprite = PrecacheModel("sprites/glow01.vmt", true);

	PrecacheModel(MODEL_CONCRETE_CHUNK, true);
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_OXYGENTANK, true);
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_TANK_MAIN, true);
	PrecacheModel(MODEL_TANK_DLC, true);
	PrecacheModel(MODEL_TIRES, true);
	PrecacheModel(MODEL_TREE_TRUNK, true);
	PrecacheModel(MODEL_WITCH, true);
	PrecacheModel(SPRITE_EXPLODE, true);

	iPrecacheParticle(PARTICLE_ACHIEVED);
	iPrecacheParticle(PARTICLE_BLOOD);
	iPrecacheParticle(PARTICLE_ELECTRICITY);
	iPrecacheParticle(PARTICLE_FIRE);
	iPrecacheParticle(PARTICLE_FIREWORK);
	iPrecacheParticle(PARTICLE_ICE);
	iPrecacheParticle(PARTICLE_METEOR);
	iPrecacheParticle(PARTICLE_SMOKE);

	switch (g_bSecondGame)
	{
		case true:
		{
			PrecacheModel(MODEL_FIREWORKCRATE, true);
			PrecacheModel(MODEL_TANK_L4D1, true);
			PrecacheModel(MODEL_WITCHBRIDE, true);

			PrecacheSound(SOUND_EXPLOSION2, true);
			PrecacheSound(SOUND_SPIT, true);

			iPrecacheParticle(PARTICLE_GORE);
			iPrecacheParticle(PARTICLE_SPIT);
			iPrecacheParticle(PARTICLE_SPIT2);
		}
		case false: PrecacheSound(SOUND_EXPLOSION1, true);
	}

	PrecacheSound(SOUND_ACHIEVEMENT, true);
	PrecacheSound(SOUND_DAMAGE, true);
	PrecacheSound(SOUND_DAMAGE2, true);
	PrecacheSound(SOUND_DEATH, true);
	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_METAL, true);
	PrecacheSound(SOUND_NULL, true);
	PrecacheSound(SOUND_SPAWN, true);

	vResetPlugin();
	vResetLadyKiller(false);
	vToggleLogging(1);

	AddNormalSoundHook(FallSoundHook);
}

public void OnClientPutInServer(int client)
{
	g_esGeneral.g_iPlayerCount[0] = iGetPlayerCount();
	g_esPlayer[client].g_iUserID = GetClientUserId(client);

	SDKHook(client, SDKHook_OnTakeDamage, OnTakeCombineDamage);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakePlayerDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakePlayerDamageAlive);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakePlayerDamageAlivePost);
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitchPost);

	vResetTank2(client);
	vCacheSettings(client);
	vResetCore(client);
}

public void OnClientDisconnect(int client)
{
	if (bIsTank(client) && !bIsValidClient(client, MT_CHECK_FAKECLIENT))
	{
		if (!bIsCustomTank(client))
		{
			g_esGeneral.g_iTankCount--;
		}

		vCalculateDeath(client, 0);
	}

	if (bIsValidClient(client))
	{
		vResetPlayer(client);
	}
}

public void OnClientDisconnect_Post(int client)
{
	g_esGeneral.g_iPlayerCount[0] = iGetPlayerCount();
}

public void OnConfigsExecuted()
{
	g_esGeneral.g_bConfigsExecuted = true;

	vDefaultConVarSettings();
	vLoadConfigs(g_esGeneral.g_sSavePath, 1);
	vSetupConfigs();
	vPluginStatus();
	vResetTimers();

	CreateTimer(0.1, tTimerRefreshRewards, .flags = TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(10.0, tTimerReloadConfigs, .flags = TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, tTimerRegenerateAmmo, .flags = TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, tTimerRegenerateHealth, .flags = TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

	g_esGeneral.g_iChosenType = 0;
	g_esGeneral.g_iRegularCount = 0;
	g_esGeneral.g_iTankCount = 0;
}

public void OnMapEnd()
{
	g_esGeneral.g_bMapStarted = false;
	g_esGeneral.g_bConfigsExecuted = false;

	vResetPlugin();
	vToggleLogging(0);

	RemoveNormalSoundHook(FallSoundHook);
}

public void OnPluginEnd()
{
	vRemoveCommands();
	vMultiTargetFilters(false);
	vClearSectionList();
	vRemovePermanentPatches();
	vTogglePlugin(false);

	if (g_esGeneral.g_alFilePaths != null)
	{
		g_esGeneral.g_alFilePaths.Clear();

		delete g_esGeneral.g_alFilePaths;
	}

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			vResetTank(iTank);
		}
	}

	Call_StartForward(g_esGeneral.g_gfPluginEndForward);
	Call_Finish();
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(entity))
	{
		g_esGeneral.g_bWitchKilled[entity] = false;
		g_esGeneral.g_iTeamID[entity] = 0;

		if (StrEqual(classname, "tank_rock"))
		{
			RequestFrame(vRockThrowFrame, EntIndexToEntRef(entity));
		}
		else if (StrEqual(classname, "infected") || StrEqual(classname, "witch"))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnInfectedSpawnPost);
		}
		else if (StrEqual(classname, "inferno") || StrEqual(classname, "pipe_bomb_projectile") || (g_bSecondGame && (StrEqual(classname, "fire_cracker_blast") || StrEqual(classname, "grenade_launcher_projectile"))))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnEffectSpawnPost);
		}
		else if (StrEqual(classname, "physics_prop") || StrEqual(classname, "prop_physics"))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnPropSpawnPost);
		}
		else if (StrEqual(classname, "prop_fuel_barrel"))
		{
			SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(entity))
	{
		char sClassname[32];
		GetEntityClassname(entity, sClassname, sizeof sClassname);
		if (StrEqual(sClassname, "tank_rock"))
		{
			int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
			if (bIsTankSupported(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esCache[iThrower].g_iTankEnabled == 1)
			{
				Call_StartForward(g_esGeneral.g_gfRockBreakForward);
				Call_PushCell(iThrower);
				Call_PushCell(entity);
				Call_Finish();

				vCombineAbilitiesForward(iThrower, MT_COMBO_ROCKBREAK, .weapon = entity);
			}
		}
		else if (StrEqual(sClassname, "infected") || StrEqual(sClassname, "witch"))
		{
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakePlayerDamage);
			SDKUnhook(entity, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
			SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
		}
	}
}

public void OnGameFrame()
{
	if (g_esGeneral.g_bPluginEnabled)
	{
		char sHealthBar[51], sSet[2][2];
		float flPercentage = 0.0;
		int iTarget = 0, iHealth = 0, iMaxHealth = 0, iTotalHealth = 0;
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
			{
				iTarget = GetClientAimTarget(iPlayer);
				if (bIsTank(iTarget))
				{
					if (bIsTankIdle(iTarget, 1) && bIsSurvivor(iPlayer))
					{
						continue;
					}

					sHealthBar[0] = '\0';
					iHealth = bIsPlayerIncapacitated(iTarget) ? 0 : GetEntProp(iTarget, Prop_Data, "m_iHealth");
					iMaxHealth = GetEntProp(iTarget, Prop_Data, "m_iMaxHealth");
					iTotalHealth = (iHealth > iMaxHealth) ? iHealth : iMaxHealth;
					flPercentage = ((float(iHealth) / float(iTotalHealth)) * 100.0);

					ReplaceString(g_esCache[iTarget].g_sHealthCharacters, sizeof esCache::g_sHealthCharacters, " ", "");
					ExplodeString(g_esCache[iTarget].g_sHealthCharacters, ",", sSet, sizeof sSet, sizeof sSet[]);

					for (int iCount = 0; iCount < (float(iHealth) / float(iTotalHealth)) * (sizeof sHealthBar - 1) && iCount < (sizeof sHealthBar - 1); iCount++)
					{
						StrCat(sHealthBar, sizeof sHealthBar, sSet[0]);
					}

					for (int iCount = 0; iCount < (sizeof sHealthBar - 1); iCount++)
					{
						StrCat(sHealthBar, sizeof sHealthBar, sSet[1]);
					}

					bool bHuman = bIsValidClient(iTarget, MT_CHECK_FAKECLIENT);
					char sHumanTag[128], sTankName[33];
					FormatEx(sHumanTag, sizeof sHumanTag, "%T", "HumanTag", iPlayer);
					vGetTranslatedName(sTankName, sizeof sTankName, iTarget);

					switch (g_esCache[iTarget].g_iDisplayHealthType)
					{
						case 1:
						{
							switch (g_esCache[iTarget].g_iDisplayHealth)
							{
								case 1: PrintHintText(iPlayer, "%t %s", sTankName, (bHuman ? sHumanTag : ""));
								case 2: PrintHintText(iPlayer, "%i HP", iHealth);
								case 3: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, iTotalHealth, flPercentage, "%%");
								case 4: PrintHintText(iPlayer, "HP: |-<%s>-|", sHealthBar);
								case 5: PrintHintText(iPlayer, "%t %s (%i HP)", sTankName, (bHuman ? sHumanTag : ""), iHealth);
								case 6: PrintHintText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%");
								case 7: PrintHintText(iPlayer, "%t %s\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), sHealthBar);
								case 8: PrintHintText(iPlayer, "%i HP\nHP: |-<%s>-|", iHealth, sHealthBar);
								case 9: PrintHintText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
								case 10: PrintHintText(iPlayer, "%t %s (%i HP)\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, sHealthBar);
								case 11: PrintHintText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
							}
						}
						case 2:
						{
							switch (g_esCache[iTarget].g_iDisplayHealth)
							{
								case 1: PrintCenterText(iPlayer, "%t %s", sTankName, (bHuman ? sHumanTag : ""));
								case 2: PrintCenterText(iPlayer, "%i HP", iHealth);
								case 3: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)", iHealth, iTotalHealth, flPercentage, "%%");
								case 4: PrintCenterText(iPlayer, "HP: |-<%s>-|", sHealthBar);
								case 5: PrintCenterText(iPlayer, "%t %s (%i HP)", sTankName, (bHuman ? sHumanTag : ""), iHealth);
								case 6: PrintCenterText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%");
								case 7: PrintCenterText(iPlayer, "%t %s\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), sHealthBar);
								case 8: PrintCenterText(iPlayer, "%i HP\nHP: |-<%s>-|", iHealth, sHealthBar);
								case 9: PrintCenterText(iPlayer, "%i/%i HP (%.0f%s)\nHP: |-<%s>-|", iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
								case 10: PrintCenterText(iPlayer, "%t %s (%i HP)\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, sHealthBar);
								case 11: PrintCenterText(iPlayer, "%t %s [%i/%i HP (%.0f%s)]\nHP: |-<%s>-|", sTankName, (bHuman ? sHumanTag : ""), iHealth, iTotalHealth, flPercentage, "%%", sHealthBar);
							}
						}
					}
				}
			}
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_esGeneral.g_bPluginEnabled || !bIsValidClient(client))
	{
		return Plugin_Continue;
	}

	if (bIsSurvivor(client, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		if (bIsValidClient(client, MT_CHECK_ALIVE))
		{
			if ((bIsDeveloper(client, 5) || (g_esPlayer[client].g_iRewardTypes & MT_REWARD_SPEEDBOOST)) && (buttons & IN_JUMP))
			{
				if (bIsEntityGrounded(client) && !bIsSurvivorDisabled(client) && !bIsSurvivorCaught(client))
				{
					float flAngles[3], flForward[3], flVelocity[3];
					GetClientEyeAngles(client, flAngles);
					flAngles[0] = 0.0;

					GetAngleVectors(flAngles, flForward, NULL_VECTOR, NULL_VECTOR);
					NormalizeVector(flForward, flForward);
					ScaleVector(flForward, MT_JUMP_FORWARDBOOST);

					GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", flVelocity);
					flVelocity[0] += flForward[0];
					flVelocity[1] += flForward[1];
					flVelocity[2] += flForward[2];
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flVelocity);
				}

				if (bIsSurvivorDisabled(client))
				{
					vReviveSurvivor(client);
				}
			}

			if ((bIsDeveloper(client, 6) || ((g_esPlayer[client].g_iRewardTypes & MT_REWARD_ATTACKBOOST) && g_esPlayer[client].g_iShovePenalty == 1)) && (buttons & IN_ATTACK2))
			{
				SetEntProp(client, Prop_Send, "m_iShovePenalty", 0, 1);
			}

			if (bIsDeveloper(client, 7) || (g_esPlayer[client].g_iRewardTypes & MT_REWARD_INFAMMO))
			{
				vRefillAmmo(client, true);
			}

			if (!bIsEntityGrounded(client))
			{
				float flVelocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVelocity);
				if (flVelocity[2] < 0.0)
				{
					if (!g_esPlayer[client].g_bFallTracked)
					{
						float flOrigin[3];
						GetEntPropVector(client, Prop_Data, "m_vecOrigin", flOrigin);
						g_esPlayer[client].g_flPreFallZ = flOrigin[2];
						g_esPlayer[client].g_bFallTracked = true;

						return Plugin_Continue;
					}
				}
				else if (g_esPlayer[client].g_bFalling || g_esPlayer[client].g_bFallTracked)
				{
					g_esPlayer[client].g_bFalling = false;
					g_esPlayer[client].g_bFallTracked = false;
					g_esPlayer[client].g_flPreFallZ = 0.0;
				}
			}
			else if (g_esPlayer[client].g_bFalling || g_esPlayer[client].g_bFallTracked)
			{
				g_esPlayer[client].g_bFalling = false;
				g_esPlayer[client].g_bFallTracked = false;
				g_esPlayer[client].g_flPreFallZ = 0.0;
			}
		}
		else if (bIsDeveloper(client, 10) && (buttons & IN_JUMP))
		{
			RequestFrame(vRespawnFrame, GetClientUserId(client));
		}
	}
	else if (bIsTank(client))
	{
		if (bIsTankSupported(client, MT_CHECK_FAKECLIENT))
		{
			int iButton = 0;
			for (int iBit = 0; iBit < 26; iBit++)
			{
				iButton = (1 << iBit);
				if (buttons & iButton)
				{
					if (!(g_esPlayer[client].g_iLastButtons & iButton))
					{
						Call_StartForward(g_esGeneral.g_gfButtonPressedForward);
						Call_PushCell(client);
						Call_PushCell(iButton);
						Call_Finish();
					}
				}
				else if (g_esPlayer[client].g_iLastButtons & iButton)
				{
					Call_StartForward(g_esGeneral.g_gfButtonReleasedForward);
					Call_PushCell(client);
					Call_PushCell(iButton);
					Call_Finish();
				}
			}

			g_esPlayer[client].g_iLastButtons = buttons;
		}

		if (buttons & IN_ATTACK)
		{
			if (!g_esPlayer[client].g_bAttackedAgain)
			{
				g_esPlayer[client].g_bAttackedAgain = true;
			}

			if (GetRandomFloat(0.1, 100.0) <= g_esCache[client].g_flPunchThrow)
			{
				buttons |= IN_ATTACK2;

				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}

void vClearAbilityList()
{
	for (int iPos = 0; iPos < sizeof esGeneral::g_alAbilitySections; iPos++)
	{
		if (g_esGeneral.g_alAbilitySections[iPos] != null)
		{
			g_esGeneral.g_alAbilitySections[iPos].Clear();

			delete g_esGeneral.g_alAbilitySections[iPos];
		}
	}
}

void vClearColorKeysList()
{
	for (int iPos = 0; iPos < sizeof esGeneral::g_alColorKeys; iPos++)
	{
		if (g_esGeneral.g_alColorKeys[iPos] != null)
		{
			g_esGeneral.g_alColorKeys[iPos].Clear();

			delete g_esGeneral.g_alColorKeys[iPos];
		}
	}
}

void vClearCompTypesList()
{
	if (g_esGeneral.g_alCompTypes != null)
	{
		g_esGeneral.g_alCompTypes.Clear();

		delete g_esGeneral.g_alCompTypes;
	}
}

void vClearPluginList()
{
	if (g_esGeneral.g_alPlugins != null)
	{
		g_esGeneral.g_alPlugins.Clear();

		delete g_esGeneral.g_alPlugins;
	}
}

void vClearSectionList()
{
	if (g_esGeneral.g_alSections != null)
	{
		g_esGeneral.g_alSections.Clear();

		delete g_esGeneral.g_alSections;
	}
}

void vLogCommand(int admin, int type, const char[] activity, any ...)
{
	if (g_esGeneral.g_iLogCommands & type)
	{
		char sMessage[PLATFORM_MAX_PATH];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && CheckCommandAccess(iPlayer, "sm_admin", ADMFLAG_ROOT, true) && iPlayer != admin)
			{
				SetGlobalTransTarget(iPlayer);
				VFormat(sMessage, sizeof sMessage, activity, 4);
				MT_PrintToChat(iPlayer, sMessage);
			}
		}
	}
}

void vLogMessage(int type, bool timestamp = true, const char[] message, any ...)
{
	if (type == -1 || (g_esGeneral.g_iLogMessages & type))
	{
		Action aResult = Plugin_Continue;

		Call_StartForward(g_esGeneral.g_gfLogMessageForward);
		Call_PushCell(type);
		Call_PushString(message);
		Call_Finish(aResult);

		switch (aResult)
		{
			case Plugin_Handled: return;
			case Plugin_Continue:
			{
				char sBuffer[PLATFORM_MAX_PATH], sMessage[PLATFORM_MAX_PATH];
				SetGlobalTransTarget(LANG_SERVER);
				strcopy(sMessage, sizeof sMessage, message);
				VFormat(sBuffer, sizeof sBuffer, sMessage, 4);
				MT_ReplaceChatPlaceholders(sBuffer, sizeof sBuffer, true);

				switch (timestamp)
				{
					case true:
					{
						char sTime[32];
						FormatTime(sTime, sizeof sTime, "%Y-%m-%d - %H:%M:%S", GetTime());
						FormatEx(sMessage, sizeof sMessage, "[%s] %s", sTime, sBuffer);
						vSaveMessage(sMessage);
					}
					case false: vSaveMessage(sBuffer);
				}

				PrintToServer(sBuffer);
			}
		}
	}
}

void vPluginStatus()
{
	bool bPluginAllowed = bIsPluginEnabled();
	if (!g_esGeneral.g_bPluginEnabled && bPluginAllowed)
	{
		vTogglePlugin(bPluginAllowed);

		if (bIsVersusModeRound(0))
		{
			g_esGeneral.g_alCompTypes = new ArrayList();
		}
	}
	else if (g_esGeneral.g_bPluginEnabled && !bPluginAllowed)
	{
		vTogglePlugin(bPluginAllowed);
	}
}

void vRegularSpawn()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vCheatCommand(iPlayer, (g_bSecondGame ? "z_spawn_old" : "z_spawn"), "tank auto");

			break;
		}
	}
}

void vRemoveDamage(int victim, int damagetype)
{
	if (damagetype & DMG_BURN)
	{
		ExtinguishEntity(victim);
	}

	vSetWounds(victim);
}

void vRemoveGlow(int player)
{
	if (!g_bSecondGame || !bIsValidClient(player))
	{
		return;
	}

	SetEntProp(player, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(player, Prop_Send, "m_bFlashing", 0);
	SetEntProp(player, Prop_Send, "m_iGlowType", 0);
}

void vResetCore(int client)
{
	g_esPlayer[client].g_bAdminMenu = false;
	g_esPlayer[client].g_bAttacked = false;
	g_esPlayer[client].g_bDied = false;
	g_esPlayer[client].g_bIgnoreCmd = false;
	g_esPlayer[client].g_bLastLife = false;
	g_esPlayer[client].g_bStasis = false;
	g_esPlayer[client].g_bThirdPerson = false;
#if defined _ThirdPersonShoulder_Detect_included
	g_esPlayer[client].g_bThirdPerson2 = false;
#endif
	g_esPlayer[client].g_iLastButtons = 0;
	g_esPlayer[client].g_iMaxClip[0] = 0;
	g_esPlayer[client].g_iMaxClip[1] = 0;
	g_esPlayer[client].g_iReviveCount = 0;

	vResetDamage(client);
}

void vResetDamage(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		g_esPlayer[iSurvivor].g_iTankDamage[tank] = 0;
	}
}

void vResetPlayer(int player)
{
	vResetTank(player);
	vResetTank2(player);
	vResetCore(player);
	vRemoveSurvivorEffects(player);
	vCacheSettings(player);
}

void vResetPlugin()
{
	g_esGeneral.g_iPlayerCount[1] = iGetHumanCount();
	g_esGeneral.g_iPlayerCount[2] = iGetHumanCount(true);

	vResetRound();
	vClearAbilityList();
	vClearColorKeysList();
	vClearCompTypesList();
	vClearPluginList();
}

void vResetRound()
{
	g_esGeneral.g_bFinaleEnded = false;
	g_esGeneral.g_bForceSpawned = false;
	g_esGeneral.g_bUsedParser = false;
	g_esGeneral.g_iChosenType = 0;
	g_esGeneral.g_iParserViewer = 0;
	g_esGeneral.g_iRegularCount = 0;
	g_esGeneral.g_iSurvivalBlock = 0;
	g_esGeneral.g_iTankCount = 0;
	g_esGeneral.g_iTankWave = 0;

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vResetPlayer(iPlayer);
		}
	}

	delete g_esGeneral.g_hRegularWavesTimer;
	delete g_esGeneral.g_hSurvivalTimer;
	delete g_esGeneral.g_hTankWaveTimer;
}

void vSaveMessage(const char[] message)
{
	File fLog = OpenFile(g_esGeneral.g_sLogFile, "a");
	if (fLog != null)
	{
		fLog.WriteLine(message);

		delete fLog;
	}
}

void vToggleLogging(int type = -1)
{
	char sMessage[PLATFORM_MAX_PATH], sMap[128], sTime[32], sDate[32];
	GetCurrentMap(sMap, sizeof sMap);
	FormatTime(sTime, sizeof sTime, "%m/%d/%Y %H:%M:%S", GetTime());
	FormatTime(sDate, sizeof sDate, "%Y-%m-%d", GetTime());
	BuildPath(Path_SM, g_esGeneral.g_sLogFile, sizeof esGeneral::g_sLogFile, "logs/mutant_tanks_%s.log", sDate);

	bool bLog = false;
	int iType;

	switch (type)
	{
		case -1:
		{
			if (g_esGeneral.g_iLogMessages != iType)
			{
				bLog = true;
				iType = g_esGeneral.g_iLogMessages;

				FormatEx(sMessage, sizeof sMessage, "%T", ((iType != 0) ? "LogStarted" : "LogEnded"), LANG_SERVER, sTime, sMap);
			}
		}
		case 0, 1:
		{
			if (g_esGeneral.g_iLogMessages != 0)
			{
				bLog = true;
				iType = g_esGeneral.g_iLogMessages;

				FormatEx(sMessage, sizeof sMessage, "%T", ((type == 1) ? "LogStarted" : "LogEnded"), LANG_SERVER, sTime, sMap);
			}
		}
	}

	if (bLog)
	{
		int iLength = strlen(sMessage), iSize = (iLength + 1);
		char[] sBorder = new char[iSize];
		StrCat(sBorder, iLength, "--");
		for (int iPos = 0; iPos < (iLength - 4); iPos++)
		{
			StrCat(sBorder, iSize, "=");
		}

		StrCat(sBorder, iSize, "--");
		vSaveMessage(sBorder);
		vSaveMessage(sMessage);
		vSaveMessage(sBorder);
	}
}

void vTogglePlugin(bool toggle)
{
	g_esGeneral.g_bPluginEnabled = toggle;

	vHookEvents(toggle);
	vToggleDetours(toggle);
}