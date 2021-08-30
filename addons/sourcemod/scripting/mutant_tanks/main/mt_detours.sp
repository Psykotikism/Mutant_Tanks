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

bool g_bDetourBypass[MT_DETOUR_LIMIT], g_bDetourInstalled[MT_DETOUR_LIMIT], g_bDetourLog[MT_DETOUR_LIMIT];

char g_sDetourName[MT_DETOUR_LIMIT][128];

int g_iDetourCount = 0, g_iDetourType[MT_DETOUR_LIMIT];

void vRegisterDetours()
{
	g_iDetourCount = 0;

	char sFilePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sFilePath, sizeof sFilePath, "%smutant_tanks_detours.cfg", MT_CONFIG_PATH);
	if (!MT_FileExists(MT_CONFIG_PATH, "mutant_tanks_detours.cfg", sFilePath, sFilePath, sizeof sFilePath))
	{
		LogError("%s Unable to load the \"%s\" config file.", MT_TAG, sFilePath);

		return;
	}

	KeyValues kvDetours = new KeyValues("MTDetours");
	if (!kvDetours.ImportFromFile(sFilePath))
	{
		LogError("%s Unable to read the \"%s\" config file.", MT_TAG, sFilePath);

		delete kvDetours;
		return;
	}

	if (g_bSecondGame)
	{
		if (!kvDetours.JumpToKey("left4dead2"))
		{
			delete kvDetours;
			return;
		}
	}
	else
	{
		if (!kvDetours.JumpToKey("left4dead"))
		{
			delete kvDetours;
			return;
		}
	}

	if (!kvDetours.GotoFirstSubKey())
	{
		LogError("%s The \"%s\" config file contains invalid data.", MT_TAG, sFilePath);

		delete kvDetours;
		return;
	}

	bool bPlatform = false;
	char sOS[8], sName[128], sLog[4], sCvar[320], sCvarSet[10][32], sType[14];
	do
	{
		kvDetours.GetSectionName(sName, sizeof sName);
		kvDetours.GetString("log", sLog, sizeof sLog);
		kvDetours.GetString("cvarcheck", sCvar, sizeof sCvar);

		switch (g_esGeneral.g_bLinux)
		{
			case true: sOS = "Linux";
			case false: sOS = "Windows";
		}

		if (kvDetours.JumpToKey(sOS))
		{
			bPlatform = true;

			kvDetours.GetString("type", sType, sizeof sType);
			kvDetours.GoBack();
		}

		if (sName[0] == '\0' || (!StrEqual(sLog, "yes") && !StrEqual(sLog, "no")) || (strncmp(sType, "full", 4) == -1 && strncmp(sType, "setup", 5) == -1 && strncmp(sType, "ignore", 6) == -1) || (bPlatform && sType[0] == '\0'))
		{
			LogError("%s The \"%s\" config file contains invalid data.", MT_TAG, sFilePath);

			continue;
		}

		if ((!bPlatform && sType[0] == '\0') || (bPlatform && StrEqual(sType, "ignore")))
		{
			if (sLog[0] == 'y')
			{
				vLogMessage(-1, _, "%s No detour for \"%s\" on %s was found.", MT_TAG, sName, sOS);
			}

			continue;
		}

		bPlatform = false;

		bool bBypass = (StrContains(sType, "_bypass") != -1);
		if (sCvar[0] != '\0' && !bBypass)
		{
			ExplodeString(sCvar, ",", sCvarSet, sizeof sCvarSet, sizeof sCvarSet[]);
			for (int iPos = 0; iPos < sizeof sCvarSet; iPos++)
			{
				if (sCvarSet[iPos][0] != '\0')
				{
					g_esGeneral.g_cvMTTempSetting = FindConVar(sCvarSet[iPos]);
					if (g_esGeneral.g_cvMTTempSetting != null)
					{
						if (sLog[0] == 'y')
						{
							vLogMessage(-1, _, "%s The \"%s\" convar was found; skipping \"%s\".", MT_TAG, sCvarSet[iPos], sName);
						}

						break;
					}
				}
			}

			if (g_esGeneral.g_cvMTTempSetting != null)
			{
				g_esGeneral.g_cvMTTempSetting = null;

				continue;
			}
		}

		bBypass = (bBypass && sCvar[0] != '\0');

		switch (sType[0])
		{
			case 'i': bRegisterDetour(sName, (sLog[0] == 'y'), 0, bBypass);
			case 's': bRegisterDetour(sName, (sLog[0] == 'y'), 1, bBypass);
			case 'f': bRegisterDetour(sName, (sLog[0] == 'y'), 2, bBypass);
		}
	}
	while (kvDetours.GotoNextKey());

	vLogMessage(-1, _, "%s Registered %i detours.", MT_TAG, g_iDetourCount);

	delete kvDetours;
}

void vSetupDetour(DynamicDetour &detourHandle, GameData dataHandle, const char[] name)
{
	int iIndex = iGetDetourIndex(name);
	if (iIndex == -1 || g_iDetourType[iIndex] == 0)
	{
		return;
	}

	detourHandle = DynamicDetour.FromConf(dataHandle, name);
	if (detourHandle == null)
	{
		LogError("%s Failed to detour: %s", MT_TAG, name);

		return;
	}

	if (g_bDetourLog[iIndex])
	{
		vLogMessage(-1, _, "%s Setup the \"%s\" detour.", MT_TAG, name);
	}
}

void vSetupDetours(GameData dataHandle)
{
	vSetupDetour(g_esGeneral.g_ddActionCompleteDetour, dataHandle, "MTDetour_CFirstAidKit::OnActionComplete");
	vSetupDetour(g_esGeneral.g_ddBaseEntityCreateDetour, dataHandle, "MTDetour_CBaseEntity::Create");
	vSetupDetour(g_esGeneral.g_ddBeginChangeLevelDetour, dataHandle, "MTDetour_CTerrorPlayer::OnBeginChangeLevel");
	vSetupDetour(g_esGeneral.g_ddCanDeployForDetour, dataHandle, "MTDetour_CTerrorWeapon::CanDeployFor");
	vSetupDetour(g_esGeneral.g_ddDeathFallCameraEnableDetour, dataHandle, "MTDetour_CDeathFallCamera::Enable");
	vSetupDetour(g_esGeneral.g_ddDoAnimationEventDetour, dataHandle, "MTDetour_CTerrorPlayer::DoAnimationEvent");
	vSetupDetour(g_esGeneral.g_ddDoJumpDetour, dataHandle, "MTDetour_CTerrorGameMovement::DoJump");
	vSetupDetour(g_esGeneral.g_ddEnterGhostStateDetour, dataHandle, "MTDetour_CTerrorPlayer::OnEnterGhostState");
	vSetupDetour(g_esGeneral.g_ddEnterStasisDetour, dataHandle, "MTDetour_Tank::EnterStasis");
	vSetupDetour(g_esGeneral.g_ddEventKilledDetour, dataHandle, "MTDetour_CTerrorPlayer::Event_Killed");
	vSetupDetour(g_esGeneral.g_ddFallingDetour, dataHandle, "MTDetour_CTerrorPlayer::OnFalling");
	vSetupDetour(g_esGeneral.g_ddFinishHealingDetour, dataHandle, "MTDetour_CFirstAidKit::FinishHealing");
	vSetupDetour(g_esGeneral.g_ddFireBulletDetour, dataHandle, "MTDetour_CTerrorGun::FireBullet");
	vSetupDetour(g_esGeneral.g_ddFirstSurvivorLeftSafeAreaDetour, dataHandle, "MTDetour_CDirector::OnFirstSurvivorLeftSafeArea");
	vSetupDetour(g_esGeneral.g_ddFlingDetour, dataHandle, "MTDetour_CTerrorPlayer::Fling");
	vSetupDetour(g_esGeneral.g_ddGetMaxClip1Detour, dataHandle, "MTDetour_CBaseCombatWeapon::GetMaxClip1");
	vSetupDetour(g_esGeneral.g_ddHitByVomitJarDetour, dataHandle, "MTDetour_CTerrorPlayer::OnHitByVomitJar");
	vSetupDetour(g_esGeneral.g_ddIncapacitatedAsTankDetour, dataHandle, "MTDetour_CTerrorPlayer::OnIncapacitatedAsTank");
	vSetupDetour(g_esGeneral.g_ddLadderDismountDetour, dataHandle, "MTDetour_CTerrorPlayer::OnLadderDismount");
	vSetupDetour(g_esGeneral.g_ddLadderMountDetour, dataHandle, "MTDetour_CTerrorPlayer::OnLadderMount");
	vSetupDetour(g_esGeneral.g_ddLauncherDirectionDetour, dataHandle, "MTDetour_CEnvRockLauncher::LaunchCurrentDir");
	vSetupDetour(g_esGeneral.g_ddLeaveStasisDetour, dataHandle, "MTDetour_Tank::LeaveStasis");
	vSetupDetour(g_esGeneral.g_ddMaxCarryDetour, dataHandle, "MTDetour_CAmmoDef::MaxCarry");
	vSetupDetour(g_esGeneral.g_ddPreThinkDetour, dataHandle, "MTDetour_CTerrorPlayer::PreThink");
	vSetupDetour(g_esGeneral.g_ddReplaceTankDetour, dataHandle, "MTDetour_ZombieManager::ReplaceTank");
	vSetupDetour(g_esGeneral.g_ddRevivedDetour, dataHandle, "MTDetour_CTerrorPlayer::OnRevived");
	vSetupDetour(g_esGeneral.g_ddSecondaryAttackDetour, dataHandle, "MTDetour_CTerrorWeapon::SecondaryAttack");
	vSetupDetour(g_esGeneral.g_ddSecondaryAttackDetour2, dataHandle, "MTDetour_CTerrorMeleeWeapon::SecondaryAttack");
	vSetupDetour(g_esGeneral.g_ddSelectWeightedSequenceDetour, dataHandle, "MTDetour_CTerrorPlayer::SelectWeightedSequence");
	vSetupDetour(g_esGeneral.g_ddSetMainActivityDetour, dataHandle, "MTDetour_CTerrorPlayer::SetMainActivity");
	vSetupDetour(g_esGeneral.g_ddShovedByPounceLandingDetour, dataHandle, "MTDetour_CTerrorPlayer::OnShovedByPounceLanding");
	vSetupDetour(g_esGeneral.g_ddShovedBySurvivorDetour, dataHandle, "MTDetour_CTerrorPlayer::OnShovedBySurvivor");
	vSetupDetour(g_esGeneral.g_ddSpawnTankDetour, dataHandle, "MTDetour_ZombieManager::SpawnTank");
	vSetupDetour(g_esGeneral.g_ddStaggerDetour, dataHandle, "MTDetour_CTerrorPlayer::OnStaggered");
	vSetupDetour(g_esGeneral.g_ddStartActionDetour, dataHandle, "MTDetour_CBaseBackpackItem::StartAction");
	vSetupDetour(g_esGeneral.g_ddStartHealingDetour, dataHandle, "MTDetour_CFirstAidKit::StartHealing");
	vSetupDetour(g_esGeneral.g_ddStartRevivingDetour, dataHandle, "MTDetour_CTerrorPlayer::StartReviving");
	vSetupDetour(g_esGeneral.g_ddTankClawDoSwingDetour, dataHandle, "MTDetour_CTankClaw::DoSwing");
	vSetupDetour(g_esGeneral.g_ddTankClawGroundPoundDetour, dataHandle, "MTDetour_CTankClaw::GroundPound");
	vSetupDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, dataHandle, "MTDetour_CTankClaw::OnPlayerHit");
	vSetupDetour(g_esGeneral.g_ddTankRockCreateDetour, dataHandle, "MTDetour_CTankRock::Create");
	vSetupDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, dataHandle, "MTDetour_CTerrorMeleeWeapon::TestMeleeSwingCollision");
	vSetupDetour(g_esGeneral.g_ddVomitedUponDetour, dataHandle, "MTDetour_CTerrorPlayer::OnVomitedUpon");
}

void vToggleDetour(DynamicDetour &detourHandle, const char[] name, HookMode mode, DHookCallback callback, bool toggle, int game = 0)
{
	int iIndex = iGetDetourIndex(name);
	if (detourHandle == null || (game == 1 && g_bSecondGame) || (game == 2 && !g_bSecondGame) || iIndex == -1 || (!toggle && !g_bDetourInstalled[iIndex]) || (g_iDetourType[iIndex] < 2 && !g_bDetourBypass[iIndex]))
	{
		return;
	}

	bool bToggle = toggle ? detourHandle.Enable(mode, callback) : detourHandle.Disable(mode, callback);
	if (!bToggle)
	{
		LogError("%s Failed to %s the %s-hook detour for the \"%s\" function.", MT_TAG, (toggle ? "enable" : "disable"), ((mode == Hook_Pre) ? "pre" : "post"), name);

		return;
	}

	g_bDetourInstalled[iIndex] = toggle;

	if (g_bDetourLog[iIndex])
	{
		vLogMessage(-1, _, "%s %sabled the \"%s\" detour.", MT_TAG, (toggle ? "En" : "Dis"), name);
	}
}

void vToggleDetours(bool toggle)
{
	vToggleDetour(g_esGeneral.g_ddBaseEntityCreateDetour, "MTDetour_CBaseEntity::Create", Hook_Post, mreBaseEntityCreatePost, toggle, 1);
	vToggleDetour(g_esGeneral.g_ddFinishHealingDetour, "MTDetour_CFirstAidKit::FinishHealing", Hook_Pre, mreFinishHealingPre, toggle, 1);
	vToggleDetour(g_esGeneral.g_ddFinishHealingDetour, "MTDetour_CFirstAidKit::FinishHealing", Hook_Post, mreFinishHealingPost, toggle, 1);
	vToggleDetour(g_esGeneral.g_ddSetMainActivityDetour, "MTDetour_CTerrorPlayer::SetMainActivity", Hook_Pre, mreSetMainActivityPre, toggle, 1);

	vToggleDetour(g_esGeneral.g_ddActionCompleteDetour, "MTDetour_CFirstAidKit::OnActionComplete", Hook_Pre, mreActionCompletePre, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddActionCompleteDetour, "MTDetour_CFirstAidKit::OnActionComplete", Hook_Post, mreActionCompletePost, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddDoAnimationEventDetour, "MTDetour_CTerrorPlayer::DoAnimationEvent", Hook_Pre, mreDoAnimationEventPre, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddFireBulletDetour, "MTDetour_CTerrorGun::FireBullet", Hook_Pre, mreFireBulletPre, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddFireBulletDetour, "MTDetour_CTerrorGun::FireBullet", Hook_Post, mreFireBulletPost, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddFlingDetour, "MTDetour_CTerrorPlayer::Fling", Hook_Pre, mreFlingPre, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour2, "MTDetour_CTerrorMeleeWeapon::SecondaryAttack", Hook_Pre, mreSecondaryAttackPre, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour2, "MTDetour_CTerrorMeleeWeapon::SecondaryAttack", Hook_Post, mreSecondaryAttackPost, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddSelectWeightedSequenceDetour, "MTDetour_CTerrorPlayer::SelectWeightedSequence", Hook_Post, mreSelectWeightedSequencePost, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddStartActionDetour, "MTDetour_CBaseBackpackItem::StartAction", Hook_Pre, mreStartActionPre, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddStartActionDetour, "MTDetour_CBaseBackpackItem::StartAction", Hook_Post, mreStartActionPost, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddTankRockCreateDetour, "MTDetour_CTankRock::Create", Hook_Post, mreTankRockCreatePost, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, "MTDetour_CTerrorMeleeWeapon::TestMeleeSwingCollision", Hook_Pre, mreTestMeleeSwingCollisionPre, toggle, 2);
	vToggleDetour(g_esGeneral.g_ddTestMeleeSwingCollisionDetour, "MTDetour_CTerrorMeleeWeapon::TestMeleeSwingCollision", Hook_Post, mreTestMeleeSwingCollisionPost, toggle, 2);

	vToggleDetour(g_esGeneral.g_ddBeginChangeLevelDetour, "MTDetour_CTerrorPlayer::OnBeginChangeLevel", Hook_Pre, mreBeginChangeLevelPre, toggle);
	vToggleDetour(g_esGeneral.g_ddCanDeployForDetour, "MTDetour_CTerrorWeapon::CanDeployFor", Hook_Pre, mreCanDeployForPre, toggle);
	vToggleDetour(g_esGeneral.g_ddCanDeployForDetour, "MTDetour_CTerrorWeapon::CanDeployFor", Hook_Post, mreCanDeployForPost, toggle);
	vToggleDetour(g_esGeneral.g_ddDeathFallCameraEnableDetour, "MTDetour_CDeathFallCamera::Enable", Hook_Pre, mreDeathFallCameraEnablePre, toggle);
	vToggleDetour(g_esGeneral.g_ddDoJumpDetour, "MTDetour_CTerrorGameMovement::DoJump", Hook_Pre, mreDoJumpPre, toggle);
	vToggleDetour(g_esGeneral.g_ddDoJumpDetour, "MTDetour_CTerrorGameMovement::DoJump", Hook_Post, mreDoJumpPost, toggle);
	vToggleDetour(g_esGeneral.g_ddEnterStasisDetour, "MTDetour_Tank::EnterStasis", Hook_Post, mreEnterStasisPost, toggle);
	vToggleDetour(g_esGeneral.g_ddEventKilledDetour, "MTDetour_CTerrorPlayer::Event_Killed", Hook_Pre, mreEventKilledPre, toggle);
	vToggleDetour(g_esGeneral.g_ddEventKilledDetour, "MTDetour_CTerrorPlayer::Event_Killed", Hook_Post, mreEventKilledPost, toggle);
	vToggleDetour(g_esGeneral.g_ddFallingDetour, "MTDetour_CTerrorPlayer::OnFalling", Hook_Pre, mreFallingPre, toggle);
	vToggleDetour(g_esGeneral.g_ddFallingDetour, "MTDetour_CTerrorPlayer::OnFalling", Hook_Post, mreFallingPost, toggle);
	vToggleDetour(g_esGeneral.g_ddGetMaxClip1Detour, "MTDetour_CBaseCombatWeapon::GetMaxClip1", Hook_Pre, mreGetMaxClip1Pre, toggle);
	vToggleDetour(g_esGeneral.g_ddIncapacitatedAsTankDetour, "MTDetour_CTerrorPlayer::OnIncapacitatedAsTank", Hook_Pre, mreIncapacitatedAsTankPre, toggle);
	vToggleDetour(g_esGeneral.g_ddIncapacitatedAsTankDetour, "MTDetour_CTerrorPlayer::OnIncapacitatedAsTank", Hook_Post, mreIncapacitatedAsTankPost, toggle);
	vToggleDetour(g_esGeneral.g_ddLadderDismountDetour, "MTDetour_CTerrorPlayer::OnLadderDismount", Hook_Pre, mreLadderDismountPre, toggle);
	vToggleDetour(g_esGeneral.g_ddLadderDismountDetour, "MTDetour_CTerrorPlayer::OnLadderDismount", Hook_Post, mreLadderDismountPost, toggle);
	vToggleDetour(g_esGeneral.g_ddLadderMountDetour, "MTDetour_CTerrorPlayer::OnLadderMount", Hook_Pre, mreLadderMountPre, toggle);
	vToggleDetour(g_esGeneral.g_ddLadderMountDetour, "MTDetour_CTerrorPlayer::OnLadderMount", Hook_Post, mreLadderMountPost, toggle);
	vToggleDetour(g_esGeneral.g_ddLauncherDirectionDetour, "MTDetour_CEnvRockLauncher::LaunchCurrentDir", Hook_Pre, mreLaunchDirectionPre, toggle);
	vToggleDetour(g_esGeneral.g_ddLeaveStasisDetour, "MTDetour_Tank::LeaveStasis", Hook_Post, mreLeaveStasisPost, toggle);
	vToggleDetour(g_esGeneral.g_ddMaxCarryDetour, "MTDetour_CAmmoDef::MaxCarry", Hook_Pre, mreMaxCarryPre, toggle);
	vToggleDetour(g_esGeneral.g_ddPreThinkDetour, "MTDetour_CTerrorPlayer::PreThink", Hook_Pre, mrePreThinkPre, toggle);
	vToggleDetour(g_esGeneral.g_ddPreThinkDetour, "MTDetour_CTerrorPlayer::PreThink", Hook_Post, mrePreThinkPost, toggle);
	vToggleDetour(g_esGeneral.g_ddRevivedDetour, "MTDetour_CTerrorPlayer::OnRevived", Hook_Pre, mreRevivedPre, toggle);
	vToggleDetour(g_esGeneral.g_ddRevivedDetour, "MTDetour_CTerrorPlayer::OnRevived", Hook_Post, mreRevivedPost, toggle);
	vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour, "MTDetour_CTerrorWeapon::SecondaryAttack", Hook_Pre, mreSecondaryAttackPre, toggle);
	vToggleDetour(g_esGeneral.g_ddSecondaryAttackDetour, "MTDetour_CTerrorWeapon::SecondaryAttack", Hook_Post, mreSecondaryAttackPost, toggle);
	vToggleDetour(g_esGeneral.g_ddStartRevivingDetour, "MTDetour_CTerrorPlayer::StartReviving", Hook_Pre, mreStartRevivingPre, toggle);
	vToggleDetour(g_esGeneral.g_ddStartRevivingDetour, "MTDetour_CTerrorPlayer::StartReviving", Hook_Post, mreStartRevivingPost, toggle);
	vToggleDetour(g_esGeneral.g_ddTankClawDoSwingDetour, "MTDetour_CTankClaw::DoSwing", Hook_Pre, mreTankClawDoSwingPre, toggle);
	vToggleDetour(g_esGeneral.g_ddTankClawDoSwingDetour, "MTDetour_CTankClaw::DoSwing", Hook_Post, mreTankClawDoSwingPost, toggle);
	vToggleDetour(g_esGeneral.g_ddTankClawGroundPoundDetour, "MTDetour_CTankClaw::GroundPound", Hook_Pre, mreTankClawGroundPoundPre, toggle);
	vToggleDetour(g_esGeneral.g_ddTankClawGroundPoundDetour, "MTDetour_CTankClaw::GroundPound", Hook_Post, mreTankClawGroundPoundPost, toggle);
	vToggleDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, "MTDetour_CTankClaw::OnPlayerHit", Hook_Pre, mreTankClawPlayerHitPre, toggle);
	vToggleDetour(g_esGeneral.g_ddTankClawPlayerHitDetour, "MTDetour_CTankClaw::OnPlayerHit", Hook_Post, mreTankClawPlayerHitPost, toggle);

	switch (g_esGeneral.g_bLinux)
	{
		case true:
		{
			vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "MTDetour_CFirstAidKit::StartHealing", Hook_Pre, mreStartHealingLinuxPre, toggle, 1);
			vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "MTDetour_CFirstAidKit::StartHealing", Hook_Post, mreStartHealingLinuxPost, toggle, 1);
		}
		case false:
		{
			vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "MTDetour_CFirstAidKit::StartHealing", Hook_Pre, mreStartHealingWindowsPre, toggle, 1);
			vToggleDetour(g_esGeneral.g_ddStartHealingDetour, "MTDetour_CFirstAidKit::StartHealing", Hook_Post, mreStartHealingWindowsPost, toggle, 1);
		}
	}

	if (!g_esGeneral.g_bLeft4DHooksInstalled)
	{
		vToggleLeft4DHooks(toggle);
	}
}

void vToggleLeft4DHooks(bool toggle)
{
	if (g_esGeneral.g_bConfigsExecuted)
	{
		vToggleDetour(g_esGeneral.g_ddHitByVomitJarDetour, "MTDetour_CTerrorPlayer::OnHitByVomitJar", Hook_Pre, mreHitByVomitJarPre, toggle, 2);
		vToggleDetour(g_esGeneral.g_ddEnterGhostStateDetour, "MTDetour_CTerrorPlayer::OnEnterGhostState", Hook_Post, mreEnterGhostStatePost, toggle);
		vToggleDetour(g_esGeneral.g_ddFirstSurvivorLeftSafeAreaDetour, "MTDetour_CDirector::OnFirstSurvivorLeftSafeArea", Hook_Post, mreFirstSurvivorLeftSafeAreaPost, toggle);
		vToggleDetour(g_esGeneral.g_ddReplaceTankDetour, "MTDetour_ZombieManager::ReplaceTank", Hook_Post, mreReplaceTankPost, toggle);
		vToggleDetour(g_esGeneral.g_ddShovedByPounceLandingDetour, "MTDetour_CTerrorPlayer::OnShovedByPounceLanding", Hook_Pre, mreShovedByPounceLandingPre, toggle);
		vToggleDetour(g_esGeneral.g_ddShovedBySurvivorDetour, "MTDetour_CTerrorPlayer::OnShovedBySurvivor", Hook_Pre, mreShovedBySurvivorPre, toggle);
		vToggleDetour(g_esGeneral.g_ddSpawnTankDetour, "MTDetour_ZombieManager::SpawnTank", Hook_Pre, mreSpawnTankPre, toggle);
		vToggleDetour(g_esGeneral.g_ddStaggerDetour, "MTDetour_CTerrorPlayer::OnStaggered", Hook_Pre, mreStaggerPre, toggle);
		vToggleDetour(g_esGeneral.g_ddVomitedUponDetour, "MTDetour_CTerrorPlayer::OnVomitedUpon", Hook_Pre, mreVomitedUponPre, toggle);
	}
}

bool bRegisterDetour(const char[] name, bool log = false, int type = 2, bool bypass)
{
	if (iGetDetourIndex(name) >= 0)
	{
		LogError("%s The \"%s\" detour has already been registered.", MT_TAG, name);

		return false;
	}

	strcopy(g_sDetourName[g_iDetourCount], sizeof g_sDetourName, name);

	g_bDetourBypass[g_iDetourCount] = bypass;
	g_bDetourInstalled[g_iDetourCount] = false;
	g_bDetourLog[g_iDetourCount] = log;
	g_iDetourType[g_iDetourCount] = type;
	g_iDetourCount++;

	if (log)
	{
		vLogMessage(-1, _, "%s Registered the \"%s\" detour.", MT_TAG, name);
	}

	return true;
}

int iGetDetourIndex(const char[] name)
{
	for (int iPos = 0; iPos < g_iDetourCount; iPos++)
	{
		if (StrEqual(name, g_sDetourName[iPos]))
		{
			return iPos;
		}
	}

	return -1;
}

public MRESReturn mreActionCompletePre(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_cvMTFirstAidHealPercent != null)
	{
		int iSurvivor = hParams.IsNull(1) ? 0 : hParams.Get(1), iTeammate = hParams.IsNull(2) ? 0 : hParams.Get(2);
		if (bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 6) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_HEALTH)))
		{
			vSetHealPercentCvar(false, iSurvivor);
		}
		else if (bIsSurvivor(iTeammate) && (bIsDeveloper(iTeammate, 6) || (g_esPlayer[iTeammate].g_iRewardTypes & MT_REWARD_HEALTH)))
		{
			vSetHealPercentCvar(false, iTeammate);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreActionCompletePost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_flDefaultFirstAidHealPercent != -1.0)
	{
		vSetHealPercentCvar(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreBaseEntityCreatePost(DHookReturn hReturn, DHookParam hParams)
{
	char sClassname[32];
	hParams.GetString(1, sClassname, sizeof sClassname);
	if (StrEqual(sClassname, "tank_rock") && hParams.IsNull(4))
	{
		vSetRockColor(hReturn.Value);
	}

	return MRES_Ignored;
}

public MRESReturn mreBeginChangeLevelPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && g_esPlayer[pThis].g_iRewardTypes > 0)
	{
		vEndRewards(pThis, true);
	}

	return MRES_Ignored;
}

public MRESReturn mreCanDeployForPre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int iSurvivor;

	switch (g_bSecondGame && !hParams.IsNull(1))
	{
		case true: iSurvivor = hParams.Get(1);
		case false: iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	}

	if (bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 6) || ((g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST) && g_esPlayer[iSurvivor].g_iLadderActions == 1)))
	{
		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("LadderMount2");
		}

		if (iIndex != -1)
		{
			bInstallPatch(iIndex);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreCanDeployForPost(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	static int iIndex = -1;
	if (iIndex == -1)
	{
		iIndex = iGetPatchIndex("LadderMount2");
	}

	if (iIndex != -1)
	{
		bRemovePatch(iIndex);
	}

	return MRES_Ignored;
}

public MRESReturn mreDeathFallCameraEnablePre(int pThis, DHookParam hParams)
{
	int iSurvivor = hParams.IsNull(1) ? 0 : hParams.Get(1);
	if (bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 5) || bIsDeveloper(iSurvivor, 11) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_GODMODE)) && g_esPlayer[iSurvivor].g_bFalling)
	{
		g_esPlayer[iSurvivor].g_bFatalFalling = true;

		return MRES_Supercede;
	}

	g_esPlayer[iSurvivor].g_bFatalFalling = true;

	Action aResult = Plugin_Continue;
	Call_StartForward(g_esGeneral.g_gfFatalFallingForward);
	Call_PushCell(iSurvivor);
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreDoAnimationEventPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
	{
		int iAnim = hParams.Get(1);
		if (iAnim == 57 // punched by a Tank
			|| iAnim == 96) // landing on something
		{
			hParams.Set(1, 65); // active/standing state

			return MRES_ChangedHandled;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreDoJumpPre(int pThis, DHookParam hParams)
{
	Address adSurvivor = view_as<Address>(LoadFromAddress(view_as<Address>(pThis + 4), NumberType_Int32));
	int iSurvivor = iGetEntityIndex(SDKCall(g_esGeneral.g_hSDKGetRefEHandle, adSurvivor));
	if (bIsSurvivor(iSurvivor))
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 5);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
		{
			if (!g_esGeneral.g_bPatchDoJumpValue)
			{
				float flHeight = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevJumpHeight > g_esPlayer[iSurvivor].g_flJumpHeight) ? g_esDeveloper[iSurvivor].g_flDevJumpHeight : g_esPlayer[iSurvivor].g_flJumpHeight;
				if (flHeight > 0.0)
				{
					g_esGeneral.g_bPatchDoJumpValue = true;

					switch (!g_bSecondGame && g_esGeneral.g_bLinux)
					{
						case true:
						{
							g_esGeneral.g_adOriginalJumpHeight[0] = LoadFromAddress(g_esGeneral.g_adDoJumpValue, NumberType_Int32);
							StoreToAddress(g_esGeneral.g_adDoJumpValue, view_as<int>(flHeight), NumberType_Int32, g_bUpdateMemAccess2);
							g_bUpdateMemAccess2 = false;
						}
						case false:
						{
							g_esGeneral.g_adOriginalJumpHeight[1] = LoadFromAddress(g_esGeneral.g_adDoJumpValue, NumberType_Int32);
							g_esGeneral.g_adOriginalJumpHeight[0] = LoadFromAddress((g_esGeneral.g_adDoJumpValue + view_as<Address>(4)), NumberType_Int32);

							int iDouble[2];
							vGetDoubleFromFloat(flHeight, iDouble);
							StoreToAddress(g_esGeneral.g_adDoJumpValue, iDouble[1], NumberType_Int32, g_bUpdateMemAccess2);
							StoreToAddress((g_esGeneral.g_adDoJumpValue + view_as<Address>(4)), iDouble[0], NumberType_Int32, g_bUpdateMemAccess2);

							g_bUpdateMemAccess2 = false;
						}
					}
				}
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreDoJumpPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_bPatchDoJumpValue)
	{
		g_esGeneral.g_bPatchDoJumpValue = false;

		switch (!g_bSecondGame && g_esGeneral.g_bLinux)
		{
			case true: StoreToAddress(g_esGeneral.g_adDoJumpValue, g_esGeneral.g_adOriginalJumpHeight[0], NumberType_Int32, g_bUpdateMemAccess2);
			case false:
			{
				StoreToAddress(g_esGeneral.g_adDoJumpValue, g_esGeneral.g_adOriginalJumpHeight[1], NumberType_Int32, g_bUpdateMemAccess2);
				StoreToAddress((g_esGeneral.g_adDoJumpValue + view_as<Address>(4)), g_esGeneral.g_adOriginalJumpHeight[0], NumberType_Int32, g_bUpdateMemAccess2);
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreEnterGhostStatePost(int pThis)
{
	if (bIsTank(pThis))
	{
		g_esPlayer[pThis].g_bKeepCurrentType = true;

		if (g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_flForceSpawn > 0.0)
		{
			CreateTimer(g_esGeneral.g_flForceSpawn, tTimerForceSpawnTank, GetClientUserId(pThis), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreEnterStasisPost(int pThis)
{
	if (bIsTank(pThis))
	{
		g_esPlayer[pThis].g_bStasis = true;
	}

	return MRES_Ignored;
}

public MRESReturn mreEventKilledPre(int pThis, DHookParam hParams)
{
	int iAttacker = hParams.GetObjectVar(1, g_esGeneral.g_iEventKilledAttackerOffset, ObjectValueType_Ehandle);
	if (bIsSurvivor(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esPlayer[pThis].g_bLastLife = false;
		g_esPlayer[pThis].g_iReviveCount = 0;

		vResetSurvivorStats(pThis, true);
		vSaveWeapons(pThis);
	}
	else if (bIsTank(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		if (!bIsCustomTank(pThis))
		{
			g_esGeneral.g_iTankCount--;

			if (!g_esPlayer[pThis].g_bArtificial)
			{
				delete g_esGeneral.g_hTankWaveTimer;

				g_esGeneral.g_hTankWaveTimer = CreateTimer(5.0, tTimerTankWave);
			}
		}

		if (bIsTankSupported(pThis) && bIsCustomTankSupported(pThis))
		{
			vCombineAbilitiesForward(pThis, MT_COMBO_UPONDEATH);
		}
	}
	else if (bIsSpecialInfected(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		SetEntityRenderMode(pThis, RENDER_NORMAL);
		SetEntityRenderColor(pThis, 255, 255, 255, 255);

		if (bIsSurvivor(iAttacker) && (bIsDeveloper(iAttacker, 10) || ((g_esPlayer[iAttacker].g_iRewardTypes & MT_REWARD_GODMODE) && g_esPlayer[iAttacker].g_iCleanKills == 1)))
		{
			bool bBoomer = bIsBoomer(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME), bSmoker = bIsSmoker(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME);
			char sName[32];
			static int iIndex[11] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
			int iLimit = g_bSecondGame ? 6 : 3;
			for (int iPos = 0; iPos < sizeof iIndex; iPos++)
			{
				if (bBoomer && iPos < iLimit) // X < 6 or 3
				{
					FormatEx(sName, sizeof sName, "Boomer%iCleanKill", (iPos + 1)); // X + 1 = 1...3/6
					if (iIndex[iPos] == -1)
					{
						iIndex[iPos] = iGetPatchIndex(sName);
					}

					if (iIndex[iPos] != -1)
					{
						bInstallPatch(iIndex[iPos]);
					}
				}
				else if (bSmoker && iLimit <= iPos <= (iLimit + 3)) // X <= 6 or 3 <= X + 3
				{
					FormatEx(sName, sizeof sName, "Smoker%iCleanKill", (iPos - (iLimit - 1))); // X - 2/5 = 1...4
					if (iIndex[iPos] == -1)
					{
						iIndex[iPos] = iGetPatchIndex(sName);
					}

					if (iIndex[iPos] != -1)
					{
						bInstallPatch(iIndex[iPos]);
					}
				}
			}

			if (bIsSpitter(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				if (iIndex[10] == -1)
				{
					iIndex[10] = iGetPatchIndex("SpitterCleanKill");
				}

				if (iIndex[10] != -1)
				{
					bInstallPatch(iIndex[10]);
				}
			}
		}
	}

	Call_StartForward(g_esGeneral.g_gfPlayerEventKilledForward);
	Call_PushCell(pThis);
	Call_PushCell(iAttacker);
	Call_Finish();

	return MRES_Ignored;
}

public MRESReturn mreEventKilledPost(int pThis, DHookParam hParams)
{
	char sName[32];
	static int iIndex[11] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
	int iLimit = g_bSecondGame ? 6 : 3;
	for (int iPos = 0; iPos < sizeof iIndex; iPos++)
	{
		if (iPos < iLimit) // X < 6 or 3
		{
			FormatEx(sName, sizeof sName, "Boomer%iCleanKill", (iPos + 1)); // X + 1 = 1...3/6
			if (iIndex[iPos] == -1)
			{
				iIndex[iPos] = iGetPatchIndex(sName);
			}

			if (iIndex[iPos] != -1)
			{
				bRemovePatch(iIndex[iPos]);
			}
		}
		else if (iLimit <= iPos <= (iLimit + 3)) // X <= 6 or 3 <= X + 3
		{
			FormatEx(sName, sizeof sName, "Smoker%iCleanKill", (iPos - (iLimit - 1))); // X - 2/5 = 1...4
			if (iIndex[iPos] == -1)
			{
				iIndex[iPos] = iGetPatchIndex(sName);
			}

			if (iIndex[iPos] != -1)
			{
				bRemovePatch(iIndex[iPos]);
			}
		}
	}

	if (iIndex[10] == -1)
	{
		iIndex[10] = iGetPatchIndex("SpitterCleanKill");
	}

	if (iIndex[10] != -1)
	{
		bRemovePatch(iIndex[10]);
	}

	return MRES_Ignored;
}

public MRESReturn mreFallingPre(int pThis)
{
	if (bIsSurvivor(pThis) && !g_esPlayer[pThis].g_bFalling)
	{
		g_esPlayer[pThis].g_bFallDamage = true;
		g_esPlayer[pThis].g_bFalling = true;

		static int iIndex[2] = {-1, -1};
		if (iIndex[0] == -1)
		{
			iIndex[0] = iGetPatchIndex("DoJumpHeight");
		}

		if (((iIndex[0] != -1 && g_bPermanentPatch[iIndex[0]]) || bIsDeveloper(pThis, 5) || bIsDeveloper(pThis, 11) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_SPEEDBOOST) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)) && !g_esGeneral.g_bPatchFallingSound)
		{
			g_esGeneral.g_bPatchFallingSound = true;

			if (iIndex[1] == -1)
			{
				iIndex[1] = iGetPatchIndex("FallScreamMute");
			}

			if (iIndex[1] != -1)
			{
				bInstallPatch(iIndex[1]);
			}

			char sVoiceLine[64];
			sVoiceLine = (bIsDeveloper(pThis) && g_esDeveloper[pThis].g_sDevFallVoiceline[0] != '\0') ? g_esDeveloper[pThis].g_sDevFallVoiceline : g_esPlayer[pThis].g_sFallVoiceline;
			if (sVoiceLine[0] != '\0')
			{
				vVocalize(pThis, sVoiceLine);
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreFallingPost(int pThis)
{
	if (g_esGeneral.g_bPatchFallingSound)
	{
		g_esGeneral.g_bPatchFallingSound = false;

		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("FallScreamMute");
		}

		if (iIndex != -1)
		{
			bRemovePatch(iIndex);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreFirstSurvivorLeftSafeAreaPost(DHookParam hParams)
{
	int iSurvivor = hParams.IsNull(1) ? 0 : hParams.Get(1);
	if (bIsSurvivor(iSurvivor))
	{
		vResetTimers(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreFinishHealingPre(int pThis)
{
	int iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTFirstAidHealPercent != null)
	{
		if (bIsDeveloper(iSurvivor, 6) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_HEALTH))
		{
			vSetHealPercentCvar(false, iSurvivor);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreFinishHealingPost(int pThis)
{
	if (g_esGeneral.g_flDefaultFirstAidHealPercent != -1.0)
	{
		vSetHealPercentCvar(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreFireBulletPre(int pThis)
{
	int iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor, 9) || ((g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST) && g_esPlayer[iSurvivor].g_iSledgehammerRounds == 1) && g_esGeneral.g_cvMTPhysicsPushScale != null)
	{
		g_esGeneral.g_flDefaultPhysicsPushScale = g_esGeneral.g_cvMTPhysicsPushScale.FloatValue;
		g_esGeneral.g_cvMTPhysicsPushScale.FloatValue = 5.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreFireBulletPost(int pThis)
{
	if (g_esGeneral.g_flDefaultPhysicsPushScale != -1.0)
	{
		g_esGeneral.g_cvMTPhysicsPushScale.FloatValue = g_esGeneral.g_flDefaultPhysicsPushScale;
		g_esGeneral.g_flDefaultPhysicsPushScale = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreFlingPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis))
	{
		if (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			hParams.Set(4, 1.5);

			return MRES_ChangedHandled;
		}
		else if (bIsDeveloper(pThis, 8) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE))
		{
			return MRES_Supercede;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreGetMaxClip1Pre(int pThis, DHookReturn hReturn)
{
	int iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner"), iClip = iGetMaxAmmo(iSurvivor, 0, pThis, false);
	if (bIsSurvivor(iSurvivor) && iClip > 0)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 4) || bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || ((g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_AMMO) && g_esPlayer[iSurvivor].g_iAmmoBoost == 1))
		{
			hReturn.Value = iClip;

			return MRES_Override;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreHitByVomitJarPre(int pThis, DHookParam hParams)
{
	int iSurvivor = hParams.IsNull(1) ? 0 : hParams.Get(1);
	if (bIsTank(pThis) && g_esCache[pThis].g_iVomitImmunity == 1 && bIsSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && !(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
	{
		return MRES_Supercede;
	}

	Action aResult = Plugin_Continue;
	Call_StartForward(g_esGeneral.g_gfPlayerHitByVomitJarForward);
	Call_PushCell(pThis);
	Call_PushCell(iSurvivor);
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreIncapacitatedAsTankPre(int pThis, DHookParam hParams)
{
	if (bIsTank(pThis) && g_esCache[pThis].g_iSkipIncap == 1 && g_esGeneral.g_cvMTTankIncapHealth != null)
	{
		g_esGeneral.g_iDefaultTankIncapHealth = g_esGeneral.g_cvMTTankIncapHealth.IntValue;
		g_esGeneral.g_cvMTTankIncapHealth.IntValue = 0;

		return MRES_Override;
	}

	return MRES_Ignored;
}

public MRESReturn mreIncapacitatedAsTankPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_iDefaultTankIncapHealth != -1)
	{
		g_esGeneral.g_cvMTTankIncapHealth.IntValue = g_esGeneral.g_iDefaultTankIncapHealth;
		g_esGeneral.g_iDefaultTankIncapHealth = -1;
	}

	return MRES_Ignored;
}

public MRESReturn mreLadderDismountPre(int pThis)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || ((g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST) && g_esPlayer[pThis].g_iLadderActions == 1)))
	{
		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("LadderDismount1");
		}

		if (iIndex != -1)
		{
			bInstallPatch(iIndex);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreLadderDismountPost(int pThis)
{
	static int iIndex = -1;
	if (iIndex == -1)
	{
		iIndex = iGetPatchIndex("LadderDismount1");
	}

	if (iIndex != -1)
	{
		bRemovePatch(iIndex);
	}

	return MRES_Ignored;
}

public MRESReturn mreLadderMountPre(int pThis)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || ((g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST) && g_esPlayer[pThis].g_iLadderActions == 1)))
	{
		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("LadderMount1");
		}

		if (iIndex != -1)
		{
			bInstallPatch(iIndex);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreLadderMountPost(int pThis)
{
	static int iIndex = -1;
	if (iIndex == -1)
	{
		iIndex = iGetPatchIndex("LadderMount1");
	}

	if (iIndex != -1)
	{
		bRemovePatch(iIndex);
	}

	return MRES_Ignored;
}

public MRESReturn mreLaunchDirectionPre(int pThis)
{
	if (bIsValidEntity(pThis))
	{
		g_esGeneral.g_iLauncher = EntIndexToEntRef(pThis);
	}

	return MRES_Ignored;
}

public MRESReturn mreLeaveStasisPost(int pThis)
{
	if (bIsTank(pThis))
	{
		g_esPlayer[pThis].g_bStasis = false;
	}

	return MRES_Ignored;
}

public MRESReturn mreMaxCarryPre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int iSurvivor = hParams.IsNull(2) ? 0 : hParams.Get(2), iAmmo = iGetMaxAmmo(iSurvivor, hParams.Get(1), 0, true);
	if (bIsSurvivor(iSurvivor) && iAmmo > 0)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 4) || bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || ((g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_AMMO) && g_esPlayer[iSurvivor].g_iAmmoBoost == 1))
		{
			hReturn.Value = iAmmo;

			return MRES_Override;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mrePreThinkPre(int pThis)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || ((g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST) && g_esPlayer[pThis].g_iLadderActions == 1)))
	{
		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("LadderDismount2");
		}

		if (iIndex != -1)
		{
			bInstallPatch(iIndex);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mrePreThinkPost(int pThis)
{
	static int iIndex = -1;
	if (iIndex == -1)
	{
		iIndex = iGetPatchIndex("LadderDismount2");
	}

	if (iIndex != -1)
	{
		bRemovePatch(iIndex);
	}

	return MRES_Ignored;
}

public MRESReturn mreReplaceTankPost(DHookParam hParams)
{
	int iOldTank = hParams.IsNull(1) ? 0 : hParams.Get(1), iNewTank = hParams.IsNull(2) ? 0 : hParams.Get(2);
	g_esPlayer[iNewTank].g_bReplaceSelf = true;

	vSetTankColor(iNewTank, g_esPlayer[iOldTank].g_iTankType);
	vCopyTankStats(iOldTank, iNewTank);
	vTankSpawn(iNewTank, -1);
	vResetTank(iOldTank, 0);
	vResetTank2(iOldTank);
	vCacheSettings(iOldTank);

	return MRES_Ignored;
}

public MRESReturn mreRevivedPre(int pThis)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_HEALTH)) && g_esGeneral.g_cvMTSurvivorReviveHealth != null)
	{
		vSetReviveHealthCvar(false, pThis);
	}

	return MRES_Ignored;
}

public MRESReturn mreRevivedPost(int pThis)
{
	if (g_esGeneral.g_cvMTSurvivorReviveHealth != null)
	{
		vSetReviveHealthCvar(true);
	}

	return MRES_Ignored;
}

public MRESReturn mreSecondaryAttackPre(int pThis)
{
	int iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTGunSwingInterval != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			float flMultiplier = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevShoveRate > g_esPlayer[iSurvivor].g_flShoveRate) ? g_esDeveloper[iSurvivor].g_flDevShoveRate : g_esPlayer[iSurvivor].g_flShoveRate;
			if (flMultiplier > 0.0)
			{
				g_esGeneral.g_flDefaultGunSwingInterval = g_esGeneral.g_cvMTGunSwingInterval.FloatValue;
				g_esGeneral.g_cvMTGunSwingInterval.FloatValue *= flMultiplier;
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreSecondaryAttackPost(int pThis)
{
	if (g_esGeneral.g_flDefaultGunSwingInterval != -1.0)
	{
		g_esGeneral.g_cvMTGunSwingInterval.FloatValue = g_esGeneral.g_flDefaultGunSwingInterval;
		g_esGeneral.g_flDefaultGunSwingInterval = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreSelectWeightedSequencePost(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (bIsTank(pThis) && g_esCache[pThis].g_iSkipTaunt == 1 && 54 <= hReturn.Value <= 60)
	{
		hReturn.Value = iGetAnimation(pThis, "ACT_HULK_ATTACK_LOW");
		SetEntPropFloat(pThis, Prop_Send, "m_flCycle", 15.0);

		return MRES_Override;
	}

	return MRES_Ignored;
}

public MRESReturn mreShovedByPounceLandingPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 8) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreShovedBySurvivorPre(int pThis, DHookParam hParams)
{
	Action aResult = Plugin_Continue;
	int iSurvivor = hParams.IsNull(1) ? 0 : hParams.Get(1);
	float flDirection[3];
	hParams.GetVector(2, flDirection);

	Call_StartForward(g_esGeneral.g_gfPlayerShovedBySurvivorForward);
	Call_PushCell(pThis);
	Call_PushCell(iSurvivor);
	Call_PushArray(flDirection, sizeof flDirection);
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreSetMainActivityPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
	{
		int iActivity = hParams.Get(1);
		if (iActivity == 1077 // ACT_TERROR_HIT_BY_TANKPUNCH
			|| iActivity == 1078 // ACT_TERROR_IDLE_FALL_FROM_TANKPUNCH
			|| iActivity == 1263 // ACT_TERROR_POUNCED_TO_STAND
			|| iActivity == 1283) // ACT_TERROR_TANKROCK_TO_STAND
		{
			hParams.Set(1, 1079); // ACT_TERROR_TANKPUNCH_LAND

			return MRES_ChangedHandled;
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreSpawnTankPre(DHookReturn hReturn, DHookParam hParams)
{
	float flPos[3], flAngles[3];
	hParams.GetVector(1, flPos);
	hParams.GetVector(2, flAngles);

	if (g_esGeneral.g_iLimitExtras == 0 || g_esGeneral.g_bForceSpawned)
	{
		return MRES_Ignored;
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

	if (bBlock)
	{
		hReturn.Value = 0;

		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreStaggerPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 8) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreStartActionPre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_hSDKGetUseAction != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			float flDuration = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevActionDuration > g_esPlayer[iSurvivor].g_flActionDuration) ? g_esDeveloper[iSurvivor].g_flDevActionDuration : g_esPlayer[iSurvivor].g_flActionDuration;
			if (flDuration > 0.0)
			{
				vSetDurationCvars(pThis, false, flDuration);
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreStartActionPost(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (g_esGeneral.g_hSDKGetUseAction != null)
	{
		vSetDurationCvars(pThis, true);
	}

	return MRES_Ignored;
}

public MRESReturn mreStartHealingLinuxPre(DHookParam hParams)
{
	int pThis = hParams.Get(1), iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTFirstAidKitUseDuration != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			float flDuration = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevActionDuration > g_esPlayer[iSurvivor].g_flActionDuration) ? g_esDeveloper[iSurvivor].g_flDevActionDuration : g_esPlayer[iSurvivor].g_flActionDuration;
			if (flDuration > 0.0)
			{
				g_esGeneral.g_flDefaultFirstAidKitUseDuration = g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue;
				g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = flDuration;
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreStartHealingLinuxPost(DHookParam hParams)
{
	if (g_esGeneral.g_flDefaultFirstAidKitUseDuration != -1.0)
	{
		g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = g_esGeneral.g_flDefaultFirstAidKitUseDuration;
		g_esGeneral.g_flDefaultFirstAidKitUseDuration = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreStartHealingWindowsPre(int pThis, DHookParam hParams)
{
	int iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTFirstAidKitUseDuration != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
		{
			float flDuration = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevActionDuration > g_esPlayer[iSurvivor].g_flActionDuration) ? g_esDeveloper[iSurvivor].g_flDevActionDuration : g_esPlayer[iSurvivor].g_flActionDuration;
			if (flDuration > 0.0)
			{
				g_esGeneral.g_flDefaultFirstAidKitUseDuration = g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue;
				g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = flDuration;
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreStartHealingWindowsPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_flDefaultFirstAidKitUseDuration != -1.0)
	{
		g_esGeneral.g_cvMTFirstAidKitUseDuration.FloatValue = g_esGeneral.g_flDefaultFirstAidKitUseDuration;
		g_esGeneral.g_flDefaultFirstAidKitUseDuration = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreStartRevivingPre(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_cvMTSurvivorReviveDuration != null)
	{
		int iTarget = hParams.IsNull(1) ? 0 : hParams.Get(1);
		if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 6) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
		{
			vSetReviveDurationCvar(pThis);
		}
		else if (bIsSurvivor(iTarget) && (bIsDeveloper(iTarget, 6) || (g_esPlayer[iTarget].g_iRewardTypes & MT_REWARD_ATTACKBOOST)))
		{
			vSetReviveDurationCvar(iTarget);
		}

		g_esPlayer[iTarget].g_iReviver = GetClientUserId(pThis);
	}

	return MRES_Ignored;
}

public MRESReturn mreStartRevivingPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_flDefaultSurvivorReviveDuration != -1.0)
	{
		g_esGeneral.g_cvMTSurvivorReviveDuration.FloatValue = g_esGeneral.g_flDefaultSurvivorReviveDuration;
		g_esGeneral.g_flDefaultSurvivorReviveDuration = -1.0;
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawDoSwingPre(int pThis)
{
	int iTank = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsTank(iTank) && g_esCache[iTank].g_iSweepFist == 1)
	{
		char sName[32];
		static int iIndex[2] = {-1, -1};
		for (int iPos = 0; iPos < sizeof iIndex; iPos++)
		{
			if (iIndex[iPos] == -1)
			{
				FormatEx(sName, sizeof sName, "TankSweepFist%i", (iPos + 1));
				iIndex[iPos] = iGetPatchIndex(sName);
			}

			if (iIndex[iPos] != -1)
			{
				bInstallPatch(iIndex[iPos]);
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawDoSwingPost(int pThis)
{
	char sName[32];
	static int iIndex[2] = {-1, -1};
	for (int iPos = 0; iPos < sizeof iIndex; iPos++)
	{
		if (iIndex[iPos] == -1)
		{
			FormatEx(sName, sizeof sName, "TankSweepFist%i", (iPos + 1));
			iIndex[iPos] = iGetPatchIndex(sName);
		}

		if (iIndex[iPos] != -1)
		{
			bRemovePatch(iIndex[iPos]);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawGroundPoundPre(int pThis)
{
	int iTank = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsTank(iTank) && g_esCache[iTank].g_iGroundPound == 1)
	{
		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("TankGroundPound");
		}

		if (iIndex != -1)
		{
			bInstallPatch(iIndex);
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawGroundPoundPost(int pThis)
{
	static int iIndex = -1;
	if (iIndex == -1)
	{
		iIndex = iGetPatchIndex("TankGroundPound");
	}

	if (iIndex != -1)
	{
		bRemovePatch(iIndex);
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawPlayerHitPre(int pThis, DHookParam hParams)
{
	g_esGeneral.g_iTankTarget = hParams.IsNull(1) ? 0 : hParams.Get(1);
	if (bIsSurvivor(g_esGeneral.g_iTankTarget) && bIsDeveloper(g_esGeneral.g_iTankTarget, 8))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

public MRESReturn mreTankClawPlayerHitPost(int pThis, DHookParam hParams)
{
	int iTank = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner"), iSurvivor = g_esGeneral.g_iTankTarget;
	if (bIsTank(iTank) && bIsSurvivor(iSurvivor))
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 4);
		if (g_esCache[iTank].g_flPunchForce >= 0.0 || bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_GODMODE))
		{
			float flVelocity[3], flForce = flGetPunchForce(iSurvivor, g_esCache[iTank].g_flPunchForce);
			if (flForce >= 0.0)
			{
				GetEntPropVector(iSurvivor, Prop_Data, "m_vecVelocity", flVelocity);
				ScaleVector(flVelocity, flForce);
				TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
			}
		}
	}

	g_esGeneral.g_iTankTarget = 0;

	return MRES_Ignored;
}

public MRESReturn mreTankRockCreatePost(DHookReturn hReturn, DHookParam hParams)
{
	if (hParams.IsNull(4))
	{
		vSetRockColor(hReturn.Value);
	}

	return MRES_Ignored;
}

public MRESReturn mreTestMeleeSwingCollisionPre(int pThis, DHookParam hParams)
{
	int iSurvivor = !bIsValidEntity(pThis) ? 0 : GetEntPropEnt(pThis, Prop_Send, "m_hOwner");
	if (bIsSurvivor(iSurvivor) && g_esGeneral.g_cvMTMeleeRange != null)
	{
		bool bDeveloper = bIsDeveloper(iSurvivor, 6);
		if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
		{
			int iRange = (bDeveloper && g_esDeveloper[iSurvivor].g_iDevMeleeRange > g_esPlayer[iSurvivor].g_iMeleeRange) ? g_esDeveloper[iSurvivor].g_iDevMeleeRange : g_esPlayer[iSurvivor].g_iMeleeRange;
			if (iRange > 0)
			{
				g_esGeneral.g_iDefaultMeleeRange = g_esGeneral.g_cvMTMeleeRange.IntValue;
				g_esGeneral.g_cvMTMeleeRange.IntValue = iRange;
			}
		}
	}

	return MRES_Ignored;
}

public MRESReturn mreTestMeleeSwingCollisionPost(int pThis, DHookParam hParams)
{
	if (g_esGeneral.g_iDefaultMeleeRange != -1)
	{
		g_esGeneral.g_cvMTMeleeRange.IntValue = g_esGeneral.g_iDefaultMeleeRange;
		g_esGeneral.g_iDefaultMeleeRange = -1;
	}

	return MRES_Ignored;
}

public MRESReturn mreVomitedUponPre(int pThis, DHookParam hParams)
{
	if (bIsSurvivor(pThis) && (bIsDeveloper(pThis, 8) || bIsDeveloper(pThis, 10) || (g_esPlayer[pThis].g_iRewardTypes & MT_REWARD_GODMODE)))
	{
		return MRES_Supercede;
	}

	return MRES_Ignored;
}