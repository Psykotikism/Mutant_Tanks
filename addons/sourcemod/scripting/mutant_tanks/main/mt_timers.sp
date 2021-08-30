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

void vResetTimers(bool delay = false)
{
	switch (delay)
	{
		case true: CreateTimer(g_esGeneral.g_flRegularDelay, tTimerDelayRegularWaves, .flags = TIMER_FLAG_NO_MAPCHANGE);
		case false:
		{
			if (g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea != null && g_esGeneral.g_adDirector != Address_Null)
			{
				if (SDKCall(g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea, g_esGeneral.g_adDirector))
				{
					delete g_esGeneral.g_hRegularWavesTimer;

					g_esGeneral.g_hRegularWavesTimer = CreateTimer(g_esGeneral.g_flRegularInterval, tTimerRegularWaves, .flags = TIMER_REPEAT);
				}
			}
		}
	}

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankSupported(iTank))
		{
			vResetTimersForward(1, iTank);
		}
	}

	vResetTimersForward();
}

public Action tTimerAnnounce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTank(iTank))
	{
		return Plugin_Stop;
	}

	if (bIsTankSupported(iTank) && !bIsTankIdle(iTank))
	{
		char sOldName[33], sNewName[33];
		pack.ReadString(sOldName, sizeof sOldName);
		pack.ReadString(sNewName, sizeof sNewName);
		int iMode = pack.ReadCell();
		vAnnounce(iTank, sOldName, sNewName, iMode);

		return Plugin_Stop;
	}
	else
	{
		vTriggerTank(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerAnnounce2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTank(iTank))
	{
		return Plugin_Stop;
	}

	if (!bIsTankIdle(iTank))
	{
		vAnnounceArrival(iTank, "NoName");

		return Plugin_Stop;
	}
	else
	{
		vTriggerTank(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerBloodEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_BLOOD) || !g_esPlayer[iTank].g_bBlood)
	{
		g_esPlayer[iTank].g_bBlood = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_BLOOD, 0.75, 30.0);

	return Plugin_Continue;
}

public Action tTimerBlurEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iPropsAttached & MT_PROP_BLUR) || !g_esPlayer[iTank].g_bBlur)
	{
		g_esPlayer[iTank].g_bBlur = false;

		return Plugin_Stop;
	}

	int iTankModel = EntRefToEntIndex(g_esPlayer[iTank].g_iBlur);
	if (iTankModel == INVALID_ENT_REFERENCE || !bIsValidEntity(iTankModel))
	{
		g_esPlayer[iTank].g_bBlur = false;
		g_esPlayer[iTank].g_iBlur = INVALID_ENT_REFERENCE;

		return Plugin_Stop;
	}

	float flTankPos[3], flTankAng[3];
	GetClientAbsOrigin(iTank, flTankPos);
	GetClientAbsAngles(iTank, flTankAng);
	if (bIsValidEntity(iTankModel))
	{
		TeleportEntity(iTankModel, flTankPos, flTankAng, NULL_VECTOR);
		SetEntProp(iTankModel, Prop_Send, "m_nSequence", GetEntProp(iTank, Prop_Send, "m_nSequence"));
	}

	return Plugin_Continue;
}

public Action tTimerBoss(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bIsCustomTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !g_esPlayer[iTank].g_bBoss)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	int iBossStages = pack.ReadCell(),
		iBossHealth = pack.ReadCell(), iType = pack.ReadCell(),
		iBossHealth2 = pack.ReadCell(), iType2 = pack.ReadCell(),
		iBossHealth3 = pack.ReadCell(), iType3 = pack.ReadCell(),
		iBossHealth4 = pack.ReadCell(), iType4 = pack.ReadCell();

	switch (g_esPlayer[iTank].g_iBossStageCount)
	{
		case 0: vBoss(iTank, iBossHealth, iBossStages, iType, 1);
		case 1: vBoss(iTank, iBossHealth2, iBossStages, iType2, 2);
		case 2: vBoss(iTank, iBossHealth3, iBossStages, iType3, 3);
		case 3: vBoss(iTank, iBossHealth4, iBossStages, iType4, 4);
	}

	return Plugin_Continue;
}

public Action tTimerCheckTankView(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT))
	{
		return Plugin_Stop;
	}

	QueryClientConVar(iTank, "z_view_distance", vViewDistanceQuery);

	return Plugin_Continue;
}

public Action tTimerDelayRegularWaves(Handle timer)
{
	delete g_esGeneral.g_hRegularWavesTimer;

	g_esGeneral.g_hRegularWavesTimer = CreateTimer(g_esGeneral.g_flRegularInterval, tTimerRegularWaves, .flags = TIMER_REPEAT);
}

public Action tTimerDelaySurvival(Handle timer)
{
	g_esGeneral.g_hSurvivalTimer = null;
	g_esGeneral.g_iSurvivalBlock = 2;
}

public Action tTimerDevParticle(Handle timer, int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || !bIsDeveloper(iSurvivor, 0) || !g_esDeveloper[iSurvivor].g_bDevVisual || g_esDeveloper[iSurvivor].g_iDevParticle == 0 || g_esGeneral.g_bFinaleEnded)
	{
		g_esDeveloper[iSurvivor].g_bDevVisual = false;

		return Plugin_Stop;
	}

	vSetSurvivorEffects(iSurvivor, g_esDeveloper[iSurvivor].g_iDevParticle);

	return Plugin_Continue;
}

public Action tTimerElectricEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ELECTRICITY) || !g_esPlayer[iTank].g_bElectric)
	{
		g_esPlayer[iTank].g_bElectric = false;

		return Plugin_Stop;
	}

	switch (bIsValidClient(iTank, MT_CHECK_FAKECLIENT))
	{
		case true: vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, 30.0);
		case false:
		{
			for (int iCount = 1; iCount < 4; iCount++)
			{
				vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, (1.0 * float(iCount * 15)));
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerExecuteCustomConfig(Handle timer, DataPack pack)
{
	pack.Reset();

	char sSavePath[PLATFORM_MAX_PATH];
	pack.ReadString(sSavePath, sizeof sSavePath);
	if (sSavePath[0] != '\0')
	{
		vLoadConfigs(sSavePath, 2);
		vPluginStatus();
		vResetTimers();
		vToggleLogging();
	}

	return Plugin_Continue;
}

public Action tTimerFireEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_FIRE) || !g_esPlayer[iTank].g_bFire)
	{
		g_esPlayer[iTank].g_bFire = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_FIRE, 0.75);

	return Plugin_Continue;
}

public Action tTimerForceSpawnTank(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTank(iTank) || !bIsInfectedGhost(iTank))
	{
		return Plugin_Stop;
	}

	int iAbility = -1;
#if defined _l4dh_included
	switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKMaterializeGhost == null)
	{
		case true: iAbility = L4D_MaterializeFromGhost(iTank);
		case false:
		{
			SDKCall(g_esGeneral.g_hSDKMaterializeGhost, iTank);
			iAbility = GetEntPropEnt(iTank, Prop_Send, "m_customAbility");
		}
	}
#else
	if (g_esGeneral.g_hSDKMaterializeGhost != null)
	{
		SDKCall(g_esGeneral.g_hSDKMaterializeGhost, iTank);
		iAbility = GetEntPropEnt(iTank, Prop_Send, "m_customAbility");
	}
#endif
	switch (iAbility)
	{
		case -1: MT_PrintToChat(iTank, "%s %t", MT_TAG3, "SpawnManually");
		default: vTankSpawn(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerIceEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_ICE) || !g_esPlayer[iTank].g_bIce)
	{
		g_esPlayer[iTank].g_bIce = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_ICE, 2.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerKillIdleTank(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTank(iTank) || bIsTank(iTank, MT_CHECK_FAKECLIENT))
	{
		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank, g_esGeneral.g_iIdleCheckMode))
	{
		ForcePlayerSuicide(iTank);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerKillStuckTank(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTank(iTank) || !bIsPlayerIncapacitated(iTank))
	{
		return Plugin_Stop;
	}

	ForcePlayerSuicide(iTank);

	return Plugin_Continue;
}

public Action tTimerLoopVoiceline(Handle timer, int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_flVisualTime[2] == -1.0 || g_esPlayer[iSurvivor].g_flVisualTime[2] < GetGameTime() || g_esPlayer[iSurvivor].g_sLoopingVoiceline[0] == '\0' || g_esGeneral.g_bFinaleEnded)
	{
		g_esPlayer[iSurvivor].g_flVisualTime[2] = -1.0;
		g_esPlayer[iSurvivor].g_sLoopingVoiceline[0] = '\0';

		return Plugin_Stop;
	}

	if (!(g_esPlayer[iSurvivor].g_iRewardVisuals & MT_VISUAL_VOICELINE) || bHasIdlePlayer(iSurvivor) || bIsPlayerIdle(iSurvivor))
	{
		return Plugin_Continue;
	}

	vVocalize(iSurvivor, g_esPlayer[iSurvivor].g_sLoopingVoiceline);

	return Plugin_Continue;
}

public Action tTimerMeteorEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_METEOR) || !g_esPlayer[iTank].g_bMeteor)
	{
		g_esPlayer[iTank].g_bMeteor = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);

	return Plugin_Continue;
}

public Action tTimerParticleVisual(Handle timer, int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_flVisualTime[1] == -1.0 || g_esPlayer[iSurvivor].g_flVisualTime[1] < GetGameTime() || g_esPlayer[iSurvivor].g_iParticleEffect == 0 || g_esGeneral.g_bFinaleEnded)
	{
		g_esPlayer[iSurvivor].g_flVisualTime[1] = -1.0;
		g_esPlayer[iSurvivor].g_iParticleEffect = 0;

		return Plugin_Stop;
	}

	if ((bIsDeveloper(iSurvivor, 0) && g_esDeveloper[iSurvivor].g_bDevVisual && g_esDeveloper[iSurvivor].g_iDevParticle > 0) || !(g_esPlayer[iSurvivor].g_iRewardVisuals & MT_VISUAL_PARTICLE) || bHasIdlePlayer(iSurvivor) || bIsPlayerIdle(iSurvivor))
	{
		return Plugin_Continue;
	}

	vSetSurvivorEffects(iSurvivor, g_esPlayer[iSurvivor].g_iParticleEffect);

	return Plugin_Continue;
}

public Action tTimerRandomize(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !bIsCustomTankSupported(iTank) || !g_esPlayer[iTank].g_bRandomized || (flTime + g_esCache[iTank].g_flRandomDuration < GetEngineTime()))
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	int iType = iChooseTank(iTank, 2, .mutate = false);

	switch (iType)
	{
		case 0: return Plugin_Continue;
		default: vSetTankColor(iTank, iType);
	}

	vTankSpawn(iTank, 2);

	return Plugin_Continue;
}

public Action tTimerRefreshRewards(Handle timer)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			vEndRewards(iSurvivor, false);
		}
	}

	return Plugin_Continue;
}

public Action tTimerRegenerateAmmo(Handle timer)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	bool bDeveloper;
	char sWeapon[32];
	int iAmmo, iAmmoOffset, iMaxAmmo, iClip, iRegen, iSlot, iSpecialAmmo, iUpgrades;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (!bIsSurvivor(iSurvivor))
		{
			continue;
		}

		bDeveloper = bIsDeveloper(iSurvivor, 4) || bIsDeveloper(iSurvivor, 6);
		iRegen = (bDeveloper && g_esDeveloper[iSurvivor].g_iDevAmmoRegen > g_esPlayer[iSurvivor].g_iAmmoRegen) ? g_esDeveloper[iSurvivor].g_iDevAmmoRegen : g_esPlayer[iSurvivor].g_iAmmoRegen;
		if ((!bDeveloper && (!(g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_AMMO) || g_esPlayer[iSurvivor].g_flRewardTime[4] == -1.0)) || iRegen == 0)
		{
			continue;
		}

		iSlot = GetPlayerWeaponSlot(iSurvivor, 0);
		if (!bIsValidEntity(iSlot))
		{
			g_esPlayer[iSurvivor].g_iMaxClip[0] = 0;

			continue;
		}

		iClip = GetEntProp(iSlot, Prop_Send, "m_iClip1");
		if (iClip < g_esPlayer[iSurvivor].g_iMaxClip[0] && !GetEntProp(iSlot, Prop_Send, "m_bInReload"))
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", (iClip + iRegen));
		}

		if ((iClip + iRegen) > g_esPlayer[iSurvivor].g_iMaxClip[0])
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[iSurvivor].g_iMaxClip[0]);
		}

		if (g_bSecondGame)
		{
			iUpgrades = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");
			if ((iUpgrades & MT_UPGRADE_INCENDIARY) || (iUpgrades & MT_UPGRADE_EXPLOSIVE))
			{
				iSpecialAmmo = GetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
				if (iSpecialAmmo < g_esPlayer[iSurvivor].g_iMaxClip[0])
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", (iSpecialAmmo + iRegen));
				}

				if ((iSpecialAmmo + iRegen) > g_esPlayer[iSurvivor].g_iMaxClip[0])
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", g_esPlayer[iSurvivor].g_iMaxClip[0]);
				}
			}
		}

		iAmmoOffset = iGetWeaponOffset(iSlot), iAmmo = GetEntProp(iSurvivor, Prop_Send, "m_iAmmo", .element = iAmmoOffset), iMaxAmmo = iGetMaxAmmo(iSurvivor, 0, iSlot, true);
		if (iAmmo < iMaxAmmo)
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iAmmo", (iAmmo + iRegen), .element = iAmmoOffset);
		}

		if ((iAmmo + iRegen) > iMaxAmmo)
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iAmmo", iMaxAmmo, .element = iAmmoOffset);
		}

		iSlot = GetPlayerWeaponSlot(iSurvivor, 1);
		if (!bIsValidEntity(iSlot))
		{
			g_esPlayer[iSurvivor].g_iMaxClip[1] = 0;

			continue;
		}

		GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
		if (StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw"))
		{
			iClip = GetEntProp(iSlot, Prop_Send, "m_iClip1");
			if (iClip < g_esPlayer[iSurvivor].g_iMaxClip[1])
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", (iClip + iRegen));
			}

			if ((iClip + iRegen) > g_esPlayer[iSurvivor].g_iMaxClip[1])
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[iSurvivor].g_iMaxClip[1]);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerRegenerateHealth(Handle timer)
{
	if (!g_esGeneral.g_bPluginEnabled)
	{
		return Plugin_Continue;
	}

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		vLifeLeech(iSurvivor, .type = 7);
	}

	return Plugin_Continue;
}

public Action tTimerRegularWaves(Handle timer)
{
	if (!bCanTypeSpawn() || g_esGeneral.g_bFinalMap || g_esGeneral.g_iTankWave > 0 || (g_esGeneral.g_iRegularLimit > 0 && g_esGeneral.g_iRegularCount >= g_esGeneral.g_iRegularLimit))
	{
		g_esGeneral.g_hRegularWavesTimer = null;

		return Plugin_Stop;
	}

	int iCount = iGetTankCount(true);
	iCount = (iCount > 0) ? iCount : iGetTankCount(false);
	if (!g_esGeneral.g_bPluginEnabled || g_esGeneral.g_iRegularLimit == 0 || g_esGeneral.g_iRegularMode == 0 || g_esGeneral.g_iRegularWave == 0 || (g_esGeneral.g_iRegularAmount > 0 && iCount >= g_esGeneral.g_iRegularAmount))
	{
		return Plugin_Continue;
	}

	switch (g_esGeneral.g_iRegularAmount)
	{
		case 0: vRegularSpawn();
		default:
		{
			for (int iAmount = iCount; iAmount < g_esGeneral.g_iRegularAmount; iAmount++)
			{
				vRegularSpawn();
			}

			g_esGeneral.g_iRegularCount++;
		}
	}

	return Plugin_Continue;
}

public Action tTimerReloadConfigs(Handle timer)
{
	vCheckConfig(false);

	return Plugin_Continue;
}

public Action tTimerRemoveTimescale(Handle timer, int ref)
{
	int iTimescale = EntRefToEntIndex(ref);
	if (iTimescale == INVALID_ENT_REFERENCE || !bIsValidEntity(iTimescale))
	{
		return Plugin_Stop;
	}

	AcceptEntityInput(iTimescale, "Stop");
	RemoveEntity(iTimescale);

	return Plugin_Continue;
}

public Action tTimerResetAttackDelay(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankSupported(iTank))
	{
		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bAttackedAgain = false;

	return Plugin_Continue;
}

public Action tTimerResetType(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsValidClient(iTank))
	{
		vResetTank2(iTank);

		return Plugin_Stop;
	}

	vResetTank2(iTank);
	vCacheSettings(iTank);

	return Plugin_Continue;
}

public Action tTimerRockEffects(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (!g_esGeneral.g_bPluginEnabled || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock) || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || g_esCache[iTank].g_iRockEffects == 0)
	{
		return Plugin_Stop;
	}

	char sClassname[32];
	GetEntityClassname(iRock, sClassname, sizeof sClassname);
	if (!StrEqual(sClassname, "tank_rock"))
	{
		return Plugin_Stop;
	}

	if (g_esCache[iTank].g_iRockEffects & MT_ROCK_BLOOD)
	{
		vAttachParticle(iRock, PARTICLE_BLOOD, 0.75);
	}

	if (g_esCache[iTank].g_iRockEffects & MT_ROCK_ELECTRICITY)
	{
		vAttachParticle(iRock, PARTICLE_ELECTRICITY, 0.75);
	}

	if (g_esCache[iTank].g_iRockEffects & MT_ROCK_FIRE)
	{
		IgniteEntity(iRock, 120.0);
	}

	if (g_bSecondGame && (g_esCache[iTank].g_iRockEffects & MT_ROCK_SPIT))
	{
		EmitSoundToAll(SOUND_SPIT, iTank);
		vAttachParticle(iRock, PARTICLE_SPIT, 0.75);
	}

	return Plugin_Continue;
}

public Action tTimerScreenEffect(Handle timer, int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsSurvivor(iSurvivor) || g_esPlayer[iSurvivor].g_flVisualTime[0] == -1.0 || g_esPlayer[iSurvivor].g_flVisualTime[0] < GetGameTime() || g_esGeneral.g_bFinaleEnded)
	{
		g_esPlayer[iSurvivor].g_flVisualTime[0] = -1.0;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[0] = -1;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[1] = -1;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[2] = -1;
		g_esPlayer[iSurvivor].g_iScreenColorVisual[3] = -1;

		return Plugin_Stop;
	}

	if (!(g_esPlayer[iSurvivor].g_iRewardVisuals & MT_VISUAL_SCREEN) || bHasIdlePlayer(iSurvivor) || bIsPlayerIdle(iSurvivor) || bIsSurvivorHanging(iSurvivor) || bIsPlayerInThirdPerson(iSurvivor))
	{
		return Plugin_Continue;
	}
#if defined _ThirdPersonShoulder_Detect_included
	if (g_esPlayer[iSurvivor].g_bThirdPerson2)
	{
		return Plugin_Continue;
	}
#endif
	vEffect(iSurvivor, 0, MT_ATTACK_RANGE, MT_ATTACK_RANGE, g_esPlayer[iSurvivor].g_iScreenColorVisual[0], g_esPlayer[iSurvivor].g_iScreenColorVisual[1], g_esPlayer[iSurvivor].g_iScreenColorVisual[2], g_esPlayer[iSurvivor].g_iScreenColorVisual[3]);

	return Plugin_Continue;
}

public Action tTimerSmokeEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SMOKE) || !g_esPlayer[iTank].g_bSmoke)
	{
		g_esPlayer[iTank].g_bSmoke = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SMOKE, 1.5);

	return Plugin_Continue;
}

public Action tTimerSpitEffect(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !(g_esCache[iTank].g_iBodyEffects & MT_PARTICLE_SPIT) || !g_esPlayer[iTank].g_bSpit)
	{
		g_esPlayer[iTank].g_bSpit = false;

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SPIT, 2.0, 30.0);
	iCreateParticle(iTank, PARTICLE_SPIT2, NULL_VECTOR, NULL_VECTOR, 0.95, 2.0, "mouth");

	return Plugin_Continue;
}

public Action tTimerTankCountCheck(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()),
		iAmount = pack.ReadCell(),
		iCount = iGetTankCount(true),
		iCount2 = iGetTankCount(false);
	if (!bIsTank(iTank) || iAmount == 0 || iCount >= iAmount || iCount2 >= iAmount || (g_esGeneral.g_bNormalMap && g_esGeneral.g_iTankWave == 0 && g_esGeneral.g_iRegularMode == 1 && g_esGeneral.g_iRegularWave == 1))
	{
		return Plugin_Stop;
	}
	else if (iCount < iAmount && iCount2 < iAmount)
	{
		vRegularSpawn();
	}

	return Plugin_Continue;
}

public Action tTimerTankUpdate(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bIsCustomTankSupported(iTank) || bIsPlayerIncapacitated(iTank) || g_esGeneral.g_bFinaleEnded)
	{
		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	switch (g_esCache[iTank].g_iSpawnType)
	{
		case 1:
		{
			if (!g_esPlayer[iTank].g_bBoss)
			{
				vSpawnModes(iTank, true);

				DataPack dpBoss;
				CreateDataTimer(0.1, tTimerBoss, dpBoss, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpBoss.WriteCell(GetClientUserId(iTank));
				dpBoss.WriteCell(g_esCache[iTank].g_iBossStages);

				for (int iPos = 0; iPos < sizeof esCache::g_iBossHealth; iPos++)
				{
					dpBoss.WriteCell(g_esCache[iTank].g_iBossHealth[iPos]);
					dpBoss.WriteCell(g_esCache[iTank].g_iBossType[iPos]);
				}
			}
		}
		case 2:
		{
			if (!g_esPlayer[iTank].g_bRandomized)
			{
				vSpawnModes(iTank, true);

				DataPack dpRandom;
				CreateDataTimer(g_esCache[iTank].g_flRandomInterval, tTimerRandomize, dpRandom, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpRandom.WriteCell(GetClientUserId(iTank));
				dpRandom.WriteFloat(GetEngineTime());
			}
		}
		case 3:
		{
			if (!g_esPlayer[iTank].g_bTransformed)
			{
				vSpawnModes(iTank, true);
				CreateTimer(g_esCache[iTank].g_flTransformDelay, tTimerTransform, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);

				DataPack dpUntransform;
				CreateDataTimer((g_esCache[iTank].g_flTransformDuration + g_esCache[iTank].g_flTransformDelay), tTimerUntransform, dpUntransform, TIMER_FLAG_NO_MAPCHANGE);
				dpUntransform.WriteCell(GetClientUserId(iTank));
				dpUntransform.WriteCell(g_esPlayer[iTank].g_iTankType);
			}
		}
		case 4: vSpawnModes(iTank, true);
	}

	Call_StartForward(g_esGeneral.g_gfAbilityActivatedForward);
	Call_PushCell(iTank);
	Call_Finish();

	vCombineAbilitiesForward(iTank, MT_COMBO_MAINRANGE);

	return Plugin_Continue;
}

public Action tTimerTankWave(Handle timer)
{
	if (g_esGeneral.g_bNormalMap || iGetTankCount(true, true) > 0 || iGetTankCount(false, true) > 0 || !(0 < g_esGeneral.g_iTankWave < 10))
	{
		g_esGeneral.g_hTankWaveTimer = null;

		return Plugin_Stop;
	}

	g_esGeneral.g_hTankWaveTimer = null;
	g_esGeneral.g_iTankWave++;

	return Plugin_Continue;
}

public Action tTimerTransform(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_esGeneral.g_bPluginEnabled || !bIsTankSupported(iTank) || !bHasCoreAdminAccess(iTank) || g_esCache[iTank].g_iTankEnabled <= 0 || !bIsCustomTankSupported(iTank) || !g_esPlayer[iTank].g_bTransformed)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	int iPos = GetRandomInt(0, (sizeof esCache::g_iTransformType - 1));
	vSetTankColor(iTank, g_esCache[iTank].g_iTransformType[iPos]);
	vTankSpawn(iTank, 3);

	return Plugin_Continue;
}

public Action tTimerUntransform(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankSupported(iTank) || g_esCache[iTank].g_iTankEnabled <= 0)
	{
		vSpawnModes(iTank, false);

		return Plugin_Stop;
	}

	if (bIsTankIdle(iTank))
	{
		return Plugin_Continue;
	}

	int iTankType = pack.ReadCell();
	vSetTankColor(iTank, iTankType);
	vTankSpawn(iTank, 4);
	vSpawnModes(iTank, false);

	return Plugin_Continue;
}