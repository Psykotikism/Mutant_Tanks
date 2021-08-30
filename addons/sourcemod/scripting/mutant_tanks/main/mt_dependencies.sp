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

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "clientprefs"))
	{
		g_esGeneral.g_bClientPrefsInstalled = true;
	}
	else if (StrEqual(name, "left4dhooks"))
	{
		g_esGeneral.g_bLeft4DHooksInstalled = true;

		vToggleLeft4DHooks(false);
	}
	else if (StrEqual(name, "mt_clone"))
	{
		g_esGeneral.g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "clientprefs"))
	{
		g_esGeneral.g_bClientPrefsInstalled = false;
	}
	else if (StrEqual(name, "left4dhooks"))
	{
		g_esGeneral.g_bLeft4DHooksInstalled = false;

		vToggleLeft4DHooks(true);
	}
	else if (StrEqual(name, "mt_clone"))
	{
		g_esGeneral.g_bCloneInstalled = false;
	}
}

public void OnAllPluginsLoaded()
{
	g_esGeneral.g_bClientPrefsInstalled = LibraryExists("clientprefs");
	g_esGeneral.g_bCloneInstalled = LibraryExists("mt_clone");
	g_esGeneral.g_bLeft4DHooksInstalled = LibraryExists("left4dhooks");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks != null)
	{
		vRegisterDetours();
		vSetupDetours(gdMutantTanks);
		vRegisterPatches(gdMutantTanks);
		vInstallPermanentPatches();

		delete gdMutantTanks;
	}
}

#if defined _clientprefs_included
public void OnClientCookiesCached(int client)
{
	char sColor[16];
	for (int iPos = 0; iPos < sizeof esGeneral::g_ckMTAdmin; iPos++)
	{
		g_esGeneral.g_ckMTAdmin[iPos].Get(client, sColor, sizeof sColor);
		if (sColor[0] != '\0')
		{
			switch (iPos)
			{
				case 0: g_esDeveloper[client].g_iDevAccess = (g_esDeveloper[client].g_iDevAccess < 2) ? StringToInt(sColor) : g_esDeveloper[client].g_iDevAccess;
				case 1: g_esDeveloper[client].g_iDevParticle = StringToInt(sColor);
				case 2: strcopy(g_esDeveloper[client].g_sDevGlowOutline, sizeof esDeveloper::g_sDevGlowOutline, sColor);
				case 3: strcopy(g_esDeveloper[client].g_sDevFlashlight, sizeof esDeveloper::g_sDevFlashlight, sColor);
				case 4: strcopy(g_esDeveloper[client].g_sDevSkinColor, sizeof esDeveloper::g_sDevSkinColor, sColor);
			}
		}
	}

	char sValue[3];
	g_esGeneral.g_ckMTPrefs.Get(client, sValue, sizeof sValue);
	if (sValue[0] != '\0')
	{
		g_esPlayer[client].g_iRewardVisuals = StringToInt(sValue);
		g_esPlayer[client].g_bApplyVisuals[0] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_SCREEN);
		g_esPlayer[client].g_bApplyVisuals[1] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_PARTICLE);
		g_esPlayer[client].g_bApplyVisuals[2] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_VOICELINE);
		g_esPlayer[client].g_bApplyVisuals[3] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_LIGHT);
		g_esPlayer[client].g_bApplyVisuals[4] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_BODY);
		g_esPlayer[client].g_bApplyVisuals[5] = !!(g_esPlayer[client].g_iRewardVisuals & MT_VISUAL_GLOW);
	}
}
#endif

#if defined _adminmenu_included
public void OnAdminMenuReady(Handle topmenu)
{
	TopMenu tmMTMenu = TopMenu.FromHandle(topmenu);
	if (topmenu == g_esGeneral.g_tmMTMenu)
	{
		return;
	}

	g_esGeneral.g_tmMTMenu = tmMTMenu;
	TopMenuObject tmoCommands = g_esGeneral.g_tmMTMenu.AddCategory(MT_CONFIG_SECTION_MAIN2, vMTAdminMenuHandler, "mt_adminmenu", ADMFLAG_GENERIC);
	if (tmoCommands != INVALID_TOPMENUOBJECT)
	{
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_tank", vMutantTanksMenu, tmoCommands, "sm_mt_tank", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_config", vMTConfigMenu, tmoCommands, "sm_mt_config", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_info", vMTInfoMenu, tmoCommands, "sm_mt_info", ADMFLAG_GENERIC);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_list", vMTListMenu, tmoCommands, "sm_mt_list", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_reload", vMTReloadMenu, tmoCommands, "sm_mt_reload", ADMFLAG_ROOT);
		g_esGeneral.g_tmMTMenu.AddItem("sm_mt_version", vMTVersionMenu, tmoCommands, "sm_mt_version", ADMFLAG_ROOT);
	}
}

public void vMTAdminMenuHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayTitle, TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", MT_CONFIG_SECTION_MAIN2, param);
	}
}

public void vMutantTanksMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTListMenu", param);
		case TopMenuAction_SelectOption:
		{
			vTankMenu(param, true);
			vLogCommand(param, MT_CMD_SPAWN, "%s %N:{default} Opened the{mint} %s{default} menu.", MT_TAG4, param, MT_CONFIG_SECTION_MAIN);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the %s menu.", MT_TAG, param, MT_CONFIG_SECTION_MAIN);
		}
	}
}

public void vMTConfigMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTPathMenu", param);
		case TopMenuAction_SelectOption:
		{
			vPathMenu(param, true);
			vLogCommand(param, MT_CMD_CONFIG, "%s %N:{default} Opened the config file viewer.", MT_TAG4, param);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Opened the config file viewer.", MT_TAG, param);
		}
	}
}

public void vMTInfoMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTInfoMenu", param);
		case TopMenuAction_SelectOption: vInfoMenu(param, true);
	}
}

public void vMTListMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTAbilitiesMenu", param);
		case TopMenuAction_SelectOption:
		{
			vListAbilities(param);
			vLogCommand(param, MT_CMD_LIST, "%s %N:{default} Checked the list of abilities installed.", MT_TAG4, param);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the list of abilities installed.", MT_TAG, param);

			if (bIsValidClient(param, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && g_esGeneral.g_tmMTMenu != null)
			{
				g_esGeneral.g_tmMTMenu.Display(param, TopMenuPosition_LastCategory);
			}
		}
	}
}

public void vMTReloadMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTReloadMenu", param);
		case TopMenuAction_SelectOption:
		{
			vReloadConfig(param);
			vLogCommand(param, MT_CMD_RELOAD, "%s %N:{default} Reloaded all config files.", MT_TAG4, param);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Reloaded all config files.", MT_TAG, param);

			if (bIsValidClient(param, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && g_esGeneral.g_tmMTMenu != null)
			{
				g_esGeneral.g_tmMTMenu.Display(param, TopMenuPosition_LastCategory);
			}
		}
	}
}

public void vMTVersionMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: FormatEx(buffer, maxlength, "%T", "MTVersionMenu", param);
		case TopMenuAction_SelectOption:
		{
			MT_PrintToChat(param, "%s %s{yellow} v%s{mint}, by{olive} %s", MT_TAG3, MT_CONFIG_SECTION_MAIN, MT_VERSION, MT_AUTHOR);
			vLogCommand(param, MT_CMD_VERSION, "%s %N:{default} Checked the current version of{mint} %s{default}.", MT_TAG4, param, MT_CONFIG_SECTION_MAIN);
			vLogMessage(MT_LOG_SERVER, _, "%s %N: Checked the current version of %s.", MT_TAG, param, MT_CONFIG_SECTION_MAIN);

			if (bIsValidClient(param, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT|MT_CHECK_INKICKQUEUE) && g_esGeneral.g_tmMTMenu != null)
			{
				g_esGeneral.g_tmMTMenu.Display(param, TopMenuPosition_LastCategory);
			}
		}
	}
}
#endif

#if defined _l4dh_included
public void L4D_OnEnterGhostState(int client)
{
	if (bIsTank(client))
	{
		g_esPlayer[client].g_bKeepCurrentType = true;

		if (g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_flForceSpawn > 0.0)
		{
			CreateTimer(g_esGeneral.g_flForceSpawn, tTimerForceSpawnTank, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action L4D_OnFirstSurvivorLeftSafeArea(int client)
{
	vResetTimers(true);
}

public void L4D_OnReplaceTank(int tank, int newtank)
{
	g_esPlayer[newtank].g_bReplaceSelf = true;

	vSetTankColor(newtank, g_esPlayer[tank].g_iTankType);
	vCopyTankStats(tank, newtank);
	vTankSpawn(newtank, -1);
	vResetTank(tank, 0);
	vResetTank2(tank);
	vCacheSettings(tank);
}

public Action L4D_OnShovedBySurvivor(int client, int victim, const float vecDir[3])
{
	Action aResult = Plugin_Continue;
	Call_StartForward(g_esGeneral.g_gfPlayerShovedBySurvivorForward);
	Call_PushCell(victim);
	Call_PushCell(client);
	Call_PushArray(vecDir, 3);
	Call_Finish(aResult);

	return aResult;
}

public Action L4D_OnSpawnTank(const float vecPos[3], const float vecAng[3])
{
	if (g_esGeneral.g_iLimitExtras == 0 || g_esGeneral.g_bForceSpawned)
	{
		return Plugin_Continue;
	}

	bool bBlock = false;
	int iCount = iGetTankCount(true), iCount2 = iGetTankCount(false);

	switch (g_esGeneral.g_bFinalMap)
	{
		case true:
		{
			switch (g_esGeneral.g_iTankWave)
			{
				case 0: bBlock = false;
				default:
				{
					switch (g_esGeneral.g_iFinaleAmount)
					{
						case 0: bBlock = (0 < g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1] <= iCount) || (0 < g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1] <= iCount2);
						default: bBlock = (0 < g_esGeneral.g_iFinaleAmount <= iCount) || (0 < g_esGeneral.g_iFinaleAmount <= iCount2);
					}
				}
			}
		}
		case false: bBlock = (0 < g_esGeneral.g_iRegularAmount <= iCount) || (0 < g_esGeneral.g_iRegularAmount <= iCount2);
	}

	return bBlock ? Plugin_Handled : Plugin_Continue;
}

public Action L4D_OnVomitedUpon(int victim, int &attacker, bool &boomerExplosion)
{
	if (bIsSurvivor(victim) && (bIsDeveloper(victim, 8) || bIsDeveloper(victim, 10) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D2_OnHitByVomitJar(int victim, int &attacker)
{
	if (bIsTank(victim) && g_esCache[victim].g_iVomitImmunity == 1 && bIsSurvivor(attacker, MT_CHECK_INDEX|MT_CHECK_INGAME) && !(g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
	{
		return Plugin_Handled;
	}

	Action aResult = Plugin_Continue;
	Call_StartForward(g_esGeneral.g_gfPlayerHitByVomitJarForward);
	Call_PushCell(victim);
	Call_PushCell(attacker);
	Call_Finish(aResult);

	return aResult;
}

public Action L4D2_OnPounceOrLeapStumble(int victim, int attacker)
{
	if (bIsSurvivor(victim) && (bIsDeveloper(victim, 8) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D2_OnStagger(int target, int source)
{
	if (bIsSurvivor(target) && (bIsDeveloper(target, 8) || (g_esPlayer[target].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
#endif

#if defined _ThirdPersonShoulder_Detect_included
public void TP_OnThirdPersonChanged(int iClient, bool bIsThirdPerson)
{
	if (bIsSurvivor(iClient))
	{
		g_esPlayer[iClient].g_bThirdPerson2 = bIsThirdPerson;
	}
}
#endif

#if defined _WeaponHandling_included
float flGetAttackBoost(int survivor, float speedmodifier)
{
	bool bDeveloper = bIsDeveloper(survivor, 6);
	if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
	{
		float flBoost = (bDeveloper && g_esDeveloper[survivor].g_flDevAttackBoost > g_esPlayer[survivor].g_flAttackBoost) ? g_esDeveloper[survivor].g_flDevAttackBoost : g_esPlayer[survivor].g_flAttackBoost;
		if (flBoost > 0.0)
		{
			return flBoost;
		}
	}

	return speedmodifier;
}

public void WH_OnMeleeSwing(int client, int weapon, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnStartThrow(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnReadyingThrow(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnReloadModifier(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnGetRateOfFire(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}

public void WH_OnDeployModifier(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	speedmodifier *= flGetAttackBoost(client, speedmodifier);
}
#endif