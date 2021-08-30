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

#if !defined MT_CORE_MAIN
	#error This file must be inside "scripting/mutant_tanks/main" while compiling "mutant_tanks.sp" to work.
#endif

void vRegisterConVars()
{
	g_esGeneral.g_cvMTDisabledGameModes = CreateConVar("mt_disabledgamemodes", "", "Disable Mutant Tanks in these game modes.\nSeparate by commas.\nEmpty: None\nNot empty: Disabled only in these game modes.", FCVAR_NOTIFY);
	g_esGeneral.g_cvMTEnabledGameModes = CreateConVar("mt_enabledgamemodes", "", "Enable Mutant Tanks in these game modes.\nSeparate by commas.\nEmpty: All\nNot empty: Enabled only in these game modes.", FCVAR_NOTIFY);
	g_esGeneral.g_cvMTGameModeTypes = CreateConVar("mt_gamemodetypes", "0", "Enable Mutant Tanks in these game mode types.\n0 OR 15: All game mode types.\n1: Co-Op modes only.\n2: Versus modes only.\n4: Survival modes only.\n8: Scavenge modes only. (Only available in Left 4 Dead 2.)", FCVAR_NOTIFY, true, 0.0, true, 15.0);
	g_esGeneral.g_cvMTListenSupport = CreateConVar("mt_listensupport", (g_bDedicated ? "0" : "1"), "Enable Mutant Tanks on listen servers.\n0: OFF\n1: ON", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_esGeneral.g_cvMTPluginEnabled = CreateConVar("mt_pluginenabled", "1", "Enable Mutant Tanks.\n0: OFF\n1: ON", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar("mt_pluginversion", MT_VERSION, "Mutant Tanks Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_SPONLY);
	AutoExecConfig(true, "mutant_tanks");

	g_esGeneral.g_cvMTAssaultRifleAmmo = FindConVar("ammo_assaultrifle_max");
	g_esGeneral.g_cvMTAutoShotgunAmmo = g_bSecondGame ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_esGeneral.g_cvMTDifficulty = FindConVar("z_difficulty");
	g_esGeneral.g_cvMTFirstAidHealPercent = FindConVar("first_aid_heal_percent");
	g_esGeneral.g_cvMTFirstAidKitUseDuration = FindConVar("first_aid_kit_use_duration");
	g_esGeneral.g_cvMTGrenadeLauncherAmmo = FindConVar("ammo_grenadelauncher_max");
	g_esGeneral.g_cvMTHuntingRifleAmmo = FindConVar("ammo_huntingrifle_max");
	g_esGeneral.g_cvMTGameMode = FindConVar("mp_gamemode");
	g_esGeneral.g_cvMTGameTypes = FindConVar("sv_gametypes");
	g_esGeneral.g_cvMTPainPillsDecayRate = FindConVar("pain_pills_decay_rate");
	g_esGeneral.g_cvMTShotgunAmmo = g_bSecondGame ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_esGeneral.g_cvMTSMGAmmo = FindConVar("ammo_smg_max");
	g_esGeneral.g_cvMTSniperRifleAmmo = FindConVar("ammo_sniperrifle_max");
	g_esGeneral.g_cvMTSurvivorReviveDuration = FindConVar("survivor_revive_duration");
	g_esGeneral.g_cvMTSurvivorReviveHealth = FindConVar("survivor_revive_health");
	g_esGeneral.g_cvMTGunSwingInterval = FindConVar("z_gun_swing_interval");
	g_esGeneral.g_cvMTTankIncapHealth = FindConVar("z_tank_incapacitated_health");

	if (g_bSecondGame)
	{
		g_esGeneral.g_cvMTAmmoPackUseDuration = FindConVar("ammo_pack_use_duration");
		g_esGeneral.g_cvMTColaBottlesUseDuration = FindConVar("cola_bottles_use_duration");
		g_esGeneral.g_cvMTDefibrillatorUseDuration = FindConVar("defibrillator_use_duration");
		g_esGeneral.g_cvMTGasCanUseDuration = FindConVar("gas_can_use_duration");
		g_esGeneral.g_cvMTMeleeRange = FindConVar("melee_range");
		g_esGeneral.g_cvMTPhysicsPushScale = FindConVar("phys_pushscale");
		g_esGeneral.g_cvMTUpgradePackUseDuration = FindConVar("upgrade_pack_use_duration");
	}

	g_esGeneral.g_cvMTDisabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTEnabledGameModes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTGameModeTypes.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTPluginEnabled.AddChangeHook(vMTPluginStatusCvar);
	g_esGeneral.g_cvMTDifficulty.AddChangeHook(vMTGameDifficultyCvar);
}

void vSetDurationCvars(int item, bool reset, float duration = 1.0)
{
	if (g_esGeneral.g_hSDKGetUseAction != null)
	{
		int iType = SDKCall(g_esGeneral.g_hSDKGetUseAction, item);
		if (reset)
		{
			switch (iType)
			{
				case 1:
				{
					if (g_esGeneral.g_flDefaultFirstAidKitUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = g_esGeneral.g_flDefaultFirstAidKitUseDuration; // first_aid_kit
						g_esGeneral.g_flDefaultFirstAidKitUseDuration = -1.0;
					}
				}
				case 2:
				{
					if (g_esGeneral.g_flDefaultAmmoPackUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTAmmoPackUseDuration.FloatValue = g_esGeneral.g_flDefaultAmmoPackUseDuration; // ammo_pack
						g_esGeneral.g_flDefaultAmmoPackUseDuration = -1.0;
					}
				}
				case 4:
				{
					if (g_esGeneral.g_flDefaultDefibrillatorUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTDefibrillatorUseDuration.FloatValue = g_esGeneral.g_flDefaultDefibrillatorUseDuration; // defibrillator
						g_esGeneral.g_flDefaultDefibrillatorUseDuration = -1.0;
					}
				}
				case 6, 7:
				{
					if (g_esGeneral.g_flDefaultUpgradePackUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTUpgradePackUseDuration.FloatValue = g_esGeneral.g_flDefaultUpgradePackUseDuration; // upgrade_pack
						g_esGeneral.g_flDefaultUpgradePackUseDuration = -1.0;
					}
				}
				case 8:
				{
					if (g_esGeneral.g_flDefaultGasCanUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTGasCanUseDuration.FloatValue = g_esGeneral.g_flDefaultGasCanUseDuration; // gas_can
						g_esGeneral.g_flDefaultGasCanUseDuration = -1.0;
					}
				}
				case 9:
				{
					if (g_esGeneral.g_flDefaultColaBottlesUseDuration != -1.0)
					{
						g_esGeneral.g_cvMTColaBottlesUseDuration.FloatValue = g_esGeneral.g_flDefaultColaBottlesUseDuration; // cola_bottles
						g_esGeneral.g_flDefaultColaBottlesUseDuration = -1.0;
					}
				}
			}
		}
		else
		{
			switch (iType)
			{
				case 1:
				{
					if (g_esGeneral.g_cvMTFirstAidKitUseDuration != null)
					{
						g_esGeneral.g_flDefaultFirstAidKitUseDuration = g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue;
						g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = duration; // first_aid_kit
					}
				}
				case 2:
				{
					if (g_esGeneral.g_cvMTAmmoPackUseDuration != null)
					{
						g_esGeneral.g_flDefaultAmmoPackUseDuration = g_esGeneral.g_cvMTAmmoPackUseDuration.FloatValue;
						g_esGeneral.g_cvMTAmmoPackUseDuration.FloatValue = duration; // ammo_pack
					}
				}
				case 4:
				{
					if (g_esGeneral.g_cvMTDefibrillatorUseDuration != null)
					{
						g_esGeneral.g_flDefaultDefibrillatorUseDuration = g_esGeneral.g_cvMTDefibrillatorUseDuration.FloatValue;
						g_esGeneral.g_cvMTDefibrillatorUseDuration.FloatValue = duration; // defibrillator
					}
				}
				case 6, 7:
				{
					if (g_esGeneral.g_cvMTUpgradePackUseDuration != null)
					{
						g_esGeneral.g_flDefaultUpgradePackUseDuration = g_esGeneral.g_cvMTUpgradePackUseDuration.FloatValue;
						g_esGeneral.g_cvMTUpgradePackUseDuration.FloatValue = duration; // upgrade_pack
					}
				}
				case 8:
				{
					if (g_esGeneral.g_cvMTGasCanUseDuration != null)
					{
						g_esGeneral.g_flDefaultGasCanUseDuration = g_esGeneral.g_cvMTGasCanUseDuration.FloatValue;
						g_esGeneral.g_cvMTGasCanUseDuration.FloatValue = duration; // gas_can
					}
				}
				case 9:
				{
					if (g_esGeneral.g_cvMTColaBottlesUseDuration != null)
					{
						g_esGeneral.g_flDefaultColaBottlesUseDuration = g_esGeneral.g_cvMTColaBottlesUseDuration.FloatValue;
						g_esGeneral.g_cvMTColaBottlesUseDuration.FloatValue = duration; // cola_bottles
					}
				}
			}
		}
	}
}

void vSetHealPercentCvar(bool reset, int survivor = 0)
{
	if (reset)
	{
		if (g_esGeneral.g_flDefaultFirstAidHealPercent != -1.0)
		{
			g_esGeneral.g_cvMTFirstAidHealPercent.FloatValue = g_esGeneral.g_flDefaultFirstAidHealPercent;
			g_esGeneral.g_flDefaultFirstAidHealPercent = -1.0;
		}
	}
	else
	{
		bool bDeveloper = bIsDeveloper(survivor, 6);
		if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
		{
			float flPercent = (bDeveloper && g_esDeveloper[survivor].g_flDevHealPercent > g_esPlayer[survivor].g_flHealPercent) ? g_esDeveloper[survivor].g_flDevHealPercent : g_esPlayer[survivor].g_flHealPercent;
			if (flPercent > 0.0)
			{
				g_esGeneral.g_flDefaultFirstAidHealPercent = g_esGeneral.g_cvMTFirstAidHealPercent.FloatValue;
				g_esGeneral.g_cvMTFirstAidHealPercent.FloatValue = flPercent / 100.0;
			}
		}
	}
}

void vSetReviveDurationCvar(int survivor)
{
	bool bDeveloper = bIsDeveloper(survivor, 6);
	if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
	{
		float flDuration = (bDeveloper && g_esDeveloper[survivor].g_flDevActionDuration > g_esPlayer[survivor].g_flActionDuration) ? g_esDeveloper[survivor].g_flDevActionDuration : g_esPlayer[survivor].g_flActionDuration;
		if (flDuration > 0.0)
		{
			g_esGeneral.g_flDefaultSurvivorReviveDuration = g_esGeneral.g_cvMTSurvivorReviveDuration.FloatValue;
			g_esGeneral.g_cvMTSurvivorReviveDuration.FloatValue = flDuration;
		}
	}
}

void vSetReviveHealthCvar(bool reset, int survivor = 0)
{
	if (reset)
	{
		if (g_esGeneral.g_iDefaultSurvivorReviveHealth != -1)
		{
			g_esGeneral.g_cvMTSurvivorReviveHealth.IntValue = g_esGeneral.g_iDefaultSurvivorReviveHealth;
			g_esGeneral.g_iDefaultSurvivorReviveHealth = -1;
		}
	}
	else
	{
		bool bDeveloper = bIsDeveloper(survivor, 6);
		if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
		{
			int iHealth = (bDeveloper && g_esDeveloper[survivor].g_iDevReviveHealth > g_esPlayer[survivor].g_iReviveHealth) ? g_esDeveloper[survivor].g_iDevReviveHealth : g_esPlayer[survivor].g_iReviveHealth;
			if (iHealth > 0)
			{
				g_esGeneral.g_iDefaultSurvivorReviveHealth = g_esGeneral.g_cvMTSurvivorReviveHealth.IntValue;
				g_esGeneral.g_cvMTSurvivorReviveHealth.IntValue = iHealth;
			}
		}
	}
}

public void vMTPluginStatusCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	vPluginStatus();
}

public void vMTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sDifficultyConfig[PLATFORM_MAX_PATH];
		if (bIsDifficultyConfigFound(sDifficultyConfig, sizeof sDifficultyConfig))
		{
			vCustomConfig(sDifficultyConfig);
			g_esGeneral.g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
			g_esGeneral.g_iFileTimeNew[1] = g_esGeneral.g_iFileTimeOld[1];
		}
	}
}

public void vViewDistanceQuery(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	switch (bIsValidClient(client) && result == ConVarQuery_Okay)
	{
		case true: g_esPlayer[client].g_bThirdPerson = (StringToInt(cvarValue) <= -1);
		case false: g_esPlayer[client].g_bThirdPerson = false;
	}
}