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

public void OnClientPostAdminCheck(int client)
{
	if (bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		vLoadConfigs(g_esGeneral.g_sSavePath, 3);
	}

	GetClientAuthId(client, AuthId_Steam2, g_esPlayer[client].g_sSteamID32, sizeof esPlayer::g_sSteamID32);
	GetClientAuthId(client, AuthId_Steam3, g_esPlayer[client].g_sSteam3ID, sizeof esPlayer::g_sSteam3ID);
}

void vCacheSettings(int tank)
{
	bool bAccess = bIsTank(tank) && bHasCoreAdminAccess(tank), bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	int iType = g_esPlayer[tank].g_iTankType;

	g_esCache[tank].g_flAttackInterval = flGetSettingValue(bAccess, true, g_esTank[iType].g_flAttackInterval, g_esGeneral.g_flAttackInterval);
	g_esCache[tank].g_flAttackInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flAttackInterval, g_esCache[tank].g_flAttackInterval);
	g_esCache[tank].g_flBurnDuration = flGetSettingValue(bAccess, true, g_esTank[iType].g_flBurnDuration, g_esGeneral.g_flBurnDuration);
	g_esCache[tank].g_flBurnDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flBurnDuration, g_esCache[tank].g_flBurnDuration);
	g_esCache[tank].g_flBurntSkin = flGetSettingValue(bAccess, true, g_esTank[iType].g_flBurntSkin, g_esGeneral.g_flBurntSkin, 1);
	g_esCache[tank].g_flBurntSkin = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flBurntSkin, g_esCache[tank].g_flBurntSkin, 1);
	g_esCache[tank].g_flClawDamage = flGetSettingValue(bAccess, true, g_esTank[iType].g_flClawDamage, g_esGeneral.g_flClawDamage, 1);
	g_esCache[tank].g_flClawDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flClawDamage, g_esCache[tank].g_flClawDamage, 1);
	g_esCache[tank].g_flHittableDamage = flGetSettingValue(bAccess, true, g_esTank[iType].g_flHittableDamage, g_esGeneral.g_flHittableDamage, 1);
	g_esCache[tank].g_flHittableDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flHittableDamage, g_esCache[tank].g_flHittableDamage, 1);
	g_esCache[tank].g_flPunchForce = flGetSettingValue(bAccess, true, g_esTank[iType].g_flPunchForce, g_esGeneral.g_flPunchForce, 1);
	g_esCache[tank].g_flPunchForce = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPunchForce, g_esCache[tank].g_flPunchForce, 1);
	g_esCache[tank].g_flPunchThrow = flGetSettingValue(bAccess, true, g_esTank[iType].g_flPunchThrow, g_esGeneral.g_flPunchThrow);
	g_esCache[tank].g_flPunchThrow = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPunchThrow, g_esCache[tank].g_flPunchThrow);
	g_esCache[tank].g_flRandomDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRandomDuration, g_esTank[iType].g_flRandomDuration);
	g_esCache[tank].g_flRandomInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRandomInterval, g_esTank[iType].g_flRandomInterval);
	g_esCache[tank].g_flRockDamage = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRockDamage, g_esGeneral.g_flRockDamage, 1);
	g_esCache[tank].g_flRockDamage = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRockDamage, g_esCache[tank].g_flRockDamage, 1);
	g_esCache[tank].g_flRunSpeed = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRunSpeed, g_esGeneral.g_flRunSpeed);
	g_esCache[tank].g_flRunSpeed = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRunSpeed, g_esCache[tank].g_flRunSpeed);
	g_esCache[tank].g_flThrowInterval = flGetSettingValue(bAccess, true, g_esTank[iType].g_flThrowInterval, g_esGeneral.g_flThrowInterval);
	g_esCache[tank].g_flThrowInterval = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flThrowInterval, g_esCache[tank].g_flThrowInterval);
	g_esCache[tank].g_flTransformDelay = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flTransformDelay, g_esTank[iType].g_flTransformDelay);
	g_esCache[tank].g_flTransformDuration = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flTransformDuration, g_esTank[iType].g_flTransformDuration);
	g_esCache[tank].g_iAnnounceArrival = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceArrival, g_esGeneral.g_iAnnounceArrival);
	g_esCache[tank].g_iAnnounceArrival = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceArrival, g_esCache[tank].g_iAnnounceArrival);
	g_esCache[tank].g_iAnnounceDeath = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceDeath, g_esGeneral.g_iAnnounceDeath);
	g_esCache[tank].g_iAnnounceDeath = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceDeath, g_esCache[tank].g_iAnnounceDeath);
	g_esCache[tank].g_iAnnounceKill = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAnnounceKill, g_esGeneral.g_iAnnounceKill);
	g_esCache[tank].g_iAnnounceKill = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAnnounceKill, g_esCache[tank].g_iAnnounceKill);
	g_esCache[tank].g_iArrivalMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iArrivalMessage, g_esGeneral.g_iArrivalMessage);
	g_esCache[tank].g_iArrivalMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iArrivalMessage, g_esCache[tank].g_iArrivalMessage);
	g_esCache[tank].g_iArrivalSound = iGetSettingValue(bAccess, true, g_esTank[iType].g_iArrivalSound, g_esGeneral.g_iArrivalSound);
	g_esCache[tank].g_iArrivalSound = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iArrivalSound, g_esCache[tank].g_iArrivalSound);
	g_esCache[tank].g_iBaseHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iBaseHealth, g_esGeneral.g_iBaseHealth);
	g_esCache[tank].g_iBaseHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBaseHealth, g_esCache[tank].g_iBaseHealth);
	g_esCache[tank].g_iBodyEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBodyEffects, g_esTank[iType].g_iBodyEffects);
	g_esCache[tank].g_iBossStages = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossStages, g_esTank[iType].g_iBossStages);
	g_esCache[tank].g_iBulletImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iBulletImmunity, g_esGeneral.g_iBulletImmunity);
	g_esCache[tank].g_iBulletImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBulletImmunity, g_esCache[tank].g_iBulletImmunity);
	g_esCache[tank].g_iCheckAbilities = iGetSettingValue(bAccess, true, g_esTank[iType].g_iCheckAbilities, g_esGeneral.g_iCheckAbilities);
	g_esCache[tank].g_iCheckAbilities = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iCheckAbilities, g_esCache[tank].g_iCheckAbilities);
	g_esCache[tank].g_iDeathDetails = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathDetails, g_esGeneral.g_iDeathDetails);
	g_esCache[tank].g_iDeathDetails = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathDetails, g_esCache[tank].g_iDeathDetails);
	g_esCache[tank].g_iDeathMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathMessage, g_esGeneral.g_iDeathMessage);
	g_esCache[tank].g_iDeathMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathMessage, g_esCache[tank].g_iDeathMessage);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathRevert, g_esGeneral.g_iDeathRevert);
	g_esCache[tank].g_iDeathRevert = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathRevert, g_esCache[tank].g_iDeathRevert);
	g_esCache[tank].g_iDeathSound = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDeathSound, g_esGeneral.g_iDeathSound);
	g_esCache[tank].g_iDeathSound = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDeathSound, g_esCache[tank].g_iDeathSound);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealth, g_esGeneral.g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealth, g_esCache[tank].g_iDisplayHealth);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, true, g_esTank[iType].g_iDisplayHealthType, g_esGeneral.g_iDisplayHealthType);
	g_esCache[tank].g_iDisplayHealthType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iDisplayHealthType, g_esCache[tank].g_iDisplayHealthType);
	g_esCache[tank].g_iExplosiveImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iExplosiveImmunity, g_esGeneral.g_iExplosiveImmunity);
	g_esCache[tank].g_iExplosiveImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExplosiveImmunity, g_esCache[tank].g_iExplosiveImmunity);
	g_esCache[tank].g_iExtraHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iExtraHealth, g_esGeneral.g_iExtraHealth, 2);
	g_esCache[tank].g_iExtraHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iExtraHealth, g_esCache[tank].g_iExtraHealth, 2);
	g_esCache[tank].g_iFireImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iFireImmunity, g_esGeneral.g_iFireImmunity);
	g_esCache[tank].g_iFireImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFireImmunity, g_esCache[tank].g_iFireImmunity);
	g_esCache[tank].g_iGlowEnabled = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowEnabled, g_esTank[iType].g_iGlowEnabled);
	g_esCache[tank].g_iGlowFlashing = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowFlashing, g_esTank[iType].g_iGlowFlashing);
	g_esCache[tank].g_iGlowMaxRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMaxRange, g_esTank[iType].g_iGlowMaxRange);
	g_esCache[tank].g_iGlowMinRange = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowMinRange, g_esTank[iType].g_iGlowMinRange);
	g_esCache[tank].g_iGlowType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowType, g_esTank[iType].g_iGlowType);
	g_esCache[tank].g_iGroundPound = iGetSettingValue(bAccess, true, g_esTank[iType].g_iGroundPound, g_esGeneral.g_iGroundPound);
	g_esCache[tank].g_iGroundPound = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGroundPound, g_esCache[tank].g_iGroundPound);
	g_esCache[tank].g_iHittableImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iHittableImmunity, g_esGeneral.g_iHittableImmunity);
	g_esCache[tank].g_iHittableImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iHittableImmunity, g_esCache[tank].g_iHittableImmunity);
	g_esCache[tank].g_iKillMessage = iGetSettingValue(bAccess, true, g_esTank[iType].g_iKillMessage, g_esGeneral.g_iKillMessage);
	g_esCache[tank].g_iKillMessage = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iKillMessage, g_esCache[tank].g_iKillMessage);
	g_esCache[tank].g_iMeleeImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMeleeImmunity, g_esGeneral.g_iMeleeImmunity);
	g_esCache[tank].g_iMeleeImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMeleeImmunity, g_esCache[tank].g_iMeleeImmunity);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMinimumHumans, g_esGeneral.g_iMinimumHumans);
	g_esCache[tank].g_iMinimumHumans = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMinimumHumans, g_esCache[tank].g_iMinimumHumans);
	g_esCache[tank].g_iMultiplyHealth = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMultiplyHealth, g_esGeneral.g_iMultiplyHealth);
	g_esCache[tank].g_iMultiplyHealth = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMultiplyHealth, g_esCache[tank].g_iMultiplyHealth);
	g_esCache[tank].g_iPropsAttached = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPropsAttached, g_esTank[iType].g_iPropsAttached);
	g_esCache[tank].g_iRandomTank = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRandomTank, g_esTank[iType].g_iRandomTank);
	g_esCache[tank].g_iRockEffects = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockEffects, g_esTank[iType].g_iRockEffects);
	g_esCache[tank].g_iRockModel = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockModel, g_esTank[iType].g_iRockModel);
	g_esCache[tank].g_iSkipIncap = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSkipIncap, g_esGeneral.g_iSkipIncap);
	g_esCache[tank].g_iSkipIncap = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSkipIncap, g_esCache[tank].g_iSkipIncap);
	g_esCache[tank].g_iSkipTaunt = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSkipTaunt, g_esGeneral.g_iSkipTaunt);
	g_esCache[tank].g_iSkipTaunt = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSkipTaunt, g_esCache[tank].g_iSkipTaunt);
	g_esCache[tank].g_iSpawnType = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSpawnType, g_esTank[iType].g_iSpawnType);
	g_esCache[tank].g_iSweepFist = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSweepFist, g_esGeneral.g_iSweepFist);
	g_esCache[tank].g_iSweepFist = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSweepFist, g_esCache[tank].g_iSweepFist);
	g_esCache[tank].g_iTankEnabled = iGetSettingValue(bAccess, true, g_esTank[iType].g_iTankEnabled, g_esGeneral.g_iTankEnabled, 1);
	g_esCache[tank].g_iTankModel = iGetSettingValue(bAccess, true, g_esTank[iType].g_iTankModel, g_esGeneral.g_iTankModel);
	g_esCache[tank].g_iTankModel = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTankModel, g_esCache[tank].g_iTankModel);
	g_esCache[tank].g_iTankNote = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTankNote, g_esTank[iType].g_iTankNote);
	g_esCache[tank].g_iTeammateLimit = iGetSettingValue(bAccess, true, g_esTank[iType].g_iTeammateLimit, g_esGeneral.g_iTeammateLimit);
	g_esCache[tank].g_iTeammateLimit = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTeammateLimit, g_esCache[tank].g_iTeammateLimit);
	g_esCache[tank].g_iVocalizeArrival = iGetSettingValue(bAccess, true, g_esTank[iType].g_iVocalizeArrival, g_esGeneral.g_iVocalizeArrival);
	g_esCache[tank].g_iVocalizeArrival = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iVocalizeArrival, g_esCache[tank].g_iVocalizeArrival);
	g_esCache[tank].g_iVocalizeDeath = iGetSettingValue(bAccess, true, g_esTank[iType].g_iVocalizeDeath, g_esGeneral.g_iVocalizeDeath);
	g_esCache[tank].g_iVocalizeDeath = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iVocalizeDeath, g_esCache[tank].g_iVocalizeDeath);
	g_esCache[tank].g_iVomitImmunity = iGetSettingValue(bAccess, true, g_esTank[iType].g_iVomitImmunity, g_esGeneral.g_iVomitImmunity);
	g_esCache[tank].g_iVomitImmunity = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iVomitImmunity, g_esCache[tank].g_iVomitImmunity);

	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual, sizeof esCache::g_sBodyColorVisual, g_esTank[iType].g_sBodyColorVisual, g_esGeneral.g_sBodyColorVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual, sizeof esCache::g_sBodyColorVisual, g_esPlayer[tank].g_sBodyColorVisual, g_esCache[tank].g_sBodyColorVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual2, sizeof esCache::g_sBodyColorVisual2, g_esTank[iType].g_sBodyColorVisual2, g_esGeneral.g_sBodyColorVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual2, sizeof esCache::g_sBodyColorVisual2, g_esPlayer[tank].g_sBodyColorVisual2, g_esCache[tank].g_sBodyColorVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual3, sizeof esCache::g_sBodyColorVisual3, g_esTank[iType].g_sBodyColorVisual3, g_esGeneral.g_sBodyColorVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual3, sizeof esCache::g_sBodyColorVisual3, g_esPlayer[tank].g_sBodyColorVisual3, g_esCache[tank].g_sBodyColorVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sBodyColorVisual4, sizeof esCache::g_sBodyColorVisual4, g_esTank[iType].g_sBodyColorVisual4, g_esGeneral.g_sBodyColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sBodyColorVisual4, sizeof esCache::g_sBodyColorVisual4, g_esPlayer[tank].g_sBodyColorVisual4, g_esCache[tank].g_sBodyColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sComboSet, sizeof esCache::g_sComboSet, g_esPlayer[tank].g_sComboSet, g_esTank[iType].g_sComboSet);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward, sizeof esCache::g_sFallVoicelineReward, g_esTank[iType].g_sFallVoicelineReward, g_esGeneral.g_sFallVoicelineReward);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward, sizeof esCache::g_sFallVoicelineReward, g_esPlayer[tank].g_sFallVoicelineReward, g_esCache[tank].g_sFallVoicelineReward);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward2, sizeof esCache::g_sFallVoicelineReward2, g_esTank[iType].g_sFallVoicelineReward2, g_esGeneral.g_sFallVoicelineReward2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward2, sizeof esCache::g_sFallVoicelineReward2, g_esPlayer[tank].g_sFallVoicelineReward2, g_esCache[tank].g_sFallVoicelineReward2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward3, sizeof esCache::g_sFallVoicelineReward3, g_esTank[iType].g_sFallVoicelineReward3, g_esGeneral.g_sFallVoicelineReward3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward3, sizeof esCache::g_sFallVoicelineReward3, g_esPlayer[tank].g_sFallVoicelineReward3, g_esCache[tank].g_sFallVoicelineReward3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sFallVoicelineReward4, sizeof esCache::g_sFallVoicelineReward4, g_esTank[iType].g_sFallVoicelineReward4, g_esGeneral.g_sFallVoicelineReward4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFallVoicelineReward4, sizeof esCache::g_sFallVoicelineReward4, g_esPlayer[tank].g_sFallVoicelineReward4, g_esCache[tank].g_sFallVoicelineReward4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFlameColor, sizeof esCache::g_sFlameColor, g_esPlayer[tank].g_sFlameColor, g_esTank[iType].g_sFlameColor);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sFlashlightColor, sizeof esCache::g_sFlashlightColor, g_esPlayer[tank].g_sFlashlightColor, g_esTank[iType].g_sFlashlightColor);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sGlowColor, sizeof esCache::g_sGlowColor, g_esPlayer[tank].g_sGlowColor, g_esTank[iType].g_sGlowColor);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sHealthCharacters, sizeof esCache::g_sHealthCharacters, g_esTank[iType].g_sHealthCharacters, g_esGeneral.g_sHealthCharacters);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sHealthCharacters, sizeof esCache::g_sHealthCharacters, g_esPlayer[tank].g_sHealthCharacters, g_esCache[tank].g_sHealthCharacters);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward, sizeof esCache::g_sItemReward, g_esTank[iType].g_sItemReward, g_esGeneral.g_sItemReward);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward, sizeof esCache::g_sItemReward, g_esPlayer[tank].g_sItemReward, g_esCache[tank].g_sItemReward);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward2, sizeof esCache::g_sItemReward2, g_esTank[iType].g_sItemReward2, g_esGeneral.g_sItemReward2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward2, sizeof esCache::g_sItemReward2, g_esPlayer[tank].g_sItemReward2, g_esCache[tank].g_sItemReward2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward3, sizeof esCache::g_sItemReward3, g_esTank[iType].g_sItemReward3, g_esGeneral.g_sItemReward3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward3, sizeof esCache::g_sItemReward3, g_esPlayer[tank].g_sItemReward3, g_esCache[tank].g_sItemReward3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sItemReward4, sizeof esCache::g_sItemReward4, g_esTank[iType].g_sItemReward4, g_esGeneral.g_sItemReward4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sItemReward4, sizeof esCache::g_sItemReward4, g_esPlayer[tank].g_sItemReward4, g_esCache[tank].g_sItemReward4);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLightColorVisual, sizeof esCache::g_sLightColorVisual, g_esTank[iType].g_sLightColorVisual, g_esGeneral.g_sLightColorVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLightColorVisual, sizeof esCache::g_sLightColorVisual, g_esPlayer[tank].g_sLightColorVisual, g_esCache[tank].g_sLightColorVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLightColorVisual2, sizeof esCache::g_sLightColorVisual2, g_esTank[iType].g_sLightColorVisual2, g_esGeneral.g_sLightColorVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLightColorVisual2, sizeof esCache::g_sLightColorVisual2, g_esPlayer[tank].g_sLightColorVisual2, g_esCache[tank].g_sLightColorVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLightColorVisual3, sizeof esCache::g_sLightColorVisual3, g_esTank[iType].g_sLightColorVisual3, g_esGeneral.g_sLightColorVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLightColorVisual3, sizeof esCache::g_sLightColorVisual3, g_esPlayer[tank].g_sLightColorVisual3, g_esCache[tank].g_sLightColorVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLightColorVisual4, sizeof esCache::g_sLightColorVisual4, g_esTank[iType].g_sLightColorVisual4, g_esGeneral.g_sLightColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLightColorVisual4, sizeof esCache::g_sLightColorVisual4, g_esPlayer[tank].g_sLightColorVisual4, g_esCache[tank].g_sLightColorVisual4);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual, sizeof esCache::g_sLoopingVoicelineVisual, g_esTank[iType].g_sLoopingVoicelineVisual, g_esGeneral.g_sLoopingVoicelineVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual, sizeof esCache::g_sLoopingVoicelineVisual, g_esPlayer[tank].g_sLoopingVoicelineVisual, g_esCache[tank].g_sLoopingVoicelineVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual2, sizeof esCache::g_sLoopingVoicelineVisual2, g_esTank[iType].g_sLoopingVoicelineVisual2, g_esGeneral.g_sLoopingVoicelineVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual2, sizeof esCache::g_sLoopingVoicelineVisual2, g_esPlayer[tank].g_sLoopingVoicelineVisual2, g_esCache[tank].g_sLoopingVoicelineVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual3, sizeof esCache::g_sLoopingVoicelineVisual3, g_esTank[iType].g_sLoopingVoicelineVisual3, g_esGeneral.g_sLoopingVoicelineVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual3, sizeof esCache::g_sLoopingVoicelineVisual3, g_esPlayer[tank].g_sLoopingVoicelineVisual3, g_esCache[tank].g_sLoopingVoicelineVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sLoopingVoicelineVisual4, sizeof esCache::g_sLoopingVoicelineVisual4, g_esTank[iType].g_sLoopingVoicelineVisual4, g_esGeneral.g_sLoopingVoicelineVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sLoopingVoicelineVisual4, sizeof esCache::g_sLoopingVoicelineVisual4, g_esPlayer[tank].g_sLoopingVoicelineVisual4, g_esCache[tank].g_sLoopingVoicelineVisual4);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sOutlineColorVisual, sizeof esCache::g_sOutlineColorVisual, g_esTank[iType].g_sOutlineColorVisual, g_esGeneral.g_sOutlineColorVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sOutlineColorVisual, sizeof esCache::g_sOutlineColorVisual, g_esPlayer[tank].g_sOutlineColorVisual, g_esCache[tank].g_sOutlineColorVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sOutlineColorVisual2, sizeof esCache::g_sOutlineColorVisual2, g_esTank[iType].g_sOutlineColorVisual2, g_esGeneral.g_sOutlineColorVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sOutlineColorVisual2, sizeof esCache::g_sOutlineColorVisual2, g_esPlayer[tank].g_sOutlineColorVisual2, g_esCache[tank].g_sOutlineColorVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sOutlineColorVisual3, sizeof esCache::g_sOutlineColorVisual3, g_esTank[iType].g_sOutlineColorVisual3, g_esGeneral.g_sOutlineColorVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sOutlineColorVisual3, sizeof esCache::g_sOutlineColorVisual3, g_esPlayer[tank].g_sOutlineColorVisual3, g_esCache[tank].g_sOutlineColorVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sOutlineColorVisual4, sizeof esCache::g_sOutlineColorVisual4, g_esTank[iType].g_sOutlineColorVisual4, g_esGeneral.g_sOutlineColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sOutlineColorVisual4, sizeof esCache::g_sOutlineColorVisual4, g_esPlayer[tank].g_sOutlineColorVisual4, g_esCache[tank].g_sOutlineColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sOzTankColor, sizeof esCache::g_sOzTankColor, g_esPlayer[tank].g_sOzTankColor, g_esTank[iType].g_sOzTankColor);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sPropTankColor, sizeof esCache::g_sPropTankColor, g_esPlayer[tank].g_sPropTankColor, g_esTank[iType].g_sPropTankColor);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sRockColor, sizeof esCache::g_sRockColor, g_esPlayer[tank].g_sRockColor, g_esTank[iType].g_sRockColor);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual, sizeof esCache::g_sScreenColorVisual, g_esTank[iType].g_sScreenColorVisual, g_esGeneral.g_sScreenColorVisual);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual, sizeof esCache::g_sScreenColorVisual, g_esPlayer[tank].g_sScreenColorVisual, g_esCache[tank].g_sScreenColorVisual);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual2, sizeof esCache::g_sScreenColorVisual2, g_esTank[iType].g_sScreenColorVisual2, g_esGeneral.g_sScreenColorVisual2);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual2, sizeof esCache::g_sScreenColorVisual2, g_esPlayer[tank].g_sScreenColorVisual2, g_esCache[tank].g_sScreenColorVisual2);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual3, sizeof esCache::g_sScreenColorVisual3, g_esTank[iType].g_sScreenColorVisual3, g_esGeneral.g_sScreenColorVisual3);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual3, sizeof esCache::g_sScreenColorVisual3, g_esPlayer[tank].g_sScreenColorVisual3, g_esCache[tank].g_sScreenColorVisual3);
	vGetSettingValue(bAccess, true, g_esCache[tank].g_sScreenColorVisual4, sizeof esCache::g_sScreenColorVisual4, g_esTank[iType].g_sScreenColorVisual4, g_esGeneral.g_sScreenColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sScreenColorVisual4, sizeof esCache::g_sScreenColorVisual4, g_esPlayer[tank].g_sScreenColorVisual4, g_esCache[tank].g_sScreenColorVisual4);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sSkinColor, sizeof esCache::g_sSkinColor, g_esPlayer[tank].g_sSkinColor, g_esTank[iType].g_sSkinColor);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sTankName, sizeof esCache::g_sTankName, g_esPlayer[tank].g_sTankName, g_esTank[iType].g_sTankName);
	vGetSettingValue(bAccess, bHuman, g_esCache[tank].g_sTireColor, sizeof esCache::g_sTireColor, g_esPlayer[tank].g_sTireColor, g_esTank[iType].g_sTireColor);

	for (int iPos = 0; iPos < sizeof esCache::g_iTransformType; iPos++)
	{
		g_esCache[tank].g_iTransformType[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTransformType[iPos], g_esTank[iType].g_iTransformType[iPos]);

		if (iPos < sizeof esCache::g_iRewardEnabled)
		{
			g_esCache[tank].g_flActionDurationReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flActionDurationReward[iPos], g_esGeneral.g_flActionDurationReward[iPos]);
			g_esCache[tank].g_flActionDurationReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flActionDurationReward[iPos], g_esCache[tank].g_flActionDurationReward[iPos]);
			g_esCache[tank].g_iAmmoBoostReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAmmoBoostReward[iPos], g_esGeneral.g_iAmmoBoostReward[iPos]);
			g_esCache[tank].g_iAmmoBoostReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAmmoBoostReward[iPos], g_esCache[tank].g_iAmmoBoostReward[iPos]);
			g_esCache[tank].g_iAmmoRegenReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iAmmoRegenReward[iPos], g_esGeneral.g_iAmmoRegenReward[iPos]);
			g_esCache[tank].g_iAmmoRegenReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iAmmoRegenReward[iPos], g_esCache[tank].g_iAmmoRegenReward[iPos]);
			g_esCache[tank].g_flAttackBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flAttackBoostReward[iPos], g_esGeneral.g_flAttackBoostReward[iPos]);
			g_esCache[tank].g_flAttackBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flAttackBoostReward[iPos], g_esCache[tank].g_flAttackBoostReward[iPos]);
			g_esCache[tank].g_iCleanKillsReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iCleanKillsReward[iPos], g_esGeneral.g_iCleanKillsReward[iPos]);
			g_esCache[tank].g_iCleanKillsReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iCleanKillsReward[iPos], g_esCache[tank].g_iCleanKillsReward[iPos]);
			g_esCache[tank].g_flDamageBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flDamageBoostReward[iPos], g_esGeneral.g_flDamageBoostReward[iPos]);
			g_esCache[tank].g_flDamageBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flDamageBoostReward[iPos], g_esCache[tank].g_flDamageBoostReward[iPos]);
			g_esCache[tank].g_flDamageResistanceReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flDamageResistanceReward[iPos], g_esGeneral.g_flDamageResistanceReward[iPos]);
			g_esCache[tank].g_flDamageResistanceReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flDamageResistanceReward[iPos], g_esCache[tank].g_flDamageResistanceReward[iPos]);
			g_esCache[tank].g_flHealPercentReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flHealPercentReward[iPos], g_esGeneral.g_flHealPercentReward[iPos]);
			g_esCache[tank].g_flHealPercentReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flHealPercentReward[iPos], g_esCache[tank].g_flHealPercentReward[iPos]);
			g_esCache[tank].g_iHealthRegenReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iHealthRegenReward[iPos], g_esGeneral.g_iHealthRegenReward[iPos]);
			g_esCache[tank].g_iHealthRegenReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iHealthRegenReward[iPos], g_esCache[tank].g_iHealthRegenReward[iPos]);
			g_esCache[tank].g_iHollowpointAmmoReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iHollowpointAmmoReward[iPos], g_esGeneral.g_iHollowpointAmmoReward[iPos]);
			g_esCache[tank].g_iHollowpointAmmoReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iHollowpointAmmoReward[iPos], g_esCache[tank].g_iHollowpointAmmoReward[iPos]);
			g_esCache[tank].g_flJumpHeightReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flJumpHeightReward[iPos], g_esGeneral.g_flJumpHeightReward[iPos]);
			g_esCache[tank].g_flJumpHeightReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flJumpHeightReward[iPos], g_esCache[tank].g_flJumpHeightReward[iPos]);
			g_esCache[tank].g_iInfiniteAmmoReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iInfiniteAmmoReward[iPos], g_esGeneral.g_iInfiniteAmmoReward[iPos]);
			g_esCache[tank].g_iInfiniteAmmoReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iInfiniteAmmoReward[iPos], g_esCache[tank].g_iInfiniteAmmoReward[iPos]);
			g_esCache[tank].g_iLadderActionsReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iLadderActionsReward[iPos], g_esGeneral.g_iLadderActionsReward[iPos]);
			g_esCache[tank].g_iLadderActionsReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLadderActionsReward[iPos], g_esCache[tank].g_iLadderActionsReward[iPos]);
			g_esCache[tank].g_iLadyKillerReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iLadyKillerReward[iPos], g_esGeneral.g_iLadyKillerReward[iPos]);
			g_esCache[tank].g_iLadyKillerReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLadyKillerReward[iPos], g_esCache[tank].g_iLadyKillerReward[iPos]);
			g_esCache[tank].g_iLifeLeechReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iLifeLeechReward[iPos], g_esGeneral.g_iLifeLeechReward[iPos]);
			g_esCache[tank].g_iLifeLeechReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLifeLeechReward[iPos], g_esCache[tank].g_iLifeLeechReward[iPos]);
			g_esCache[tank].g_iMeleeRangeReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iMeleeRangeReward[iPos], g_esGeneral.g_iMeleeRangeReward[iPos]);
			g_esCache[tank].g_iMeleeRangeReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iMeleeRangeReward[iPos], g_esCache[tank].g_iMeleeRangeReward[iPos]);
			g_esCache[tank].g_iParticleEffectVisual[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iParticleEffectVisual[iPos], g_esGeneral.g_iParticleEffectVisual[iPos]);
			g_esCache[tank].g_iParticleEffectVisual[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iParticleEffectVisual[iPos], g_esCache[tank].g_iParticleEffectVisual[iPos]);
			g_esCache[tank].g_iPrefsNotify[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iPrefsNotify[iPos], g_esGeneral.g_iPrefsNotify[iPos]);
			g_esCache[tank].g_iPrefsNotify[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPrefsNotify[iPos], g_esCache[tank].g_iPrefsNotify[iPos]);
			g_esCache[tank].g_flPunchResistanceReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flPunchResistanceReward[iPos], g_esGeneral.g_flPunchResistanceReward[iPos]);
			g_esCache[tank].g_flPunchResistanceReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPunchResistanceReward[iPos], g_esCache[tank].g_flPunchResistanceReward[iPos]);
			g_esCache[tank].g_iRespawnLoadoutReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRespawnLoadoutReward[iPos], g_esGeneral.g_iRespawnLoadoutReward[iPos]);
			g_esCache[tank].g_iRespawnLoadoutReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRespawnLoadoutReward[iPos], g_esCache[tank].g_iRespawnLoadoutReward[iPos]);
			g_esCache[tank].g_iReviveHealthReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iReviveHealthReward[iPos], g_esGeneral.g_iReviveHealthReward[iPos]);
			g_esCache[tank].g_iReviveHealthReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iReviveHealthReward[iPos], g_esCache[tank].g_iReviveHealthReward[iPos]);
			g_esCache[tank].g_iRewardBots[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardBots[iPos], g_esGeneral.g_iRewardBots[iPos], 1);
			g_esCache[tank].g_iRewardBots[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardBots[iPos], g_esCache[tank].g_iRewardBots[iPos], 1);
			g_esCache[tank].g_flRewardChance[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardChance[iPos], g_esGeneral.g_flRewardChance[iPos]);
			g_esCache[tank].g_flRewardChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardChance[iPos], g_esCache[tank].g_flRewardChance[iPos]);
			g_esCache[tank].g_flRewardDuration[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardDuration[iPos], g_esGeneral.g_flRewardDuration[iPos]);
			g_esCache[tank].g_flRewardDuration[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardDuration[iPos], g_esCache[tank].g_flRewardDuration[iPos]);
			g_esCache[tank].g_iRewardEffect[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardEffect[iPos], g_esGeneral.g_iRewardEffect[iPos]);
			g_esCache[tank].g_iRewardEffect[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardEffect[iPos], g_esCache[tank].g_iRewardEffect[iPos]);
			g_esCache[tank].g_iRewardEnabled[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardEnabled[iPos], g_esGeneral.g_iRewardEnabled[iPos], 1);
			g_esCache[tank].g_iRewardEnabled[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardEnabled[iPos], g_esCache[tank].g_iRewardEnabled[iPos], 1);
			g_esCache[tank].g_iRewardNotify[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardNotify[iPos], g_esGeneral.g_iRewardNotify[iPos]);
			g_esCache[tank].g_iRewardNotify[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardNotify[iPos], g_esCache[tank].g_iRewardNotify[iPos]);
			g_esCache[tank].g_flRewardPercentage[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flRewardPercentage[iPos], g_esGeneral.g_flRewardPercentage[iPos]);
			g_esCache[tank].g_flRewardPercentage[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flRewardPercentage[iPos], g_esCache[tank].g_flRewardPercentage[iPos]);
			g_esCache[tank].g_iRewardVisual[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iRewardVisual[iPos], g_esGeneral.g_iRewardVisual[iPos]);
			g_esCache[tank].g_iRewardVisual[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRewardVisual[iPos], g_esCache[tank].g_iRewardVisual[iPos]);
			g_esCache[tank].g_iShareRewards[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iShareRewards[iPos], g_esGeneral.g_iShareRewards[iPos]);
			g_esCache[tank].g_iShareRewards[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iShareRewards[iPos], g_esCache[tank].g_iShareRewards[iPos]);
			g_esCache[tank].g_flShoveDamageReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flShoveDamageReward[iPos], g_esGeneral.g_flShoveDamageReward[iPos]);
			g_esCache[tank].g_flShoveDamageReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flShoveDamageReward[iPos], g_esCache[tank].g_flShoveDamageReward[iPos]);
			g_esCache[tank].g_iShovePenaltyReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iShovePenaltyReward[iPos], g_esGeneral.g_iShovePenaltyReward[iPos]);
			g_esCache[tank].g_iShovePenaltyReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iShovePenaltyReward[iPos], g_esCache[tank].g_iShovePenaltyReward[iPos]);
			g_esCache[tank].g_flShoveRateReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flShoveRateReward[iPos], g_esGeneral.g_flShoveRateReward[iPos]);
			g_esCache[tank].g_flShoveRateReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flShoveRateReward[iPos], g_esCache[tank].g_flShoveRateReward[iPos]);
			g_esCache[tank].g_iSledgehammerRoundsReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSledgehammerRoundsReward[iPos], g_esGeneral.g_iSledgehammerRoundsReward[iPos]);
			g_esCache[tank].g_iSledgehammerRoundsReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSledgehammerRoundsReward[iPos], g_esCache[tank].g_iSledgehammerRoundsReward[iPos]);
			g_esCache[tank].g_iSpecialAmmoReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iSpecialAmmoReward[iPos], g_esGeneral.g_iSpecialAmmoReward[iPos]);
			g_esCache[tank].g_iSpecialAmmoReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSpecialAmmoReward[iPos], g_esCache[tank].g_iSpecialAmmoReward[iPos]);
			g_esCache[tank].g_flSpeedBoostReward[iPos] = flGetSettingValue(bAccess, true, g_esTank[iType].g_flSpeedBoostReward[iPos], g_esGeneral.g_flSpeedBoostReward[iPos]);
			g_esCache[tank].g_flSpeedBoostReward[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flSpeedBoostReward[iPos], g_esCache[tank].g_flSpeedBoostReward[iPos]);
			g_esCache[tank].g_iStackRewards[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iStackRewards[iPos], g_esGeneral.g_iStackRewards[iPos]);
			g_esCache[tank].g_iStackRewards[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iStackRewards[iPos], g_esCache[tank].g_iStackRewards[iPos]);
			g_esCache[tank].g_iThornsReward[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iThornsReward[iPos], g_esGeneral.g_iThornsReward[iPos]);
			g_esCache[tank].g_iThornsReward[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iThornsReward[iPos], g_esCache[tank].g_iThornsReward[iPos]);
			g_esCache[tank].g_iUsefulRewards[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iUsefulRewards[iPos], g_esGeneral.g_iUsefulRewards[iPos]);
			g_esCache[tank].g_iUsefulRewards[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iUsefulRewards[iPos], g_esCache[tank].g_iUsefulRewards[iPos]);
		}

		if (iPos < sizeof esCache::g_iStackLimits)
		{
			g_esCache[tank].g_iStackLimits[iPos] = iGetSettingValue(bAccess, true, g_esTank[iType].g_iStackLimits[iPos], g_esGeneral.g_iStackLimits[iPos]);
			g_esCache[tank].g_iStackLimits[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iStackLimits[iPos], g_esCache[tank].g_iStackLimits[iPos]);
		}

		if (iPos < sizeof esCache::g_flComboChance)
		{
			g_esCache[tank].g_flComboChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboChance[iPos], g_esTank[iType].g_flComboChance[iPos]);
			g_esCache[tank].g_flComboDamage[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDamage[iPos], g_esTank[iType].g_flComboDamage[iPos]);
			g_esCache[tank].g_flComboDeathChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDeathChance[iPos], g_esTank[iType].g_flComboDeathChance[iPos]);
			g_esCache[tank].g_flComboDeathRange[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDeathRange[iPos], g_esTank[iType].g_flComboDeathRange[iPos]);
			g_esCache[tank].g_flComboDelay[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDelay[iPos], g_esTank[iType].g_flComboDelay[iPos]);
			g_esCache[tank].g_flComboDuration[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboDuration[iPos], g_esTank[iType].g_flComboDuration[iPos]);
			g_esCache[tank].g_flComboInterval[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboInterval[iPos], g_esTank[iType].g_flComboInterval[iPos]);
			g_esCache[tank].g_flComboMinRadius[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboMinRadius[iPos], g_esTank[iType].g_flComboMinRadius[iPos]);
			g_esCache[tank].g_flComboMaxRadius[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboMaxRadius[iPos], g_esTank[iType].g_flComboMaxRadius[iPos]);
			g_esCache[tank].g_flComboRange[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboRange[iPos], g_esTank[iType].g_flComboRange[iPos]);
			g_esCache[tank].g_flComboRangeChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboRangeChance[iPos], g_esTank[iType].g_flComboRangeChance[iPos]);
			g_esCache[tank].g_flComboRockChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboRockChance[iPos], g_esTank[iType].g_flComboRockChance[iPos]);
			g_esCache[tank].g_flComboSpeed[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboSpeed[iPos], g_esTank[iType].g_flComboSpeed[iPos]);
		}

		if (iPos < sizeof esCache::g_flComboTypeChance)
		{
			g_esCache[tank].g_flComboTypeChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flComboTypeChance[iPos], g_esTank[iType].g_flComboTypeChance[iPos]);
		}

		if (iPos < sizeof esCache::g_flPropsChance)
		{
			g_esCache[tank].g_flPropsChance[iPos] = flGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_flPropsChance[iPos], g_esTank[iType].g_flPropsChance[iPos]);
		}

		if (iPos < sizeof esCache::g_iSkinColor)
		{
			g_esCache[tank].g_iSkinColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iSkinColor[iPos], g_esTank[iType].g_iSkinColor[iPos], 1);
			g_esCache[tank].g_iBossHealth[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossHealth[iPos], g_esTank[iType].g_iBossHealth[iPos]);
			g_esCache[tank].g_iBossType[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iBossType[iPos], g_esTank[iType].g_iBossType[iPos]);
			g_esCache[tank].g_iLightColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iLightColor[iPos], g_esTank[iType].g_iLightColor[iPos], 1);
			g_esCache[tank].g_iOzTankColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iOzTankColor[iPos], g_esTank[iType].g_iOzTankColor[iPos], 1);
			g_esCache[tank].g_iFlameColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFlameColor[iPos], g_esTank[iType].g_iFlameColor[iPos], 1);
			g_esCache[tank].g_iRockColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iRockColor[iPos], g_esTank[iType].g_iRockColor[iPos], 1);
			g_esCache[tank].g_iTireColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iTireColor[iPos], g_esTank[iType].g_iTireColor[iPos], 1);
			g_esCache[tank].g_iPropTankColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iPropTankColor[iPos], g_esTank[iType].g_iPropTankColor[iPos], 1);
			g_esCache[tank].g_iFlashlightColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iFlashlightColor[iPos], g_esTank[iType].g_iFlashlightColor[iPos], 1);
			g_esCache[tank].g_iCrownColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iCrownColor[iPos], g_esTank[iType].g_iCrownColor[iPos], 1);
		}

		if (iPos < sizeof esCache::g_iGlowColor)
		{
			g_esCache[tank].g_iGlowColor[iPos] = iGetSettingValue(bAccess, bHuman, g_esPlayer[tank].g_iGlowColor[iPos], g_esTank[iType].g_iGlowColor[iPos], 1);
		}
	}

	Call_StartForward(g_esGeneral.g_gfSettingsCachedForward);
	Call_PushCell(tank);
	Call_PushCell(bAccess);
	Call_PushCell(iType);
	Call_Finish();
}

void vCheckConfig(bool manual)
{
	if (FileExists(g_esGeneral.g_sSavePath, true))
	{
		g_esGeneral.g_iFileTimeNew[0] = GetFileTime(g_esGeneral.g_sSavePath, FileTime_LastChange);
		if (g_esGeneral.g_iFileTimeOld[0] != g_esGeneral.g_iFileTimeNew[0] || manual)
		{
			vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, g_esGeneral.g_sSavePath);
			vLoadConfigs(g_esGeneral.g_sSavePath, 1);
			vPluginStatus();
			vResetTimers();
			vToggleLogging();
			g_esGeneral.g_iFileTimeOld[0] = g_esGeneral.g_iFileTimeNew[0];
		}
	}

	if (g_esGeneral.g_iConfigEnable == 1)
	{
		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_cvMTDifficulty != null)
		{
			char sDifficultyConfig[PLATFORM_MAX_PATH];
			if (bIsDifficultyConfigFound(sDifficultyConfig, sizeof sDifficultyConfig))
			{
				g_esGeneral.g_iFileTimeNew[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[1] != g_esGeneral.g_iFileTimeNew[1] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sDifficultyConfig);
					vCustomConfig(sDifficultyConfig);
					g_esGeneral.g_iFileTimeOld[1] = g_esGeneral.g_iFileTimeNew[1];
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_MAP)
		{
			char sMapConfig[PLATFORM_MAX_PATH];
			if (bIsMapConfigFound(sMapConfig, sizeof sMapConfig))
			{
				g_esGeneral.g_iFileTimeNew[2] = GetFileTime(sMapConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[2] != g_esGeneral.g_iFileTimeNew[2] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sMapConfig);
					vCustomConfig(sMapConfig);
					g_esGeneral.g_iFileTimeOld[2] = g_esGeneral.g_iFileTimeNew[2];
				}
			}
		}

		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_GAMEMODE) && g_esGeneral.g_cvMTGameMode != null)
		{
			char sModeConfig[PLATFORM_MAX_PATH];
			if (bIsGameModeConfigFound(sModeConfig, sizeof sModeConfig))
			{
				g_esGeneral.g_iFileTimeNew[3] = GetFileTime(sModeConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[3] != g_esGeneral.g_iFileTimeNew[3] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sModeConfig);
					vCustomConfig(sModeConfig);
					g_esGeneral.g_iFileTimeOld[3] = g_esGeneral.g_iFileTimeNew[3];
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_DAY)
		{
			char sDayConfig[PLATFORM_MAX_PATH];
			if (bIsDayConfigFound(sDayConfig, sizeof sDayConfig))
			{
				g_esGeneral.g_iFileTimeNew[4] = GetFileTime(sDayConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[4] != g_esGeneral.g_iFileTimeNew[4] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sDayConfig);
					vCustomConfig(sDayConfig);
					g_esGeneral.g_iFileTimeOld[4] = g_esGeneral.g_iFileTimeNew[4];
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_PLAYERCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			int iCount = iGetPlayerCount();
			BuildPath(Path_SM, sCountConfig, sizeof sCountConfig, "%s%s%i.cfg", MT_CONFIG_PATH, MT_CONFIG_PATH_PLAYERCOUNT, iCount);
			if (FileExists(sCountConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[5] != g_esGeneral.g_iFileTimeNew[5] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sCountConfig);
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iFileTimeOld[5] = g_esGeneral.g_iFileTimeNew[5];
					g_esGeneral.g_iPlayerCount[0] = iCount;
				}
				else if (g_esGeneral.g_iPlayerCount[0] != iCount || manual)
				{
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iPlayerCount[0] = iCount;
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_SURVIVORCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			int iCount = iGetHumanCount();
			BuildPath(Path_SM, sCountConfig, sizeof sCountConfig, "%s%s%i.cfg", MT_CONFIG_PATH, MT_CONFIG_PATH_SURVIVORCOUNT, iCount);
			if (FileExists(sCountConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[6] = GetFileTime(sCountConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[6] != g_esGeneral.g_iFileTimeNew[6] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sCountConfig);
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iFileTimeOld[6] = g_esGeneral.g_iFileTimeNew[6];
					g_esGeneral.g_iPlayerCount[1] = iCount;
				}
				else if (g_esGeneral.g_iPlayerCount[1] != iCount || manual)
				{
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iPlayerCount[1] = iCount;
				}
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_INFECTEDCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			int iCount = iGetHumanCount(true);
			BuildPath(Path_SM, sCountConfig, sizeof sCountConfig, "%s%s%i.cfg", MT_CONFIG_PATH, MT_CONFIG_PATH_INFECTEDCOUNT, iCount);
			if (FileExists(sCountConfig, true))
			{
				g_esGeneral.g_iFileTimeNew[7] = GetFileTime(sCountConfig, FileTime_LastChange);
				if (g_esGeneral.g_iFileTimeOld[7] != g_esGeneral.g_iFileTimeNew[7] || manual)
				{
					vLogMessage(MT_LOG_SERVER, _, "%s %T", MT_TAG, "ReloadingConfig", LANG_SERVER, sCountConfig);
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iFileTimeOld[7] = g_esGeneral.g_iFileTimeNew[7];
					g_esGeneral.g_iPlayerCount[2] = iCount;
				}
				else if (g_esGeneral.g_iPlayerCount[2] != iCount || manual)
				{
					vCustomConfig(sCountConfig);
					g_esGeneral.g_iPlayerCount[2] = iCount;
				}
			}
		}
	}
}

void vCustomConfig(const char[] savepath)
{
	DataPack dpConfig;
	CreateDataTimer(1.5, tTimerExecuteCustomConfig, dpConfig, TIMER_FLAG_NO_MAPCHANGE);
	dpConfig.WriteString(savepath);
}

void vDefaultConVarSettings()
{
	g_esGeneral.g_flDefaultAmmoPackUseDuration = -1.0;
	g_esGeneral.g_flDefaultColaBottlesUseDuration = -1.0;
	g_esGeneral.g_flDefaultDefibrillatorUseDuration = -1.0;
	g_esGeneral.g_flDefaultFirstAidHealPercent = -1.0;
	g_esGeneral.g_flDefaultFirstAidKitUseDuration = -1.0;
	g_esGeneral.g_flDefaultGasCanUseDuration = -1.0;
	g_esGeneral.g_flDefaultGunSwingInterval = -1.0;
	g_esGeneral.g_flDefaultPhysicsPushScale = -1.0;
	g_esGeneral.g_flDefaultSurvivorReviveDuration = -1.0;
	g_esGeneral.g_flDefaultUpgradePackUseDuration = -1.0;
	g_esGeneral.g_iDefaultMeleeRange = -1;
	g_esGeneral.g_iDefaultSurvivorReviveHealth = -1;
	g_esGeneral.g_iDefaultTankIncapHealth = -1;
}

void vDefaultCookieSettings(int client)
{
	g_esPlayer[client].g_iRewardVisuals = MT_VISUAL_SCREEN|MT_VISUAL_PARTICLE|MT_VISUAL_VOICELINE|MT_VISUAL_LIGHT|MT_VISUAL_BODY|MT_VISUAL_GLOW;

	for (int iPos = 0; iPos < sizeof esPlayer::g_bApplyVisuals; iPos++)
	{
		g_esPlayer[client].g_bApplyVisuals[iPos] = true;
	}
}

void vDeveloperSettings(int developer)
{
	g_esDeveloper[developer].g_bDevVisual = false;
	g_esDeveloper[developer].g_sDevFallVoiceline = "PlayerLaugh";
	g_esDeveloper[developer].g_sDevFlashlight = "rainbow";
	g_esDeveloper[developer].g_sDevGlowOutline = "rainbow";
	g_esDeveloper[developer].g_sDevLoadout = g_bSecondGame ? "shotgun_spas;machete;molotov;first_aid_kit;pain_pills" : "autoshotgun;pistol;molotov;first_aid_kit;pain_pills;pistol";
	g_esDeveloper[developer].g_sDevSkinColor = "rainbow";
	g_esDeveloper[developer].g_flDevActionDuration = 2.0;
	g_esDeveloper[developer].g_flDevAttackBoost = 1.25;
	g_esDeveloper[developer].g_flDevDamageBoost = 1.75;
	g_esDeveloper[developer].g_flDevDamageResistance = 0.5;
	g_esDeveloper[developer].g_flDevHealPercent = 100.0;
	g_esDeveloper[developer].g_flDevJumpHeight = 100.0;
	g_esDeveloper[developer].g_flDevPunchResistance = 0.0;
	g_esDeveloper[developer].g_flDevRewardDuration = 60.0;
	g_esDeveloper[developer].g_flDevShoveDamage = 0.025;
	g_esDeveloper[developer].g_flDevShoveRate = 0.4;
	g_esDeveloper[developer].g_flDevSpeedBoost = 1.25;
	g_esDeveloper[developer].g_iDevAccess = 0;
	g_esDeveloper[developer].g_iDevAmmoRegen = 1;
	g_esDeveloper[developer].g_iDevHealthRegen = 1;
	g_esDeveloper[developer].g_iDevInfiniteAmmo = 31;
	g_esDeveloper[developer].g_iDevLifeLeech = 5;
	g_esDeveloper[developer].g_iDevMeleeRange = 150;
	g_esDeveloper[developer].g_iDevPanelLevel = 0;
	g_esDeveloper[developer].g_iDevParticle = MT_ROCK_FIRE;
	g_esDeveloper[developer].g_iDevReviveHealth = 100;
	g_esDeveloper[developer].g_iDevRewardTypes = MT_REWARD_HEALTH|MT_REWARD_AMMO|MT_REWARD_REFILL|MT_REWARD_ATTACKBOOST|MT_REWARD_DAMAGEBOOST|MT_REWARD_SPEEDBOOST|MT_REWARD_GODMODE|MT_REWARD_ITEM|MT_REWARD_RESPAWN|MT_REWARD_INFAMMO;
	g_esDeveloper[developer].g_iDevSpecialAmmo = 0;
	g_esDeveloper[developer].g_iDevWeaponSkin = 1;

	vDefaultCookieSettings(developer);
}

void vExecuteFinaleConfigs(const char[] filename)
{
	if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_FINALE) && g_esGeneral.g_iConfigEnable == 1)
	{
		char sFinaleConfig[PLATFORM_MAX_PATH];
		if (bIsFinaleConfigFound(filename, sFinaleConfig, sizeof sFinaleConfig))
		{
			vCustomConfig(sFinaleConfig);
		}
	}
}

void vReadAdminSettings(int admin, int type, const char[] key, const char[] value)
{
	if (1 <= type <= MT_MAXTYPES)
	{
		if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
		{
			g_esAdmin[type].g_iAccessFlags[admin] = ReadFlagString(value);
		}
		else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
		{
			g_esAdmin[type].g_iImmunityFlags[admin] = ReadFlagString(value);
		}
	}
}

void vReadTankSettings(int type, const char[] sub, const char[] key, const char[] value)
{
	if (1 <= type <= MT_MAXTYPES)
	{
		g_esTank[type].g_iGameType = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "GameType", "Game Type", "Game_Type", "game", g_esTank[type].g_iGameType, value, 0, 2);
		g_esTank[type].g_iTankEnabled = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankEnabled", "Tank Enabled", "Tank_Enabled", "tenabled", g_esTank[type].g_iTankEnabled, value, -1, 1);
		g_esTank[type].g_flTankChance = flGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankChance", "Tank Chance", "Tank_Chance", "chance", g_esTank[type].g_flTankChance, value, 0.0, 100.0);
		g_esTank[type].g_iTankModel = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankModel", "Tank Model", "Tank_Model", "model", g_esTank[type].g_iTankModel, value, 0, 7);
		g_esTank[type].g_flBurnDuration = flGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "BurnDuration", "Burn Duration", "Burn_Duration", "burndur", g_esTank[type].g_flBurnDuration, value, 0.0, 999999.0);
		g_esTank[type].g_flBurntSkin = flGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "BurntSkin", "Burnt Skin", "Burnt_Skin", "burnt", g_esTank[type].g_flBurntSkin, value, -1.0, 1.0);
		g_esTank[type].g_iTankNote = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankNote", "Tank Note", "Tank_Note", "note", g_esTank[type].g_iTankNote, value, 0, 1);
		g_esTank[type].g_iSpawnEnabled = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "SpawnEnabled", "Spawn Enabled", "Spawn_Enabled", "spawn", g_esTank[type].g_iSpawnEnabled, value, -1, 1);
		g_esTank[type].g_iMenuEnabled = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "MenuEnabled", "Menu Enabled", "Menu_Enabled", "menu", g_esTank[type].g_iMenuEnabled, value, 0, 1);
		g_esTank[type].g_iCheckAbilities = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "CheckAbilities", "Check Abilities", "Check_Abilities", "check", g_esTank[type].g_iCheckAbilities, value, 0, 1);
		g_esTank[type].g_iDeathRevert = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "DeathRevert", "Death Revert", "Death_Revert", "revert", g_esTank[type].g_iDeathRevert, value, 0, 1);
		g_esTank[type].g_iRequiresHumans = iGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esTank[type].g_iRequiresHumans, value, 0, 32);
		g_esTank[type].g_iAnnounceArrival = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceArrival", "Announce Arrival", "Announce_Arrival", "arrival", g_esTank[type].g_iAnnounceArrival, value, 0, 31);
		g_esTank[type].g_iAnnounceDeath = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceDeath", "Announce Death", "Announce_Death", "death", g_esTank[type].g_iAnnounceDeath, value, 0, 2);
		g_esTank[type].g_iAnnounceKill = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "AnnounceKill", "Announce Kill", "Announce_Kill", "kill", g_esTank[type].g_iAnnounceKill, value, 0, 1);
		g_esTank[type].g_iArrivalMessage = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "ArrivalMessage", "Arrival Message", "Arrival_Message", "arrivalmsg", g_esTank[type].g_iArrivalMessage, value, 0, 1023);
		g_esTank[type].g_iArrivalSound = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "ArrivalSound", "Arrival Sound", "Arrival_Sound", "arrivalsnd", g_esTank[type].g_iArrivalSound, value, 0, 1);
		g_esTank[type].g_iDeathDetails = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathDetails", "Death Details", "Death_Details", "deathdets", g_esTank[type].g_iDeathDetails, value, 0, 5);
		g_esTank[type].g_iDeathMessage = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathMessage", "Death Message", "Death_Message", "deathmsg", g_esTank[type].g_iDeathMessage, value, 0, 1023);
		g_esTank[type].g_iDeathSound = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "DeathSound", "Death Sound", "Death_Sound", "deathsnd", g_esTank[type].g_iDeathSound, value, 0, 1);
		g_esTank[type].g_iKillMessage = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "KillMessage", "Kill Message", "Kill_Message", "killmsg", g_esTank[type].g_iKillMessage, value, 0, 1023);
		g_esTank[type].g_iVocalizeArrival = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "VocalizeArrival", "Vocalize Arrival", "Vocalize_Arrival", "arrivalvoc", g_esTank[type].g_iVocalizeArrival, value, 0, 1);
		g_esTank[type].g_iVocalizeDeath = iGetKeyValue(sub, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE, MT_CONFIG_SECTION_ANNOUNCE2, key, "VocalizeDeath", "Vocalize Death", "Vocalize_Death", "deathvoc", g_esTank[type].g_iVocalizeDeath, value, 0, 1);
		g_esTank[type].g_iTeammateLimit = iGetKeyValue(sub, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, MT_CONFIG_SECTION_REWARDS, key, "TeammateLimit", "Teammate Limit", "Teammate_Limit", "teamlimit", g_esTank[type].g_iTeammateLimit, value, 0, 32);
		g_esTank[type].g_iGlowEnabled = iGetKeyValue(sub, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, key, "GlowEnabled", "Glow Enabled", "Glow_Enabled", "genabled", g_esTank[type].g_iGlowEnabled, value, 0, 1);
		g_esTank[type].g_iGlowFlashing = iGetKeyValue(sub, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, key, "GlowFlashing", "Glow Flashing", "Glow_Flashing", "flashing", g_esTank[type].g_iGlowFlashing, value, 0, 1);
		g_esTank[type].g_iGlowType = iGetKeyValue(sub, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, MT_CONFIG_SECTION_GLOW, key, "GlowType", "Glow Type", "Glow_Type", "type", g_esTank[type].g_iGlowType, value, 0, 1);
		g_esTank[type].g_iBaseHealth = iGetKeyValue(sub, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "BaseHealth", "Base Health", "Base_Health", "basehp", g_esTank[type].g_iBaseHealth, value, 0, MT_MAXHEALTH);
		g_esTank[type].g_iDisplayHealth = iGetKeyValue(sub, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "DisplayHealth", "Display Health", "Display_Health", "displayhp", g_esTank[type].g_iDisplayHealth, value, 0, 11);
		g_esTank[type].g_iDisplayHealthType = iGetKeyValue(sub, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "DisplayHealthType", "Display Health Type", "Display_Health_Type", "displaytype", g_esTank[type].g_iDisplayHealthType, value, 0, 2);
		g_esTank[type].g_iExtraHealth = iGetKeyValue(sub, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "ExtraHealth", "Extra Health", "Extra_Health", "extrahp", g_esTank[type].g_iExtraHealth, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esTank[type].g_iMinimumHumans = iGetKeyValue(sub, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "MinimumHumans", "Minimum Humans", "Minimum_Humans", "minhumans", g_esTank[type].g_iMinimumHumans, value, 1, 32);
		g_esTank[type].g_iMultiplyHealth = iGetKeyValue(sub, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "MultiplyHealth", "Multiply Health", "Multiply_Health", "multihp", g_esTank[type].g_iMultiplyHealth, value, 0, 3);
		g_esTank[type].g_iHumanSupport = iGetKeyValue(sub, MT_CONFIG_SECTION_HUMAN, MT_CONFIG_SECTION_HUMAN2, MT_CONFIG_SECTION_HUMAN3, MT_CONFIG_SECTION_HUMAN4, key, MT_CONFIG_SECTION_HUMAN, MT_CONFIG_SECTION_HUMAN2, MT_CONFIG_SECTION_HUMAN3, MT_CONFIG_SECTION_HUMAN4, g_esTank[type].g_iHumanSupport, value, 0, 2);
		g_esTank[type].g_iTypeLimit = iGetKeyValue(sub, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, key, "TypeLimit", "Type Limit", "Type_Limit", "limit", g_esTank[type].g_iTypeLimit, value, 0, 32);
		g_esTank[type].g_iFinaleTank = iGetKeyValue(sub, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, key, "FinaleTank", "Finale Tank", "Finale_Tank", "finale", g_esTank[type].g_iFinaleTank, value, 0, 4);
		g_esTank[type].g_flOpenAreasOnly = flGetKeyValue(sub, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esTank[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esTank[type].g_iBossStages = iGetKeyValue(sub, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, MT_CONFIG_SECTION_BOSS, key, "BossStages", "Boss Stages", "Boss_Stages", "bossstages", g_esTank[type].g_iBossStages, value, 1, 4);
		g_esTank[type].g_iRandomTank = iGetKeyValue(sub, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, key, "RandomTank", "Random Tank", "Random_Tank", "random", g_esTank[type].g_iRandomTank, value, 0, 1);
		g_esTank[type].g_flRandomDuration = flGetKeyValue(sub, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, key, "RandomDuration", "Random Duration", "Random_Duration", "randduration", g_esTank[type].g_flRandomDuration, value, 0.1, 999999.0);
		g_esTank[type].g_flRandomInterval = flGetKeyValue(sub, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, MT_CONFIG_SECTION_RANDOM, key, "RandomInterval", "Random Interval", "Random_Interval", "randinterval", g_esTank[type].g_flRandomInterval, value, 0.1, 999999.0);
		g_esTank[type].g_flTransformDelay = flGetKeyValue(sub, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, key, "TransformDelay", "Transform Delay", "Transform_Delay", "transdelay", g_esTank[type].g_flTransformDelay, value, 0.1, 999999.0);
		g_esTank[type].g_flTransformDuration = flGetKeyValue(sub, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, MT_CONFIG_SECTION_TRANSFORM, key, "TransformDuration", "Transform Duration", "Transform_Duration", "transduration", g_esTank[type].g_flTransformDuration, value, 0.1, 999999.0);
		g_esTank[type].g_iSpawnType = iGetKeyValue(sub, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, MT_CONFIG_SECTION_SPAWN, key, "SpawnType", "Spawn Type", "Spawn_Type", "spawntype", g_esTank[type].g_iSpawnType, value, 0, 4);
		g_esTank[type].g_iRockModel = iGetKeyValue(sub, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, key, "RockModel", "Rock Model", "Rock_Model", "rockmodel", g_esTank[type].g_iRockModel, value, 0, 2);
		g_esTank[type].g_iPropsAttached = iGetKeyValue(sub, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, MT_CONFIG_SECTION_PROPS, key, "PropsAttached", "Props Attached", "Props_Attached", "attached", g_esTank[type].g_iPropsAttached, value, 0, 511);
		g_esTank[type].g_iBodyEffects = iGetKeyValue(sub, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, key, "BodyEffects", "Body Effects", "Body_Effects", "body", g_esTank[type].g_iBodyEffects, value, 0, 127);
		g_esTank[type].g_iRockEffects = iGetKeyValue(sub, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, MT_CONFIG_SECTION_PARTICLES, key, "RockEffects", "Rock Effects", "Rock_Effects", "rock", g_esTank[type].g_iRockEffects, value, 0, 15);
		g_esTank[type].g_flAttackInterval = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "AttackInterval", "Attack Interval", "Attack_Interval", "attack", g_esTank[type].g_flAttackInterval, value, 0.0, 999999.0);
		g_esTank[type].g_flClawDamage = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "ClawDamage", "Claw Damage", "Claw_Damage", "claw", g_esTank[type].g_flClawDamage, value, -1.0, 999999.0);
		g_esTank[type].g_iGroundPound = iGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "GroundPound", "Ground Pound", "Ground_Pound", "pound", g_esTank[type].g_iGroundPound, value, 0, 1);
		g_esTank[type].g_flHittableDamage = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "HittableDamage", "Hittable Damage", "Hittable_Damage", "hittable", g_esTank[type].g_flHittableDamage, value, -1.0, 999999.0);
		g_esTank[type].g_flPunchForce = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "PunchForce", "Punch Force", "Punch_Force", "punchf", g_esTank[type].g_flPunchForce, value, -1.0, 999999.0);
		g_esTank[type].g_flPunchThrow = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "PunchThrow", "Punch Throw", "Punch_Throw", "puncht", g_esTank[type].g_flPunchThrow, value, 0.0, 100.0);
		g_esTank[type].g_flRockDamage = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "RockDamage", "Rock Damage", "Rock_Damage", "rock", g_esTank[type].g_flRockDamage, value, -1.0, 999999.0);
		g_esTank[type].g_flRunSpeed = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "RunSpeed", "Run Speed", "Run_Speed", "speed", g_esTank[type].g_flRunSpeed, value, 0.0, 3.0);
		g_esTank[type].g_iSkipIncap = iGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SkipIncap", "Skip Incap", "Skip_Incap", "incap", g_esTank[type].g_iSkipIncap, value, 0, 1);
		g_esTank[type].g_iSkipTaunt = iGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SkipTaunt", "Skip Taunt", "Skip_Taunt", "taunt", g_esTank[type].g_iSkipTaunt, value, 0, 1);
		g_esTank[type].g_iSweepFist = iGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "SweepFist", "Sweep Fist", "Sweep_Fist", "sweep", g_esTank[type].g_iSweepFist, value, 0, 1);
		g_esTank[type].g_flThrowInterval = flGetKeyValue(sub, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE, MT_CONFIG_SECTION_ENHANCE2, key, "ThrowInterval", "Throw Interval", "Throw_Interval", "throw", g_esTank[type].g_flThrowInterval, value, 0.0, 999999.0);
		g_esTank[type].g_iBulletImmunity = iGetKeyValue(sub, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "BulletImmunity", "Bullet Immunity", "Bullet_Immunity", "bullet", g_esTank[type].g_iBulletImmunity, value, 0, 1);
		g_esTank[type].g_iExplosiveImmunity = iGetKeyValue(sub, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "ExplosiveImmunity", "Explosive Immunity", "Explosive_Immunity", "explosive", g_esTank[type].g_iExplosiveImmunity, value, 0, 1);
		g_esTank[type].g_iFireImmunity = iGetKeyValue(sub, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "FireImmunity", "Fire Immunity", "Fire_Immunity", "fire", g_esTank[type].g_iFireImmunity, value, 0, 1);
		g_esTank[type].g_iHittableImmunity = iGetKeyValue(sub, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "HittableImmunity", "Hittable Immunity", "Hittable_Immunity", "hittable", g_esTank[type].g_iHittableImmunity, value, 0, 1);
		g_esTank[type].g_iMeleeImmunity = iGetKeyValue(sub, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "MeleeImmunity", "Melee Immunity", "Melee_Immunity", "melee", g_esTank[type].g_iMeleeImmunity, value, 0, 1);
		g_esTank[type].g_iVomitImmunity = iGetKeyValue(sub, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE, MT_CONFIG_SECTION_IMMUNE2, key, "VomitImmunity", "Vomit Immunity", "Vomit_Immunity", "vomit", g_esTank[type].g_iVomitImmunity, value, 0, 1);
		g_esTank[type].g_iAccessFlags = iGetAdminFlagsValue(sub, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		g_esTank[type].g_iImmunityFlags = iGetAdminFlagsValue(sub, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN, MT_CONFIG_SECTION_ADMIN2, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);

		vGetKeyValue(sub, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, MT_CONFIG_SECTION_HEALTH, key, "HealthCharacters", "Health Characters", "Health_Characters", "hpchars", g_esTank[type].g_sHealthCharacters, sizeof esTank::g_sHealthCharacters, value);
		vGetKeyValue(sub, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, MT_CONFIG_SECTION_COMBO, key, "ComboSet", "Combo Set", "Combo_Set", "set", g_esTank[type].g_sComboSet, sizeof esTank::g_sComboSet, value);

		if (StrEqual(sub, MT_CONFIG_SECTION_GENERAL, false))
		{
			if (StrEqual(key, "SkinColor", false) || StrEqual(key, "Skin Color", false) || StrEqual(key, "Skin_Color", false) || StrEqual(key, "skin", false))
			{
				char sValue[64], sSet[4][4];
				vGetConfigColors(sValue, sizeof sValue, value);
				strcopy(g_esTank[type].g_sSkinColor, sizeof esTank::g_sSkinColor, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < sizeof esTank::g_iSkinColor; iPos++)
				{
					g_esTank[type].g_iSkinColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}
			}
			else
			{
				vGetKeyValue(sub, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, MT_CONFIG_SECTION_GENERAL, key, "TankName", "Tank Name", "Tank_Name", "name", g_esTank[type].g_sTankName, sizeof esTank::g_sTankName, value);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_REWARDS, false))
		{
			char sValue[1280], sSet[7][320];
			strcopy(sValue, sizeof sValue, value);
			ReplaceString(sValue, sizeof sValue, " ", "");
			ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
			for (int iPos = 0; iPos < sizeof esTank::g_iStackLimits; iPos++)
			{
				if (iPos < sizeof esTank::g_iRewardEnabled)
				{
					g_esTank[type].g_flRewardChance[iPos] = flGetClampedValue(key, "RewardChance", "Reward Chance", "Reward_Chance", "chance", g_esTank[type].g_flRewardChance[iPos], sSet[iPos], 0.1, 100.0);
					g_esTank[type].g_flRewardDuration[iPos] = flGetClampedValue(key, "RewardDuration", "Reward Duration", "Reward_Duration", "duration", g_esTank[type].g_flRewardDuration[iPos], sSet[iPos], 0.1, 999999.0);
					g_esTank[type].g_flRewardPercentage[iPos] = flGetClampedValue(key, "RewardPercentage", "Reward Percentage", "Reward_Percentage", "percent", g_esTank[type].g_flRewardPercentage[iPos], sSet[iPos], 0.1, 100.0);
					g_esTank[type].g_flActionDurationReward[iPos] = flGetClampedValue(key, "ActionDurationReward", "Action Duration Reward", "Action_Duration_Reward", "actionduration", g_esTank[type].g_flActionDurationReward[iPos], sSet[iPos], 0.0, 999999.0);
					g_esTank[type].g_flAttackBoostReward[iPos] = flGetClampedValue(key, "AttackBoostReward", "Attack Boost Reward", "Attack_Boost_Reward", "attackboost", g_esTank[type].g_flAttackBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
					g_esTank[type].g_flDamageBoostReward[iPos] = flGetClampedValue(key, "DamageBoostReward", "Damage Boost Reward", "Damage_Boost_Reward", "dmgboost", g_esTank[type].g_flDamageBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
					g_esTank[type].g_flDamageResistanceReward[iPos] = flGetClampedValue(key, "DamageResistanceReward", "Damage Resistance Reward", "Damage_Resistance_Reward", "dmgres", g_esTank[type].g_flDamageResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
					g_esTank[type].g_flHealPercentReward[iPos] = flGetClampedValue(key, "HealPercentReward", "Heal Percent Reward", "Heal_Percent_Reward", "healpercent", g_esTank[type].g_flHealPercentReward[iPos], sSet[iPos], 0.0, 100.0);
					g_esTank[type].g_flJumpHeightReward[iPos] = flGetClampedValue(key, "JumpHeightReward", "Jump Height Reward", "Jump_Height_Reward", "jumpheight", g_esTank[type].g_flJumpHeightReward[iPos], sSet[iPos], 0.0, 999999.0);
					g_esTank[type].g_flPunchResistanceReward[iPos] = flGetClampedValue(key, "PunchResistanceReward", "Punch Resistance Reward", "Punch_Resistance_Reward", "punchres", g_esTank[type].g_flPunchResistanceReward[iPos], sSet[iPos], 0.0, 1.0);
					g_esTank[type].g_flShoveDamageReward[iPos] = flGetClampedValue(key, "ShoveDamageReward", "Shove Damage Reward", "Shove_Damage_Reward", "shovedmg", g_esTank[type].g_flShoveDamageReward[iPos], sSet[iPos], 0.0, 999999.0);
					g_esTank[type].g_flShoveRateReward[iPos] = flGetClampedValue(key, "ShoveRateReward", "Shove Rate Reward", "Shove_Rate_Reward", "shoverate", g_esTank[type].g_flShoveRateReward[iPos], sSet[iPos], 0.0, 999999.0);
					g_esTank[type].g_flSpeedBoostReward[iPos] = flGetClampedValue(key, "SpeedBoostReward", "Speed Boost Reward", "Speed_Boost_Reward", "speedboost", g_esTank[type].g_flSpeedBoostReward[iPos], sSet[iPos], 0.0, 999999.0);
					g_esTank[type].g_iRewardEnabled[iPos] = iGetClampedValue(key, "RewardEnabled", "Reward Enabled", "Reward_Enabled", "renabled", g_esTank[type].g_iRewardEnabled[iPos], sSet[iPos], -1, 2147483647);
					g_esTank[type].g_iRewardBots[iPos] = iGetClampedValue(key, "RewardBots", "Reward Bots", "Reward_Bots", "bots", g_esTank[type].g_iRewardBots[iPos], sSet[iPos], -1, 2147483647);
					g_esTank[type].g_iRewardEffect[iPos] = iGetClampedValue(key, "RewardEffect", "Reward Effect", "Reward_Effect", "effect", g_esTank[type].g_iRewardEffect[iPos], sSet[iPos], 0, 15);
					g_esTank[type].g_iRewardNotify[iPos] = iGetClampedValue(key, "RewardNotify", "Reward Notify", "Reward_Notify", "rnotify", g_esTank[type].g_iRewardNotify[iPos], sSet[iPos], 0, 3);
					g_esTank[type].g_iRewardVisual[iPos] = iGetClampedValue(key, "RewardVisual", "Reward Visual", "Reward_Visual", "visual", g_esTank[type].g_iRewardVisual[iPos], sSet[iPos], 0, 63);
					g_esTank[type].g_iAmmoBoostReward[iPos] = iGetClampedValue(key, "AmmoBoostReward", "Ammo Boost Reward", "Ammo_Boost_Reward", "ammoboost", g_esTank[type].g_iAmmoBoostReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iAmmoRegenReward[iPos] = iGetClampedValue(key, "AmmoRegenReward", "Ammo Regen Reward", "Ammo_Regen_Reward", "ammoregen", g_esTank[type].g_iAmmoRegenReward[iPos], sSet[iPos], 0, 999999);
					g_esTank[type].g_iCleanKillsReward[iPos] = iGetClampedValue(key, "CleanKillsReward", "Clean Kills Reward", "Clean_Kills_Reward", "cleankills", g_esTank[type].g_iCleanKillsReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iHealthRegenReward[iPos] = iGetClampedValue(key, "HealthRegenReward", "Health Regen Reward", "Health_Regen_Reward", "hpregen", g_esTank[type].g_iHealthRegenReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
					g_esTank[type].g_iHollowpointAmmoReward[iPos] = iGetClampedValue(key, "HollowpointAmmoReward", "Hollowpoint Ammo Reward", "Hollowpoint_Ammo_Reward", "hollowpoint", g_esTank[type].g_iHollowpointAmmoReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iInfiniteAmmoReward[iPos] = iGetClampedValue(key, "InfiniteAmmoReward", "Infinite Ammo Reward", "Infinite_Ammo_Reward", "infammo", g_esTank[type].g_iInfiniteAmmoReward[iPos], sSet[iPos], 0, 31);
					g_esTank[type].g_iLadderActionsReward[iPos] = iGetClampedValue(key, "LadderActionsReward", "Ladder Actions Reward", "Ladder_Action_Reward", "ladderactions", g_esTank[type].g_iLadderActionsReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iLadyKillerReward[iPos] = iGetClampedValue(key, "LadyKillerReward", "Lady Killer Reward", "Lady_Killer_Reward", "ladykiller", g_esTank[type].g_iLadyKillerReward[iPos], sSet[iPos], 0, 999999);
					g_esTank[type].g_iLifeLeechReward[iPos] = iGetClampedValue(key, "LifeLeechReward", "Life Leech Reward", "Life_Leech_Reward", "lifeleech", g_esTank[type].g_iLifeLeechReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
					g_esTank[type].g_iMeleeRangeReward[iPos] = iGetClampedValue(key, "MeleeRangeReward", "Melee Range Reward", "Melee_Range_Reward", "meleerange", g_esTank[type].g_iMeleeRangeReward[iPos], sSet[iPos], 0, 999999);
					g_esTank[type].g_iParticleEffectVisual[iPos] = iGetClampedValue(key, "ParticleEffectVisual", "Particle Effect Visual", "Particle_Effect_Visual", "particle", g_esTank[type].g_iParticleEffectVisual[iPos], sSet[iPos], 0, 15);
					g_esTank[type].g_iPrefsNotify[iPos] = iGetClampedValue(key, "PrefsNotify", "Prefs Notify", "Prefs_Notify", "pnotify", g_esTank[type].g_iPrefsNotify[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iRespawnLoadoutReward[iPos] = iGetClampedValue(key, "RespawnLoadoutReward", "Respawn Loadout Reward", "Respawn_Loadout_Reward", "resloadout", g_esTank[type].g_iRespawnLoadoutReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iReviveHealthReward[iPos] = iGetClampedValue(key, "ReviveHealthReward", "Revive Health Reward", "Revive_Health_Reward", "revivehp", g_esTank[type].g_iReviveHealthReward[iPos], sSet[iPos], 0, MT_MAXHEALTH);
					g_esTank[type].g_iShareRewards[iPos] = iGetClampedValue(key, "ShareRewards", "Share Rewards", "Share_Rewards", "share", g_esTank[type].g_iShareRewards[iPos], sSet[iPos], 0, 3);
					g_esTank[type].g_iShovePenaltyReward[iPos] = iGetClampedValue(key, "ShovePenaltyReward", "Shove Penalty Reward", "Shove_Penalty_Reward", "shovepenalty", g_esTank[type].g_iShovePenaltyReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iSledgehammerRoundsReward[iPos] = iGetClampedValue(key, "SledgehammerRoundsReward", "Sledgehammer Rounds Reward", "Sledgehammer_Rounds_Reward", "sledgehammer", g_esTank[type].g_iSledgehammerRoundsReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iSpecialAmmoReward[iPos] = iGetClampedValue(key, "SpecialAmmoReward", "Special Ammo Reward", "Special_Ammo_Reward", "specialammo", g_esTank[type].g_iSpecialAmmoReward[iPos], sSet[iPos], 0, 3);
					g_esTank[type].g_iStackRewards[iPos] = iGetClampedValue(key, "StackRewards", "Stack Rewards", "Stack_Rewards", "stack", g_esTank[type].g_iStackRewards[iPos], sSet[iPos], 0, 2147483647);
					g_esTank[type].g_iThornsReward[iPos] = iGetClampedValue(key, "ThornsReward", "Thorns Reward", "Thorns_Reward", "thorns", g_esTank[type].g_iThornsReward[iPos], sSet[iPos], 0, 1);
					g_esTank[type].g_iUsefulRewards[iPos] = iGetClampedValue(key, "UsefulRewards", "Useful Rewards", "Useful_Rewards", "useful", g_esTank[type].g_iUsefulRewards[iPos], sSet[iPos], 0, 15);

					vGetConfigColors(sValue, sizeof sValue, sSet[iPos], ';');
					vGetStringValue(key, "BodyColorVisual", "Body Color Visual", "Body_Color_Visual", "bodycolor", iPos, g_esTank[type].g_sBodyColorVisual, sizeof esTank::g_sBodyColorVisual, g_esTank[type].g_sBodyColorVisual2, sizeof esTank::g_sBodyColorVisual2, g_esTank[type].g_sBodyColorVisual3, sizeof esTank::g_sBodyColorVisual3, g_esTank[type].g_sBodyColorVisual4, sizeof esTank::g_sBodyColorVisual4, sValue);
					vGetStringValue(key, "FallVoicelineReward", "Fall Voiceline Reward", "Fall_Voiceline_Reward", "fallvoice", iPos, g_esTank[type].g_sFallVoicelineReward, sizeof esTank::g_sFallVoicelineReward, g_esTank[type].g_sFallVoicelineReward2, sizeof esTank::g_sFallVoicelineReward2, g_esTank[type].g_sFallVoicelineReward3, sizeof esTank::g_sFallVoicelineReward3, g_esTank[type].g_sFallVoicelineReward4, sizeof esTank::g_sFallVoicelineReward4, sSet[iPos]);
					vGetStringValue(key, "GlowColorVisual", "Glow Color Visual", "Glow_Color_Visual", "glowcolor", iPos, g_esTank[type].g_sOutlineColorVisual, sizeof esTank::g_sOutlineColorVisual, g_esTank[type].g_sOutlineColorVisual2, sizeof esTank::g_sOutlineColorVisual2, g_esTank[type].g_sOutlineColorVisual3, sizeof esTank::g_sOutlineColorVisual3, g_esTank[type].g_sOutlineColorVisual4, sizeof esTank::g_sOutlineColorVisual4, sValue);
					vGetStringValue(key, "ItemReward", "Item Reward", "Item_Reward", "item", iPos, g_esTank[type].g_sItemReward, sizeof esTank::g_sItemReward, g_esTank[type].g_sItemReward2, sizeof esTank::g_sItemReward2, g_esTank[type].g_sItemReward3, sizeof esTank::g_sItemReward3, g_esTank[type].g_sItemReward4, sizeof esTank::g_sItemReward4, sValue);
					vGetStringValue(key, "LightColorVisual", "Light Color Visual", "Light_Color_Visual", "lightcolor", iPos, g_esTank[type].g_sLightColorVisual, sizeof esTank::g_sLightColorVisual, g_esTank[type].g_sLightColorVisual2, sizeof esTank::g_sLightColorVisual2, g_esTank[type].g_sLightColorVisual3, sizeof esTank::g_sLightColorVisual3, g_esTank[type].g_sLightColorVisual4, sizeof esTank::g_sLightColorVisual4, sValue);
					vGetStringValue(key, "LoopingVoicelineVisual", "Looping Voiceline Visual", "Looping_Voiceline_Visual", "loopvoice", iPos, g_esTank[type].g_sLoopingVoicelineVisual, sizeof esTank::g_sLoopingVoicelineVisual, g_esTank[type].g_sLoopingVoicelineVisual2, sizeof esTank::g_sLoopingVoicelineVisual2, g_esTank[type].g_sLoopingVoicelineVisual3, sizeof esTank::g_sLoopingVoicelineVisual3, g_esTank[type].g_sLoopingVoicelineVisual4, sizeof esTank::g_sLoopingVoicelineVisual4, sSet[iPos]);
					vGetStringValue(key, "ScreenColorVisual", "Screen Color Visual", "Screen_Color_Visual", "screencolor", iPos, g_esTank[type].g_sScreenColorVisual, sizeof esTank::g_sScreenColorVisual, g_esTank[type].g_sScreenColorVisual2, sizeof esTank::g_sScreenColorVisual2, g_esTank[type].g_sScreenColorVisual3, sizeof esTank::g_sScreenColorVisual3, g_esTank[type].g_sScreenColorVisual4, sizeof esTank::g_sScreenColorVisual4, sValue);
				}

				g_esTank[type].g_iStackLimits[iPos] = iGetClampedValue(key, "StackLimits", "Stack Limits", "Stack_Limits", "limits", g_esTank[type].g_iStackLimits[iPos], sSet[iPos], 0, 999999);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_GLOW, false))
		{
			if (StrEqual(key, "GlowColor", false) || StrEqual(key, "Glow Color", false) || StrEqual(key, "Glow_Color", false))
			{
				char sValue[64], sSet[3][4];
				vGetConfigColors(sValue, sizeof sValue, value);
				strcopy(g_esTank[type].g_sGlowColor, sizeof esTank::g_sGlowColor, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < sizeof esTank::g_iGlowColor; iPos++)
				{
					g_esTank[type].g_iGlowColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
				}
			}
			else if (StrEqual(key, "GlowRange", false) || StrEqual(key, "Glow Range", false) || StrEqual(key, "Glow_Range", false))
			{
				char sValue[50], sRange[2][7];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, "-", sRange, sizeof sRange, sizeof sRange[]);

				g_esTank[type].g_iGlowMinRange = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, 999999) : g_esTank[type].g_iGlowMinRange;
				g_esTank[type].g_iGlowMaxRange = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, 999999) : g_esTank[type].g_iGlowMaxRange;
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_BOSS, false))
		{
			char sValue[44], sSet[4][11];
			strcopy(sValue, sizeof sValue, value);
			ReplaceString(sValue, sizeof sValue, " ", "");
			ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
			for (int iPos = 0; iPos < sizeof esTank::g_iBossHealth; iPos++)
			{
				g_esTank[type].g_iBossHealth[iPos] = iGetClampedValue(key, "BossHealthStages", "Boss Health Stages", "Boss_Health_Stages", "bosshpstages", g_esTank[type].g_iBossHealth[iPos], sSet[iPos], 1, MT_MAXHEALTH);
				g_esTank[type].g_iBossType[iPos] = iGetClampedValue(key, "BossTypes", "Boss Types", "Boss_Types", "bosstypes", g_esTank[type].g_iBossType[iPos], sSet[iPos], 1, MT_MAXTYPES);
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_COMBO, false))
		{
			if (StrEqual(key, "ComboTypeChance", false) || StrEqual(key, "Combo Type Chance", false) || StrEqual(key, "Combo_Type_Chance", false) || StrEqual(key, "typechance", false))
			{
				char sValue[42], sSet[7][6];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < sizeof esTank::g_flComboTypeChance; iPos++)
				{
					g_esTank[type].g_flComboTypeChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[type].g_flComboTypeChance[iPos];
				}
			}
			else
			{
				char sValue[140], sSet[10][14];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < sizeof esTank::g_flComboChance; iPos++)
				{
					if (StrEqual(key, "ComboRadius", false) || StrEqual(key, "Combo Radius", false) || StrEqual(key, "Combo_Radius", false) || StrEqual(key, "radius", false))
					{
						char sRange[2][7], sSubset[14];
						strcopy(sSubset, sizeof sSubset, sSet[iPos]);
						ReplaceString(sSubset, sizeof sSubset, " ", "");
						ExplodeString(sSubset, ";", sRange, sizeof sRange, sizeof sRange[]);

						g_esTank[type].g_flComboMinRadius[iPos] = (sRange[0][0] != '\0') ? flClamp(StringToFloat(sRange[0]), -200.0, 0.0) : g_esTank[type].g_flComboMinRadius[iPos];
						g_esTank[type].g_flComboMaxRadius[iPos] = (sRange[1][0] != '\0') ? flClamp(StringToFloat(sRange[1]), 0.0, 200.0) : g_esTank[type].g_flComboMaxRadius[iPos];
					}
					else
					{
						g_esTank[type].g_flComboChance[iPos] = flGetClampedValue(key, "ComboChance", "Combo Chance", "Combo_Chance", "chance", g_esTank[type].g_flComboChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboDamage[iPos] = flGetClampedValue(key, "ComboDamage", "Combo Damage", "Combo_Damage", "damage", g_esTank[type].g_flComboDamage[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboDeathChance[iPos] = flGetClampedValue(key, "ComboDeathChance", "Combo Death Chance", "Combo_Death_Chance", "deathchance", g_esTank[type].g_flComboDeathChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboDeathRange[iPos] = flGetClampedValue(key, "ComboDeathRange", "Combo Death Range", "Combo_Death_Range", "deathrange", g_esTank[type].g_flComboDeathRange[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboDelay[iPos] = flGetClampedValue(key, "ComboDelay", "Combo Delay", "Combo_Delay", "delay", g_esTank[type].g_flComboDelay[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboDuration[iPos] = flGetClampedValue(key, "ComboDuration", "Combo Duration", "Combo_Duration", "duration", g_esTank[type].g_flComboDuration[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboInterval[iPos] = flGetClampedValue(key, "ComboInterval", "Combo Interval", "Combo_Interval", "interval", g_esTank[type].g_flComboInterval[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboRange[iPos] = flGetClampedValue(key, "ComboRange", "Combo Range", "Combo_Range", "range", g_esTank[type].g_flComboRange[iPos], sSet[iPos], 0.0, 999999.0);
						g_esTank[type].g_flComboRangeChance[iPos] = flGetClampedValue(key, "ComboRangeChance", "Combo Range Chance", "Combo_Range_Chance", "rangechance", g_esTank[type].g_flComboRangeChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboRockChance[iPos] = flGetClampedValue(key, "ComboRockChance", "Combo Rock Chance", "Combo_Rock_Chance", "rockchance", g_esTank[type].g_flComboRockChance[iPos], sSet[iPos], 0.0, 100.0);
						g_esTank[type].g_flComboSpeed[iPos] = flGetClampedValue(key, "ComboSpeed", "Combo Speed", "Combo_Speed", "speed", g_esTank[type].g_flComboSpeed[iPos], sSet[iPos], 0.0, 999999.0);
					}
				}
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_TRANSFORM, false))
		{
			if (StrEqual(key, "TransformTypes", false) || StrEqual(key, "Transform Types", false) || StrEqual(key, "Transform_Types", false) || StrEqual(key, "transtypes", false))
			{
				char sValue[50], sSet[10][5];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < sizeof esTank::g_iTransformType; iPos++)
				{
					g_esTank[type].g_iTransformType[iPos] = (sSet[iPos][0] != '\0') ? iClamp(StringToInt(sSet[iPos]), 1, MT_MAXTYPES) : g_esTank[type].g_iTransformType[iPos];
				}
			}
		}
		else if (StrEqual(sub, MT_CONFIG_SECTION_PROPS, false))
		{
			if (StrEqual(key, "PropsChance", false) || StrEqual(key, "Props Chance", false) || StrEqual(key, "Props_Chance", false) || StrEqual(key, "chance", false))
			{
				char sValue[54], sSet[9][6];
				strcopy(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < sizeof esTank::g_flPropsChance; iPos++)
				{
					g_esTank[type].g_flPropsChance[iPos] = (sSet[iPos][0] != '\0') ? flClamp(StringToFloat(sSet[iPos]), 0.0, 100.0) : g_esTank[type].g_flPropsChance[iPos];
				}
			}
			else
			{
				char sValue[64], sSet[4][4];
				vGetConfigColors(sValue, sizeof sValue, value);
				vSaveConfigColors(key, "OxygenTankColor", "Oxygen Tank Color", "Oxygen_Tank_Color", "oxygen", g_esTank[type].g_sOzTankColor, sizeof esTank::g_sOzTankColor, value);
				vSaveConfigColors(key, "FlameColor", "Flame Color", "Flame_Color", "flame", g_esTank[type].g_sFlameColor, sizeof esTank::g_sFlameColor, value);
				vSaveConfigColors(key, "RockColor", "Rock Color", "Rock_Color", "rock", g_esTank[type].g_sRockColor, sizeof esTank::g_sRockColor, value);
				vSaveConfigColors(key, "TireColor", "Tire Color", "Tire_Color", "tire", g_esTank[type].g_sTireColor, sizeof esTank::g_sTireColor, value);
				vSaveConfigColors(key, "PropaneTankColor", "Propane Tank Color", "Propane_Tank_Color", "propane", g_esTank[type].g_sPropTankColor, sizeof esTank::g_sPropTankColor, value);
				vSaveConfigColors(key, "FlashlightColor", "Flashlight Color", "Flashlight_Color", "flashlight", g_esTank[type].g_sFlashlightColor, sizeof esTank::g_sFlashlightColor, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < sizeof esTank::g_iLightColor; iPos++)
				{
					g_esTank[type].g_iLightColor[iPos] = iGetClampedValue(key, "LightColor", "Light Color", "Light_Color", "light", g_esTank[type].g_iLightColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iOzTankColor[iPos] = iGetClampedValue(key, "OxygenTankColor", "Oxygen Tank Color", "Oxygen_Tank_Color", "oxygen", g_esTank[type].g_iOzTankColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iFlameColor[iPos] = iGetClampedValue(key, "FlameColor", "Flame Color", "Flame_Color", "flame", g_esTank[type].g_iFlameColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iRockColor[iPos] = iGetClampedValue(key, "RockColor", "Rock Color", "Rock_Color", "rock", g_esTank[type].g_iRockColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iTireColor[iPos] = iGetClampedValue(key, "TireColor", "Tire Color", "Tire_Color", "tire", g_esTank[type].g_iTireColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iPropTankColor[iPos] = iGetClampedValue(key, "PropaneTankColor", "Propane Tank Color", "Propane_Tank_Color", "propane", g_esTank[type].g_iPropTankColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iFlashlightColor[iPos] = iGetClampedValue(key, "FlashlightColor", "Flashlight Color", "Flashlight_Color", "flashlight", g_esTank[type].g_iFlashlightColor[iPos], sSet[iPos], 0, 255, 0);
					g_esTank[type].g_iCrownColor[iPos] = iGetClampedValue(key, "CrownColor", "Crown Color", "Crown_Color", "crown", g_esTank[type].g_iCrownColor[iPos], sSet[iPos], 0, 255, 0);
				}
			}
		}

		if (g_esTank[type].g_iAbilityCount == -1 && (StrContains(sub, "ability", false) != -1 || (((!strncmp(key, "ability", 7, false) && StrContains(key, "enabled", false) != -1) || StrEqual(key, "aenabled", false) || (StrContains(key, " hit", false) != -1 && StrContains(key, "mode", false) == -1) || StrEqual(key, "hit", false)) && StringToInt(value) > 0)))
		{
			g_esTank[type].g_iAbilityCount = 0;
		}
		else if (g_esTank[type].g_iAbilityCount != -1 && (bFoundSection(sub, 0) || bFoundSection(sub, 1) || bFoundSection(sub, 2) || bFoundSection(sub, 3))
			&& ((StrContains(key, "enabled", false) != -1 || (StrContains(key, " hit", false) != -1 && StrContains(key, "mode", false) == -1) || StrEqual(key, "hit", false)) && StringToInt(value) > 0))
		{
			g_esTank[type].g_iAbilityCount++;
		}

		Call_StartForward(g_esGeneral.g_gfConfigsLoadedForward);
		Call_PushString(sub);
		Call_PushString(key);
		Call_PushString(value);
		Call_PushCell(type);
		Call_PushCell(-1);
		Call_PushCell(g_esGeneral.g_iConfigMode);
		Call_Finish();
	}
}

void vSaveConfigColors(const char[] key, const char[] setting1, const char[] setting2, const char[] setting3, const char[] setting4, char[] buffer, int size, const char[] value)
{
	if (StrEqual(key, setting1, false) || StrEqual(key, setting2, false) || StrEqual(key, setting3, false) || StrEqual(key, setting4, false))
	{
		strcopy(buffer, size, value);
	}
}

void vSetupConfigs()
{
	if (g_esGeneral.g_iConfigEnable == 1)
	{
		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_DIFFICULTY)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_PATH_DIFFICULTY);
			CreateDirectory(sSMPath, 511);

			char sDifficulty[11];
			for (int iDifficulty = 0; iDifficulty <= 3; iDifficulty++)
			{
				switch (iDifficulty)
				{
					case 0: sDifficulty = "Easy";
					case 1: sDifficulty = "Normal";
					case 2: sDifficulty = "Hard";
					case 3: sDifficulty = "Impossible";
				}

				vCreateConfigFile(MT_CONFIG_PATH_DIFFICULTY, sDifficulty);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_MAP)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, (g_bSecondGame ? MT_CONFIG_PATH_MAP2 : MT_CONFIG_PATH_MAP));
			CreateDirectory(sSMPath, 511);

			char sMapName[128];
			ArrayList alMaps = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
			if (alMaps != null)
			{
				int iSerial = -1;
				ReadMapList(alMaps, iSerial, "default", MAPLIST_FLAG_MAPSFOLDER);
				ReadMapList(alMaps, iSerial, "allexistingmaps__", MAPLIST_FLAG_MAPSFOLDER|MAPLIST_FLAG_NO_DEFAULT);

				int iListSize = alMaps.Length, iMapCount = (iListSize > 0) ? iListSize : 0;
				if (iMapCount > 0)
				{
					for (int iPos = 0; iPos < iMapCount; iPos++)
					{
						alMaps.GetString(iPos, sMapName, sizeof sMapName);
						vCreateConfigFile((g_bSecondGame ? MT_CONFIG_PATH_MAP2 : MT_CONFIG_PATH_MAP), sMapName);
					}
				}

				delete alMaps;
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_GAMEMODE)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, (g_bSecondGame ? MT_CONFIG_PATH_GAMEMODE2 : MT_CONFIG_PATH_GAMEMODE));
			CreateDirectory(sSMPath, 511);

			char sGameType[2049], sTypes[64][32];
			g_esGeneral.g_cvMTGameTypes.GetString(sGameType, sizeof sGameType);
			ReplaceString(sGameType, sizeof sGameType, " ", "");
			ExplodeString(sGameType, ",", sTypes, sizeof sTypes, sizeof sTypes[]);
			for (int iMode = 0; iMode < sizeof sTypes; iMode++)
			{
				if (StrContains(sGameType, sTypes[iMode]) != -1 && sTypes[iMode][0] != '\0')
				{
					vCreateConfigFile((g_bSecondGame ? MT_CONFIG_PATH_GAMEMODE2 : MT_CONFIG_PATH_GAMEMODE), sTypes[iMode]);
				}
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_DAY)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_PATH_DAY);
			CreateDirectory(sSMPath, 511);

			char sWeekday[32];
			for (int iDay = 0; iDay < 7; iDay++)
			{
				vGetDayName(iDay, sWeekday, sizeof sWeekday);
				vCreateConfigFile(MT_CONFIG_PATH_DAY, sWeekday);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_PLAYERCOUNT)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_PATH_PLAYERCOUNT);
			CreateDirectory(sSMPath, 511);

			char sPlayerCount[32];
			for (int iCount = 0; iCount <= (MAXPLAYERS + 1); iCount++)
			{
				IntToString(iCount, sPlayerCount, sizeof sPlayerCount);
				vCreateConfigFile(MT_CONFIG_PATH_PLAYERCOUNT, sPlayerCount);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_SURVIVORCOUNT)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_PATH_SURVIVORCOUNT);
			CreateDirectory(sSMPath, 511);

			char sPlayerCount[32];
			for (int iCount = 0; iCount <= (MAXPLAYERS + 1); iCount++)
			{
				IntToString(iCount, sPlayerCount, sizeof sPlayerCount);
				vCreateConfigFile(MT_CONFIG_PATH_SURVIVORCOUNT, sPlayerCount);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_INFECTEDCOUNT)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, MT_CONFIG_PATH_INFECTEDCOUNT);
			CreateDirectory(sSMPath, 511);

			char sPlayerCount[32];
			for (int iCount = 0; iCount <= (MAXPLAYERS + 1); iCount++)
			{
				IntToString(iCount, sPlayerCount, sizeof sPlayerCount);
				vCreateConfigFile(MT_CONFIG_PATH_INFECTEDCOUNT, sPlayerCount);
			}
		}

		if (g_esGeneral.g_iConfigCreate & MT_CONFIG_FINALE)
		{
			char sSMPath[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sSMPath, sizeof sSMPath, "%s%s", MT_CONFIG_PATH, (g_bSecondGame ? MT_CONFIG_PATH_FINALE2 : MT_CONFIG_PATH_FINALE));
			CreateDirectory(sSMPath, 511);

			char sEvent[32];
			int iLimit = g_bSecondGame ? 11 : 8;
			for (int iType = 0; iType < iLimit; iType++)
			{
				switch (iType)
				{
					case 0: sEvent = "finale_start";
					case 1: sEvent = "finale_escape_start";
					case 2: sEvent = "finale_vehicle_ready";
					case 3: sEvent = "finale_vehicle_leaving";
					case 4: sEvent = "finale_rush";
					case 5: sEvent = "finale_radio_start";
					case 6: sEvent = "finale_radio_damaged";
					case 7: sEvent = "finale_win";
					case 8: sEvent = "finale_vehicle_incoming";
					case 9: sEvent = "finale_bridge_lowering";
					case 10: sEvent = "gauntlet_finale_start";
				}

				vCreateConfigFile((g_bSecondGame ? MT_CONFIG_PATH_FINALE2 : MT_CONFIG_PATH_FINALE), sEvent);
			}
		}

		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_DIFFICULTY) && g_esGeneral.g_cvMTDifficulty != null)
		{
			char sDifficultyConfig[PLATFORM_MAX_PATH];
			if (bIsDifficultyConfigFound(sDifficultyConfig, sizeof sDifficultyConfig))
			{
				vCustomConfig(sDifficultyConfig);
				g_esGeneral.g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
			}
		}

		if ((g_esGeneral.g_iConfigExecute & MT_CONFIG_MAP))
		{
			char sMapConfig[PLATFORM_MAX_PATH];
			if (bIsMapConfigFound(sMapConfig, sizeof sMapConfig))
			{
				vCustomConfig(sMapConfig);
				g_esGeneral.g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_GAMEMODE)
		{
			char sModeConfig[PLATFORM_MAX_PATH];
			if (bIsGameModeConfigFound(sModeConfig, sizeof sModeConfig))
			{
				vCustomConfig(sModeConfig);
				g_esGeneral.g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_DAY)
		{
			char sDayConfig[PLATFORM_MAX_PATH];
			if (bIsDayConfigFound(sDayConfig, sizeof sDayConfig))
			{
				vCustomConfig(sDayConfig);
				g_esGeneral.g_iFileTimeOld[4] = GetFileTime(sDayConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_PLAYERCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sCountConfig, sizeof sCountConfig, "%s%s%i.cfg", MT_CONFIG_PATH, MT_CONFIG_PATH_PLAYERCOUNT, iGetPlayerCount());
			if (FileExists(sCountConfig, true))
			{
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iFileTimeOld[5] = GetFileTime(sCountConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_SURVIVORCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sCountConfig, sizeof sCountConfig, "%s%s%i.cfg", MT_CONFIG_PATH, MT_CONFIG_PATH_SURVIVORCOUNT, iGetHumanCount());
			if (FileExists(sCountConfig, true))
			{
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iFileTimeOld[6] = GetFileTime(sCountConfig, FileTime_LastChange);
			}
		}

		if (g_esGeneral.g_iConfigExecute & MT_CONFIG_INFECTEDCOUNT)
		{
			char sCountConfig[PLATFORM_MAX_PATH];
			BuildPath(Path_SM, sCountConfig, sizeof sCountConfig, "%s%s%i.cfg", MT_CONFIG_PATH, MT_CONFIG_PATH_INFECTEDCOUNT, iGetHumanCount(true));
			if (FileExists(sCountConfig, true))
			{
				vCustomConfig(sCountConfig);
				g_esGeneral.g_iFileTimeOld[7] = GetFileTime(sCountConfig, FileTime_LastChange);
			}
		}
	}
}