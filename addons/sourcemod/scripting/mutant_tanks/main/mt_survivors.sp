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

int g_iBossBeamSprite = -1, g_iBossHaloSprite = -1;

void vCheckClipSizes(int survivor)
{
	if (g_esGeneral.g_hSDKGetMaxClip1 != null)
	{
		int iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			g_esPlayer[survivor].g_iMaxClip[0] = SDKCall(g_esGeneral.g_hSDKGetMaxClip1, iSlot);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot > MaxClients)
		{
			char sWeapon[32];
			GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
			if (StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw"))
			{
				g_esPlayer[survivor].g_iMaxClip[1] = SDKCall(g_esGeneral.g_hSDKGetMaxClip1, iSlot);
			}
		}
	}
}

void vCopySurvivorStats(int oldSurvivor, int newSurvivor)
{
	g_esPlayer[newSurvivor].g_bFallDamage = g_esPlayer[oldSurvivor].g_bFallDamage;
	g_esPlayer[newSurvivor].g_bFalling = g_esPlayer[oldSurvivor].g_bFalling;
	g_esPlayer[newSurvivor].g_bFallTracked = g_esPlayer[oldSurvivor].g_bFallTracked;
	g_esPlayer[newSurvivor].g_bFatalFalling = g_esPlayer[oldSurvivor].g_bFatalFalling;
	g_esPlayer[newSurvivor].g_bSetup = g_esPlayer[oldSurvivor].g_bSetup;
	g_esPlayer[newSurvivor].g_bVomited = g_esPlayer[oldSurvivor].g_bVomited;
	g_esPlayer[newSurvivor].g_sLoopingVoiceline = g_esPlayer[oldSurvivor].g_sLoopingVoiceline;
	g_esPlayer[newSurvivor].g_flActionDuration = g_esPlayer[oldSurvivor].g_flActionDuration;
	g_esPlayer[newSurvivor].g_flAttackBoost = g_esPlayer[oldSurvivor].g_flAttackBoost;
	g_esPlayer[newSurvivor].g_flDamageBoost = g_esPlayer[oldSurvivor].g_flDamageBoost;
	g_esPlayer[newSurvivor].g_flDamageResistance = g_esPlayer[oldSurvivor].g_flDamageResistance;
	g_esPlayer[newSurvivor].g_flHealPercent = g_esPlayer[oldSurvivor].g_flHealPercent;
	g_esPlayer[newSurvivor].g_flJumpHeight = g_esPlayer[oldSurvivor].g_flJumpHeight;
	g_esPlayer[newSurvivor].g_flPreFallZ = g_esPlayer[oldSurvivor].g_flPreFallZ;
	g_esPlayer[newSurvivor].g_flShoveDamage = g_esPlayer[oldSurvivor].g_flShoveDamage;
	g_esPlayer[newSurvivor].g_flShoveRate = g_esPlayer[oldSurvivor].g_flShoveRate;
	g_esPlayer[newSurvivor].g_flSpeedBoost = g_esPlayer[oldSurvivor].g_flSpeedBoost;
	g_esPlayer[newSurvivor].g_iAmmoBoost = g_esPlayer[oldSurvivor].g_iAmmoBoost;
	g_esPlayer[newSurvivor].g_iAmmoRegen = g_esPlayer[oldSurvivor].g_iAmmoRegen;
	g_esPlayer[newSurvivor].g_iCleanKills = g_esPlayer[oldSurvivor].g_iCleanKills;
	g_esPlayer[newSurvivor].g_iFallPasses = g_esPlayer[oldSurvivor].g_iFallPasses;
	g_esPlayer[newSurvivor].g_iHealthRegen = g_esPlayer[oldSurvivor].g_iHealthRegen;
	g_esPlayer[newSurvivor].g_iHollowpointAmmo = g_esPlayer[oldSurvivor].g_iHollowpointAmmo;
	g_esPlayer[newSurvivor].g_iInfiniteAmmo = g_esPlayer[oldSurvivor].g_iInfiniteAmmo;
	g_esPlayer[newSurvivor].g_iLadderActions = g_esPlayer[oldSurvivor].g_iLadderActions;
	g_esPlayer[newSurvivor].g_iLifeLeech = g_esPlayer[oldSurvivor].g_iLifeLeech;
	g_esPlayer[newSurvivor].g_iMeleeRange = g_esPlayer[oldSurvivor].g_iMeleeRange;
	g_esPlayer[newSurvivor].g_iNotify = g_esPlayer[oldSurvivor].g_iNotify;
	g_esPlayer[newSurvivor].g_iPrefsAccess = g_esPlayer[oldSurvivor].g_iPrefsAccess;
	g_esPlayer[newSurvivor].g_iParticleEffect = g_esPlayer[oldSurvivor].g_iParticleEffect;
	g_esPlayer[newSurvivor].g_iReviveHealth = g_esPlayer[oldSurvivor].g_iReviveHealth;
	g_esPlayer[newSurvivor].g_iRewardTypes = g_esPlayer[oldSurvivor].g_iRewardTypes;
	g_esPlayer[newSurvivor].g_iShovePenalty = g_esPlayer[oldSurvivor].g_iShovePenalty;
	g_esPlayer[newSurvivor].g_iSledgehammerRounds = g_esPlayer[oldSurvivor].g_iSledgehammerRounds;
	g_esPlayer[newSurvivor].g_iSpecialAmmo = g_esPlayer[oldSurvivor].g_iSpecialAmmo;
	g_esPlayer[newSurvivor].g_iThorns = g_esPlayer[oldSurvivor].g_iThorns;
	g_esPlayer[newSurvivor].g_sBodyColor = g_esPlayer[oldSurvivor].g_sBodyColor;
	g_esPlayer[newSurvivor].g_sLightColor = g_esPlayer[oldSurvivor].g_sLightColor;
	g_esPlayer[newSurvivor].g_sOutlineColor = g_esPlayer[oldSurvivor].g_sOutlineColor;
	g_esPlayer[newSurvivor].g_sScreenColor = g_esPlayer[oldSurvivor].g_sScreenColor;

	for (int iPos = 0; iPos < sizeof esPlayer::g_flRewardTime; iPos++)
	{
		g_esPlayer[newSurvivor].g_flRewardTime[iPos] = g_esPlayer[oldSurvivor].g_flRewardTime[iPos];
		g_esPlayer[newSurvivor].g_iRewardStack[iPos] = g_esPlayer[oldSurvivor].g_iRewardStack[iPos];

		if (iPos < sizeof esPlayer::g_flVisualTime)
		{
			g_esPlayer[newSurvivor].g_flVisualTime[iPos] = g_esPlayer[oldSurvivor].g_flVisualTime[iPos];
		}

		if (iPos < sizeof esPlayer::g_iScreenColorVisual)
		{
			g_esPlayer[newSurvivor].g_iScreenColorVisual[iPos] = g_esPlayer[oldSurvivor].g_iScreenColorVisual[iPos];
		}
	}

	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		g_esPlayer[newSurvivor].g_iTankDamage[iTank] = g_esPlayer[oldSurvivor].g_iTankDamage[iTank];
	}

	if (g_esPlayer[oldSurvivor].g_bRainbowColor)
	{
		g_esPlayer[oldSurvivor].g_bRainbowColor = false;
		g_esPlayer[newSurvivor].g_bRainbowColor = SDKHookEx(newSurvivor, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
	}
}

void vGiveRandomMeleeWeapon(int survivor, bool specific, const char[] name = "")
{
	if (specific)
	{
		vCheatCommand(survivor, "give", ((name[0] != '\0') ? name : "machete"));

		if (GetPlayerWeaponSlot(survivor, 1) > MaxClients)
		{
			return;
		}

		vGiveRandomMeleeWeapon(survivor, false);
	}
	else
	{
		char sName[32];
		for (int iType = 1; iType < 13; iType++)
		{
			if (GetPlayerWeaponSlot(survivor, 1) > MaxClients)
			{
				break;
			}

			switch (iType)
			{
				case 1: sName = "machete";
				case 2: sName = "katana";
				case 3: sName = "fireaxe";
				case 4: sName = "shovel";
				case 5: sName = "baseball_bat";
				case 6: sName = "cricket_bat";
				case 7: sName = "golfclub";
				case 8: sName = "electric_guitar";
				case 9: sName = "frying_pan";
				case 10: sName = "tonfa";
				case 11: sName = "crowbar";
				case 12: sName = "knife";
				case 13: sName = "pitchfork";
			}

			vCheatCommand(survivor, "give", sName);
		}
	}
}

void vGiveSpecialAmmo(int survivor)
{
	int iType = ((bIsDeveloper(survivor, 7) || bIsDeveloper(survivor, 11)) && g_esDeveloper[survivor].g_iDevSpecialAmmo > g_esPlayer[survivor].g_iSpecialAmmo) ? g_esDeveloper[survivor].g_iDevSpecialAmmo : g_esPlayer[survivor].g_iSpecialAmmo;
	if (g_bSecondGame && iType > 0)
	{
		int iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			int iAmmoType = GetEntProp(iSlot, Prop_Send, "m_iPrimaryAmmoType");
			if (iAmmoType != 6 && iAmmoType != 17) // rifle_m60 and grenade_launcher
			{
				int iUpgrades = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");

				switch (iType)
				{
					case 1: iUpgrades = (iUpgrades & MT_UPGRADE_LASERSIGHT) ? MT_UPGRADE_LASERSIGHT|MT_UPGRADE_INCENDIARY : MT_UPGRADE_INCENDIARY;
					case 2: iUpgrades = (iUpgrades & MT_UPGRADE_LASERSIGHT) ? MT_UPGRADE_LASERSIGHT|MT_UPGRADE_EXPLOSIVE : MT_UPGRADE_EXPLOSIVE;
					case 3:
					{
						int iSpecialAmmo = (GetRandomInt(1, 2) == 2) ? MT_UPGRADE_INCENDIARY : MT_UPGRADE_EXPLOSIVE;
						iUpgrades = (iUpgrades & MT_UPGRADE_LASERSIGHT) ? MT_UPGRADE_LASERSIGHT|iSpecialAmmo : iSpecialAmmo;
					}
				}

				SetEntProp(iSlot, Prop_Send, "m_upgradeBitVec", iUpgrades);
				SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", GetEntProp(iSlot, Prop_Send, "m_iClip1"));
			}
		}
	}
}

void vGiveWeapons(int survivor)
{
	int iSlot = 0;
	if (g_esPlayer[survivor].g_sWeaponPrimary[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponPrimary);

		iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iWeaponInfo[0]);
			SetEntProp(survivor, Prop_Send, "m_iAmmo", g_esPlayer[survivor].g_iWeaponInfo[1], .element = iGetWeaponOffset(iSlot));

			if (g_bSecondGame)
			{
				if (g_esPlayer[survivor].g_iWeaponInfo[2] > 0)
				{
					SetEntProp(iSlot, Prop_Send, "m_upgradeBitVec", g_esPlayer[survivor].g_iWeaponInfo[2]);
				}

				if (g_esPlayer[survivor].g_iWeaponInfo[3] > 0)
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", g_esPlayer[survivor].g_iWeaponInfo[3]);
				}
			}
		}
	}

	if (g_esPlayer[survivor].g_sWeaponSecondary[0] != '\0')
	{
		switch (g_esPlayer[survivor].g_bDualWielding)
		{
			case true:
			{
				vCheatCommand(survivor, "give", "weapon_pistol");
				vCheatCommand(survivor, "give", "weapon_pistol");
			}
			case false: vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponSecondary);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot > MaxClients && g_esPlayer[survivor].g_iWeaponInfo2 != -1)
		{
			SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iWeaponInfo2);
		}
	}

	if (g_esPlayer[survivor].g_sWeaponThrowable[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponThrowable);
	}

	if (g_esPlayer[survivor].g_sWeaponMedkit[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponMedkit);
	}

	if (g_esPlayer[survivor].g_sWeaponPills[0] != '\0')
	{
		vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sWeaponPills);
	}

	for (int iPos = 0; iPos < sizeof esPlayer::g_iWeaponInfo; iPos++)
	{
		g_esPlayer[survivor].g_iWeaponInfo[iPos] = 0;
	}

	g_esPlayer[survivor].g_iWeaponInfo2 = -1;
	g_esPlayer[survivor].g_sWeaponPrimary[0] = '\0';
	g_esPlayer[survivor].g_sWeaponSecondary[0] = '\0';
	g_esPlayer[survivor].g_sWeaponThrowable[0] = '\0';
	g_esPlayer[survivor].g_sWeaponMedkit[0] = '\0';
	g_esPlayer[survivor].g_sWeaponPills[0] = '\0';
}

void vRefillAmmo(int survivor, bool all = false, bool reset = false)
{
	int iSetting = (bIsDeveloper(survivor, 7) && g_esDeveloper[survivor].g_iDevInfiniteAmmo > g_esPlayer[survivor].g_iInfiniteAmmo) ? g_esDeveloper[survivor].g_iDevInfiniteAmmo : g_esPlayer[survivor].g_iInfiniteAmmo;
	iSetting = all ? iSetting : 0;

	int iSlot;
	if (!all || (iSetting > 0 && (iSetting & MT_INFAMMO_PRIMARY)))
	{
		iSlot = GetPlayerWeaponSlot(survivor, 0);
		if (iSlot > MaxClients)
		{
			int iMaxClip = reset ? iGetMaxAmmo(survivor, 0, iSlot, false, true) : g_esPlayer[survivor].g_iMaxClip[0];
			if (!reset || (reset && GetEntProp(iSlot, Prop_Send, "m_iClip1") >= iMaxClip))
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", iMaxClip);
			}

			if (g_bSecondGame)
			{
				int iUpgrades = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");
				if ((iUpgrades & MT_UPGRADE_INCENDIARY) || (iUpgrades & MT_UPGRADE_EXPLOSIVE))
				{
					SetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", iMaxClip);
				}
			}

			vRefillMagazine(survivor, iSlot, reset);
		}
	}

	if (!all || (iSetting > 0 && (iSetting & MT_INFAMMO_SECONDARY)))
	{
		iSlot = GetPlayerWeaponSlot(survivor, 1);
		if (iSlot > MaxClients)
		{
			char sWeapon[32];
			GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
			if ((StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw")) && (!reset || (reset && GetEntProp(iSlot, Prop_Send, "m_iClip1") >= g_esPlayer[survivor].g_iMaxClip[1])))
			{
				SetEntProp(iSlot, Prop_Send, "m_iClip1", g_esPlayer[survivor].g_iMaxClip[1]);
			}
		}
	}

	if (all && iSetting > 0)
	{
		iSlot = GetPlayerWeaponSlot(survivor, 2);
		if (!bIsValidEntity(iSlot) && (iSetting & MT_INFAMMO_THROWABLE))
		{
			vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sStoredThrowable);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 3);
		if (!bIsValidEntity(iSlot) && (iSetting & MT_INFAMMO_MEDKIT))
		{
			vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sStoredMedkit);
		}

		iSlot = GetPlayerWeaponSlot(survivor, 4);
		if (!bIsValidEntity(iSlot) && (iSetting & MT_INFAMMO_PILLS))
		{
			vCheatCommand(survivor, "give", g_esPlayer[survivor].g_sStoredPills);
		}
	}
}

void vRefillHealth(int survivor)
{
	if (bIsSurvivorDisabled(survivor) || GetEntProp(survivor, Prop_Data, "m_iHealth") < GetEntProp(survivor, Prop_Data, "m_iMaxHealth"))
	{
		int iMode = GetEntProp(survivor, Prop_Data, "m_takedamage", 1);
		if (iMode != 2)
		{
			SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);
			vCheatCommand(survivor, "give", "health");
			SetEntProp(survivor, Prop_Data, "m_takedamage", iMode, 1);
		}
		else
		{
			vCheatCommand(survivor, "give", "health");
		}

		g_esPlayer[survivor].g_bLastLife = false;
		g_esPlayer[survivor].g_iReviveCount = 0;
	}
}

void vRefillMagazine(int survivor, int weapon, bool reset)
{
	int iAmmoOffset = iGetWeaponOffset(weapon), iNewAmmo = 0;

	switch (reset)
	{
		case true:
		{
			int iMaxAmmo = iGetMaxAmmo(survivor, 0, weapon, true, reset);
			if (GetEntProp(survivor, Prop_Send, "m_iAmmo", .element = iAmmoOffset) > iMaxAmmo)
			{
				iNewAmmo = iMaxAmmo;
			}
		}
		case false: iNewAmmo = iGetMaxAmmo(survivor, 0, weapon, true, reset);
	}

	if (iNewAmmo > 0)
	{
		SetEntProp(survivor, Prop_Send, "m_iAmmo", iNewAmmo, .element = iAmmoOffset);
	}
}

void vRemoveSurvivorEffects(int survivor, bool body = false)
{
	int iEffect = -1;
	for (int iPos = 0; iPos < sizeof esPlayer::g_iEffect; iPos++)
	{
		iEffect = g_esPlayer[survivor].g_iEffect[iPos];
		if (bIsValidEntRef(iEffect))
		{
			RemoveEntity(iEffect);
		}

		g_esPlayer[survivor].g_iEffect[iPos] = INVALID_ENT_REFERENCE;
	}

	if (body || bIsValidClient(survivor))
	{
		vRemoveGlow(survivor);
		vRemoveSurvivorLight(survivor);
		SetEntityRenderMode(survivor, RENDER_NORMAL);
		SetEntityRenderColor(survivor, 255, 255, 255, 255);
	}

	SDKUnhook(survivor, SDKHook_PostThinkPost, OnTankPostThinkPost);
}

void vRemoveSurvivorLight(int survivor)
{
	if (bIsValidEntRef(g_esPlayer[survivor].g_iFlashlight))
	{
		int iProp = EntRefToEntIndex(g_esPlayer[survivor].g_iFlashlight);
		if (bIsValidEntity(iProp))
		{
			RemoveEntity(iProp);
		}

		g_esPlayer[survivor].g_iFlashlight = INVALID_ENT_REFERENCE;
	}
}

void vResetSurvivorStats(int survivor, bool all)
{
	g_esDeveloper[survivor].g_bDevVisual = false;
	g_esPlayer[survivor].g_bFallDamage = false;
	g_esPlayer[survivor].g_bFalling = false;
	g_esPlayer[survivor].g_bFallTracked = false;
	g_esPlayer[survivor].g_bFatalFalling = false;
	g_esPlayer[survivor].g_bRainbowColor = false;
	g_esPlayer[survivor].g_bVomited = false;
	g_esPlayer[survivor].g_sLoopingVoiceline[0] = '\0';
	g_esPlayer[survivor].g_flActionDuration = 0.0;
	g_esPlayer[survivor].g_flAttackBoost = 0.0;
	g_esPlayer[survivor].g_flDamageBoost = 0.0;
	g_esPlayer[survivor].g_flDamageResistance = 0.0;
	g_esPlayer[survivor].g_flHealPercent = 0.0;
	g_esPlayer[survivor].g_flJumpHeight = 0.0;
	g_esPlayer[survivor].g_flPreFallZ = 0.0;
	g_esPlayer[survivor].g_flShoveDamage = 0.0;
	g_esPlayer[survivor].g_flShoveRate = 0.0;
	g_esPlayer[survivor].g_flSpeedBoost = 0.0;
	g_esPlayer[survivor].g_iAmmoBoost = 0;
	g_esPlayer[survivor].g_iAmmoRegen = 0;
	g_esPlayer[survivor].g_iCleanKills = 0;
	g_esPlayer[survivor].g_iFallPasses = 0;
	g_esPlayer[survivor].g_iHealthRegen = 0;
	g_esPlayer[survivor].g_iHollowpointAmmo = 0;
	g_esPlayer[survivor].g_iInfiniteAmmo = 0;
	g_esPlayer[survivor].g_iLadderActions = 0;
	g_esPlayer[survivor].g_iLifeLeech = 0;
	g_esPlayer[survivor].g_iMeleeRange = 0;
	g_esPlayer[survivor].g_iNotify = 0;
	g_esPlayer[survivor].g_iPrefsAccess = 0;
	g_esPlayer[survivor].g_iParticleEffect = 0;
	g_esPlayer[survivor].g_iReviveHealth = 0;
	g_esPlayer[survivor].g_iRewardTypes = 0;
	g_esPlayer[survivor].g_iShovePenalty = 0;
	g_esPlayer[survivor].g_iSledgehammerRounds = 0;
	g_esPlayer[survivor].g_iSpecialAmmo = 0;
	g_esPlayer[survivor].g_iThorns = 0;
	g_esPlayer[survivor].g_sBodyColor[0] = '\0';
	g_esPlayer[survivor].g_sLightColor[0] = '\0';
	g_esPlayer[survivor].g_sOutlineColor[0] = '\0';
	g_esPlayer[survivor].g_sScreenColor[0] = '\0';

	if (all)
	{
		g_esPlayer[survivor].g_bSetup = false;
	}

	for (int iPos = 0; iPos < sizeof esPlayer::g_flRewardTime; iPos++)
	{
		g_esPlayer[survivor].g_flRewardTime[iPos] = -1.0;
		g_esPlayer[survivor].g_iRewardStack[iPos] = 0;

		if (iPos < sizeof esPlayer::g_flVisualTime)
		{
			g_esPlayer[survivor].g_flVisualTime[iPos] = -1.0;
		}

		if (iPos < sizeof esPlayer::g_iScreenColorVisual)
		{
			g_esPlayer[survivor].g_iScreenColorVisual[iPos] = -1;
		}
	}
}

void vResetSurvivorStats2(int survivor)
{
	if (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_REFILL)
	{
		g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_REFILL;
	}

	if (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ITEM)
	{
		g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_ITEM;
	}

	if (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_RESPAWN)
	{
		g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_RESPAWN;
	}
}

void vRespawnSurvivor(int survivor)
{
	static int iIndex = -1;
	if (iIndex == -1)
	{
		iIndex = iGetPatchIndex("RespawnStats");
	}

	if (iIndex != -1)
	{
		bInstallPatch(iIndex);
	}
#if defined _l4dh_included
	switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKRoundRespawn == null)
	{
		case true: L4D_RespawnPlayer(survivor);
		case false: SDKCall(g_esGeneral.g_hSDKRoundRespawn, survivor);
	}
#else
	if (g_esGeneral.g_hSDKRoundRespawn != null)
	{
		SDKCall(g_esGeneral.g_hSDKRoundRespawn, survivor);
	}
#endif
	if (iIndex != -1)
	{
		bRemovePatch(iIndex);
	}
}

void vReviveSurvivor(int survivor)
{
#if defined _l4dh_included
	switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKRevive == null)
	{
		case true: L4D_ReviveSurvivor(survivor);
		case false: SDKCall(g_esGeneral.g_hSDKRevive, survivor);
	}
#else
	if (g_esGeneral.g_hSDKRevive != null)
	{
		SDKCall(g_esGeneral.g_hSDKRevive, survivor);
	}
#endif
}

void vSaveCaughtSurvivor(int survivor, int special = 0)
{
	int iSpecial = special;
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pounceAttacker") : iSpecial;
	iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_tongueOwner") : iSpecial;
	if (g_bSecondGame)
	{
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_pummelAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_carryAttacker") : iSpecial;
		iSpecial = (iSpecial <= 0) ? GetEntPropEnt(survivor, Prop_Send, "m_jockeyAttacker") : iSpecial;
	}

	if (iSpecial > 0)
	{
		SDKHooks_TakeDamage(iSpecial, survivor, survivor, float(GetEntProp(iSpecial, Prop_Data, "m_iHealth")));
	}
}

void vSaveWeapons(int survivor)
{
	char sWeapon[32];
	g_esPlayer[survivor].g_iWeaponInfo2 = -1;
	int iSlot = GetPlayerWeaponSlot(survivor, 0);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
		strcopy(g_esPlayer[survivor].g_sWeaponPrimary, sizeof esPlayer::g_sWeaponPrimary, sWeapon);

		g_esPlayer[survivor].g_iWeaponInfo[0] = GetEntProp(iSlot, Prop_Send, "m_iClip1");
		g_esPlayer[survivor].g_iWeaponInfo[1] = GetEntProp(survivor, Prop_Send, "m_iAmmo", .element = iGetWeaponOffset(iSlot));

		if (g_bSecondGame)
		{
			g_esPlayer[survivor].g_iWeaponInfo[2] = GetEntProp(iSlot, Prop_Send, "m_upgradeBitVec");
			g_esPlayer[survivor].g_iWeaponInfo[3] = GetEntProp(iSlot, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
		}
	}

	iSlot = 0;
	if (g_bSecondGame)
	{
		if (bIsSurvivorDisabled(survivor) && g_esGeneral.g_iMeleeOffset != -1)
		{
			int iMelee = GetEntDataEnt2(survivor, g_esGeneral.g_iMeleeOffset);

			switch (bIsValidEntity(iMelee))
			{
				case true: iSlot = iMelee;
				case false: iSlot = GetPlayerWeaponSlot(survivor, 1);
			}
		}
		else
		{
			iSlot = GetPlayerWeaponSlot(survivor, 1);
		}
	}
	else
	{
		iSlot = GetPlayerWeaponSlot(survivor, 1);
	}

	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
		if (StrEqual(sWeapon, "weapon_melee"))
		{
			GetEntPropString(iSlot, Prop_Data, "m_strMapSetScriptName", sWeapon, sizeof sWeapon);
		}

		strcopy(g_esPlayer[survivor].g_sWeaponSecondary, sizeof esPlayer::g_sWeaponSecondary, sWeapon);
		if (StrContains(sWeapon, "pistol") != -1 || StrEqual(sWeapon, "weapon_chainsaw"))
		{
			g_esPlayer[survivor].g_iWeaponInfo2 = GetEntProp(iSlot, Prop_Send, "m_iClip1");
		}

		g_esPlayer[survivor].g_bDualWielding = StrContains(sWeapon, "pistol") != -1 && GetEntProp(iSlot, Prop_Send, "m_isDualWielding") > 0;
	}

	iSlot = GetPlayerWeaponSlot(survivor, 2);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
		strcopy(g_esPlayer[survivor].g_sWeaponThrowable, sizeof esPlayer::g_sWeaponThrowable, sWeapon);
	}

	iSlot = GetPlayerWeaponSlot(survivor, 3);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
		strcopy(g_esPlayer[survivor].g_sWeaponMedkit, sizeof esPlayer::g_sWeaponMedkit, sWeapon);
	}

	iSlot = GetPlayerWeaponSlot(survivor, 4);
	if (iSlot > MaxClients)
	{
		GetEntityClassname(iSlot, sWeapon, sizeof sWeapon);
		strcopy(g_esPlayer[survivor].g_sWeaponPills, sizeof esPlayer::g_sWeaponPills, sWeapon);
	}
}

void vSetSurvivorColor(int survivor, const char[] colors, bool apply = true, const char[] delimiter = ";", bool save = false)
{
	if (!save && !bIsDeveloper(survivor, 0))
	{
		return;
	}

	char sColor[64];
	strcopy(sColor, sizeof sColor, colors);
	if (StrEqual(sColor, "rainbow", false))
	{
		if (!g_esPlayer[survivor].g_bRainbowColor)
		{
			g_esPlayer[survivor].g_bRainbowColor = SDKHookEx(survivor, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
		}

		return;
	}

	char sValue[4][4];
	vGetConfigColors(sColor, sizeof sColor, colors);
	ExplodeString(sColor, delimiter, sValue, sizeof sValue, sizeof sValue[]);

	int iColor[4];
	for (int iPos = 0; iPos < sizeof sValue; iPos++)
	{
		if (sValue[iPos][0] != '\0')
		{
			iColor[iPos] = iGetRandomColor(StringToInt(sValue[iPos]));
		}
	}

	switch (apply)
	{
		case true:
		{
			switch (iColor[3] < 255)
			{
				case true: SetEntityRenderMode(survivor, RENDER_TRANSCOLOR);
				case false: SetEntityRenderMode(survivor, RENDER_NORMAL);
			}

			SetEntityRenderColor(survivor, iColor[0], iColor[1], iColor[2], iColor[3]);
		}
		case false:
		{
			SetEntityRenderMode(survivor, RENDER_NORMAL);
			SetEntityRenderColor(survivor, 255, 255, 255, 255);
		}
	}
}

void vSetSurvivorEffects(int survivor, int effects)
{
	if (effects & MT_ROCK_BLOOD)
	{
		vAttachParticle(survivor, PARTICLE_BLOOD, 0.75, 30.0);
	}

	if (effects & MT_ROCK_ELECTRICITY)
	{
		switch (bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
		{
			case true: vAttachParticle(survivor, PARTICLE_ELECTRICITY, 0.75, 30.0);
			case false:
			{
				for (int iCount = 1; iCount < 4; iCount++)
				{
					vAttachParticle(survivor, PARTICLE_ELECTRICITY, 0.75, (1.0 * float(iCount * 15)));
				}
			}
		}
	}

	if (effects & MT_ROCK_FIRE)
	{
		vAttachParticle(survivor, PARTICLE_FIRE, 0.75);
	}

	if (effects & MT_ROCK_SPIT)
	{
		switch (g_bSecondGame)
		{
			case true: vAttachParticle(survivor, PARTICLE_SPIT, 0.75, 30.0);
			case false: vAttachParticle(survivor, PARTICLE_BLOOD, 0.75, 30.0);
		}
	}
}

void vSetSurvivorGlow(int survivor, int red, int green, int blue)
{
	if (!g_bSecondGame)
	{
		return;
	}

	SetEntProp(survivor, Prop_Send, "m_glowColorOverride", iGetRGBColor(red, green, blue));
	SetEntProp(survivor, Prop_Send, "m_bFlashing", 0);
	SetEntProp(survivor, Prop_Send, "m_nGlowRangeMin", 0);
	SetEntProp(survivor, Prop_Send, "m_nGlowRange", 999999);
	SetEntProp(survivor, Prop_Send, "m_iGlowType", 3);
}

void vSetSurvivorFlashlight(int survivor, int colors[4])
{
	if (g_esPlayer[survivor].g_iFlashlight == 0 || g_esPlayer[survivor].g_iFlashlight == INVALID_ENT_REFERENCE)
	{
		float flOrigin[3], flAngles[3];
		GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(survivor, Prop_Send, "m_angRotation", flAngles);
		vFlashlightProp(survivor, flOrigin, flAngles, colors);
	}
	else if (bIsValidEntRef(g_esPlayer[survivor].g_iFlashlight))
	{
		int iProp = EntRefToEntIndex(g_esPlayer[survivor].g_iFlashlight);
		if (bIsValidEntity(iProp))
		{
			char sColor[16];
			FormatEx(sColor, sizeof sColor, "%i %i %i %i", iGetRandomColor(colors[0]), iGetRandomColor(colors[1]), iGetRandomColor(colors[2]), iGetRandomColor(colors[3]));
			DispatchKeyValue(g_esPlayer[survivor].g_iFlashlight, "_light", sColor);
		}
	}
}

void vSetSurvivorLight(int survivor, const char[] colors, bool apply = true, const char[] delimiter = ";", bool save = false)
{
	if (!save && !bIsDeveloper(survivor, 0))
	{
		return;
	}

	char sColor[64];
	strcopy(sColor, sizeof sColor, colors);
	if (StrEqual(sColor, "rainbow", false))
	{
		if (!g_esPlayer[survivor].g_bRainbowColor)
		{
			g_esPlayer[survivor].g_bRainbowColor = SDKHookEx(survivor, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
		}

		return;
	}

	char sValue[4][4];
	vGetConfigColors(sColor, sizeof sColor, colors);
	ExplodeString(sColor, delimiter, sValue, sizeof sValue, sizeof sValue[]);

	int iColor[4];
	for (int iPos = 0; iPos < sizeof sValue; iPos++)
	{
		if (sValue[iPos][0] != '\0')
		{
			iColor[iPos] = iGetRandomColor(StringToInt(sValue[iPos]));
		}
	}

	switch (apply)
	{
		case true: vSetSurvivorFlashlight(survivor, iColor);
		case false: vRemoveSurvivorLight(survivor);
	}
}

void vSetSurvivorOutline(int survivor, const char[] colors, bool apply = true, const char[] delimiter = ";", bool save = false)
{
	if (!g_bSecondGame || (!save && !bIsDeveloper(survivor, 0)))
	{
		return;
	}

	char sColor[64];
	strcopy(sColor, sizeof sColor, colors);
	if (StrEqual(sColor, "rainbow", false))
	{
		if (!g_esPlayer[survivor].g_bRainbowColor)
		{
			g_esPlayer[survivor].g_bRainbowColor = SDKHookEx(survivor, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
		}

		return;
	}

	char sValue[3][4];
	vGetConfigColors(sColor, sizeof sColor, colors);
	ExplodeString(sColor, delimiter, sValue, sizeof sValue, sizeof sValue[]);

	int iColor[3];
	for (int iPos = 0; iPos < sizeof sValue; iPos++)
	{
		if (sValue[iPos][0] != '\0')
		{
			iColor[iPos] = iGetRandomColor(StringToInt(sValue[iPos]));
		}
	}

	switch (apply)
	{
		case true: vSetSurvivorGlow(survivor, iColor[0], iColor[1], iColor[2]);
		case false: vRemoveGlow(survivor);
	}
}

void vSetSurvivorParticle(int survivor)
{
	if (!g_esDeveloper[survivor].g_bDevVisual)
	{
		g_esDeveloper[survivor].g_bDevVisual = true;

		CreateTimer(0.75, tTimerDevParticle, GetClientUserId(survivor), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vSetSurvivorScreen(int survivor, const char[] colors, const char[] delimiter = ";")
{
	char sColor[64];
	strcopy(sColor, sizeof sColor, colors);
	if (StrEqual(sColor, "rainbow", false))
	{
		if (!g_esPlayer[survivor].g_bRainbowColor)
		{
			g_esPlayer[survivor].g_bRainbowColor = SDKHookEx(survivor, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
		}

		return;
	}

	char sValue[4][4];
	ExplodeString(colors, delimiter, sValue, sizeof sValue, sizeof sValue[]);
	for (int iPos = 0; iPos < sizeof sValue; iPos++)
	{
		if (sValue[iPos][0] != '\0')
		{
			g_esPlayer[survivor].g_iScreenColorVisual[iPos] = iGetRandomColor(StringToInt(sValue[iPos]));
		}
	}
}

void vSetSurvivorWeaponSkin(int developer)
{
	int iActiveWeapon = GetEntPropEnt(developer, Prop_Send, "m_hActiveWeapon");
	if (bIsValidEntity(iActiveWeapon))
	{
		int iSkin = iClamp(g_esDeveloper[developer].g_iDevWeaponSkin, -1, iGetMaxWeaponSkins(developer));
		if (iSkin != -1 && iSkin != GetEntProp(iActiveWeapon, Prop_Send, "m_nSkin"))
		{
			SetEntProp(iActiveWeapon, Prop_Send, "m_nSkin", iSkin);

			int iViewWeapon = GetEntPropEnt(developer, Prop_Send, "m_hViewModel");
			if (bIsValidEntity(iViewWeapon))
			{
				SetEntProp(iViewWeapon, Prop_Send, "m_nSkin", iSkin);
			}
		}
	}
}

void vSetupAdmin(int admin, const char[] keyword, const char[] value)
{
	if (StrContains(keyword, "effect", false) != -1 || StrContains(keyword, "particle", false) != -1)
	{
		g_esDeveloper[admin].g_iDevParticle = iClamp(StringToInt(value), 0, 15);

		switch (StringToInt(value) == 0)
		{
			case true: g_esDeveloper[admin].g_bDevVisual = false;
			case false: vSetSurvivorParticle(admin);
		}
#if defined _clientprefs_included
		g_esGeneral.g_ckMTAdmin[1].Set(admin, value);
#endif
	}
	else if (StrContains(keyword, "glow", false) != -1 || StrContains(keyword, "outline", false) != -1)
	{
		switch (StrEqual(value, "0"))
		{
			case true:
			{
				g_esDeveloper[admin].g_sDevGlowOutline[0] = '\0';

				vToggleSurvivorEffects(admin, true, 5);
			}
			case false:
			{
				strcopy(g_esDeveloper[admin].g_sDevGlowOutline, sizeof esDeveloper::g_sDevGlowOutline, value);
				vSetSurvivorOutline(admin, g_esDeveloper[admin].g_sDevGlowOutline, .delimiter = ",");
			}
		}
#if defined _clientprefs_included
		g_esGeneral.g_ckMTAdmin[2].Set(admin, value);
#endif
	}
	else if (StrContains(keyword, "light", false) != -1 || StrContains(keyword, "flash", false) != -1)
	{
		switch (StrEqual(value, "0"))
		{
			case true:
			{
				g_esDeveloper[admin].g_sDevFlashlight[0] = '\0';

				vToggleSurvivorEffects(admin, true, 3);
			}
			case false:
			{
				strcopy(g_esDeveloper[admin].g_sDevFlashlight, sizeof esDeveloper::g_sDevFlashlight, value);
				vSetSurvivorLight(admin, g_esDeveloper[admin].g_sDevFlashlight, .delimiter = ",");
			}
		}
#if defined _clientprefs_included
		g_esGeneral.g_ckMTAdmin[3].Set(admin, value);
#endif
	}
	else if (StrContains(keyword, "skin", false) != -1 || StrContains(keyword, "color", false) != -1)
	{
		switch (StrEqual(value, "0"))
		{
			case true:
			{
				g_esDeveloper[admin].g_sDevSkinColor[0] = '\0';

				vToggleSurvivorEffects(admin, true, 4);
			}
			case false:
			{
				strcopy(g_esDeveloper[admin].g_sDevSkinColor, sizeof esDeveloper::g_sDevSkinColor, value);
				vSetSurvivorColor(admin, g_esDeveloper[admin].g_sDevSkinColor, .delimiter = ",");
			}
		}
#if defined _clientprefs_included
		g_esGeneral.g_ckMTAdmin[4].Set(admin, value);
#endif
	}

	vAdminPanel(admin);
}

void vSetupDeveloper(int developer, bool setup = true, bool usual = false)
{
	if (setup)
	{
		if (bIsSurvivor(developer))
		{
			vSetupLoadout(developer, usual);
			vGiveSpecialAmmo(developer);
			vCheckClipSizes(developer);

			if (bIsDeveloper(developer, 0))
			{
				vSetSurvivorLight(developer, g_esDeveloper[developer].g_sDevFlashlight, .delimiter = ",");
				vSetSurvivorOutline(developer, g_esDeveloper[developer].g_sDevGlowOutline, .delimiter = ",");
				vSetSurvivorColor(developer, g_esDeveloper[developer].g_sDevSkinColor, .delimiter = ",");
				vSetSurvivorParticle(developer);
			}
			else if (g_esDeveloper[developer].g_bDevVisual)
			{
				g_esDeveloper[developer].g_bDevVisual = false;

				vToggleSurvivorEffects(developer);
			}

			switch (bIsDeveloper(developer, 5) || (g_esPlayer[developer].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				case true:
				{
					vSetAdrenalineTime(developer, 999999.0);
					SDKHook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
				}
				case false:
				{
					vSetAdrenalineTime(developer, 0.0);
					SDKUnhook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
					SetEntPropFloat(developer, Prop_Send, "m_flLaggedMovementValue", 1.0);
				}
			}

			switch (bIsDeveloper(developer, 6) || (g_esPlayer[developer].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
			{
				case true: SDKHook(developer, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
				case false: SDKUnhook(developer, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
			}

			switch (bIsDeveloper(developer, 11) || (g_esPlayer[developer].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				case true:
				{
					if (g_esPlayer[developer].g_bVomited)
					{
						vUnvomitPlayer(developer);
					}

					vSaveCaughtSurvivor(developer);
					SetEntProp(developer, Prop_Data, "m_takedamage", 0, 1);
				}
				case false: SetEntProp(developer, Prop_Data, "m_takedamage", 2, 1);
			}
		}
	}
	else if (bIsValidClient(developer))
	{
		SDKUnhook(developer, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
		SDKUnhook(developer, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);

		if (bIsValidClient(developer, MT_CHECK_ALIVE))
		{
			if (g_esDeveloper[developer].g_bDevVisual)
			{
				vToggleSurvivorEffects(developer);
			}

			if (!(g_esPlayer[developer].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				vSetAdrenalineTime(developer, 0.0);
				SetEntPropFloat(developer, Prop_Send, "m_flLaggedMovementValue", 1.0);
			}

			vCheckClipSizes(developer);

			if (!(g_esPlayer[developer].g_iRewardTypes & MT_REWARD_AMMO))
			{
				vRefillAmmo(developer, .reset = true);
			}

			if (!(g_esPlayer[developer].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				SetEntProp(developer, Prop_Data, "m_takedamage", 2, 1);
			}
		}

		g_esDeveloper[developer].g_bDevVisual = false;
	}
}

void vSetupGuest(int guest, const char[] keyword, const char[] value)
{
	bool bPanel = false;
	if (StrContains(keyword, "access", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevAccess = iClamp(StringToInt(value), 0, 4095);

		vSetupDeveloper(guest, (g_esDeveloper[guest].g_iDevAccess > 0), true);
	}
	else if (StrContains(keyword, "action", false) != -1 || StrContains(keyword, "actdur", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevActionDuration = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "regenammo", false) != -1 || StrContains(keyword, "ammoregen", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevAmmoRegen = iClamp(StringToInt(value), 0, 999999);
	}
	else if (StrContains(keyword, "attack", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevAttackBoost = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "dmgboost", false) != -1 || StrContains(keyword, "damageboost", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevDamageBoost = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "dmgres", false) != -1 || StrContains(keyword, "damageres", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevDamageResistance = flClamp(StringToFloat(value), 0.0, 0.99);
	}
	else if (StrContains(keyword, "effect", false) != -1 || StrContains(keyword, "particle", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevParticle = iClamp(StringToInt(value), 0, 15);
	}
	else if (StrContains(keyword, "fall", false) != -1 || StrContains(keyword, "scream", false) != -1 || StrContains(keyword, "voice", false) != -1)
	{
		bPanel = true;

		strcopy(g_esDeveloper[guest].g_sDevFallVoiceline, sizeof esDeveloper::g_sDevFallVoiceline, value);
	}
	else if (StrContains(keyword, "glow", false) != -1 || StrContains(keyword, "outline", false) != -1)
	{
		bPanel = true;

		strcopy(g_esDeveloper[guest].g_sDevGlowOutline, sizeof esDeveloper::g_sDevGlowOutline, value);
		vSetSurvivorOutline(guest, g_esDeveloper[guest].g_sDevGlowOutline, .delimiter = ",");
	}
	else if (StrContains(keyword, "heal", false) != -1 || StrContains(keyword, "hppercent", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevHealPercent = flClamp(StringToFloat(value), 0.0, 100.0);
	}
	else if (StrContains(keyword, "regenhp", false) != -1 || StrContains(keyword, "hpregen", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevHealthRegen = iClamp(StringToInt(value), 0, MT_MAXHEALTH);
	}
	else if (StrContains(keyword, "infammo", false) != -1 || StrContains(keyword, "infinite", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevInfiniteAmmo = iClamp(StringToInt(value), 0, 31);
	}
	else if (StrContains(keyword, "jump", false) != -1 || StrContains(keyword, "height", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevJumpHeight = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "leechhp", false) != -1 || StrContains(keyword, "hpleech", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevLifeLeech = iClamp(StringToInt(value), 0, MT_MAXHEALTH);
	}
	else if (StrContains(keyword, "light", false) != -1 || StrContains(keyword, "flash", false) != -1)
	{
		bPanel = true;

		strcopy(g_esDeveloper[guest].g_sDevFlashlight, sizeof esDeveloper::g_sDevFlashlight, value);
		vSetSurvivorLight(guest, g_esDeveloper[guest].g_sDevFlashlight, .delimiter = ",");
	}
	else if (StrContains(keyword, "loadout", false) != -1 || StrContains(keyword, "weapons", false) != -1)
	{
		bPanel = true;

		strcopy(g_esDeveloper[guest].g_sDevLoadout, sizeof esDeveloper::g_sDevLoadout, value);
		vSetupLoadout(guest);
	}
	else if (StrContains(keyword, "melee", false) != -1 || StrContains(keyword, "range", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevMeleeRange = iClamp(StringToInt(value), 0, 999999);
	}
	else if (StrContains(keyword, "punch", false) != -1 || StrContains(keyword, "force", false) != -1 || StrContains(keyword, "punchres", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevPunchResistance = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "revivehp", false) != -1 || StrContains(keyword, "hprevive", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevReviveHealth = iClamp(StringToInt(value), 0, MT_MAXHEALTH);
	}
	else if (StrContains(keyword, "rdur", false) != -1 || StrContains(keyword, "rewarddur", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevRewardDuration = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "rtypes", false) != -1 || StrContains(keyword, "rewardtypes", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevRewardTypes = iClamp(StringToInt(value), -1, 2147483647);
	}
	else if (StrContains(keyword, "sdmg", false) != -1 || StrContains(keyword, "shovedmg", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevShoveDamage = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "srate", false) != -1 || StrContains(keyword, "shoverate", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevShoveRate = flClamp(StringToFloat(value), 0.0, 999999.0);
	}
	else if (StrContains(keyword, "survskin", false) != -1 || StrContains(keyword, "color", false) != -1)
	{
		bPanel = true;

		strcopy(g_esDeveloper[guest].g_sDevSkinColor, sizeof esDeveloper::g_sDevSkinColor, value);
		vSetSurvivorColor(guest, g_esDeveloper[guest].g_sDevSkinColor, .delimiter = ",");
	}
	else if (StrContains(keyword, "specammo", false) != -1 || StrContains(keyword, "special", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevSpecialAmmo = iClamp(StringToInt(value), 0, 3);

		vGiveSpecialAmmo(guest);
	}
	else if (StrContains(keyword, "speed", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_flDevSpeedBoost = flClamp(StringToFloat(value), 0.0, 999999.0);

		vSetAdrenalineTime(guest, 999999.0);
	}
	else if (StrContains(keyword, "wepskin", false) != -1 || StrContains(keyword, "skin", false) != -1)
	{
		bPanel = true;
		g_esDeveloper[guest].g_iDevWeaponSkin = iClamp(StringToInt(value), -1, iGetMaxWeaponSkins(guest));

		vSetSurvivorWeaponSkin(guest);
	}
	else if (StrContains(keyword, "config", false) != -1)
	{
		bPanel = !!StringToInt(value);

		cmdMTConfig2(guest, 0);
	}
	else if (StrContains(keyword, "list", false) != -1)
	{
		bPanel = !!StringToInt(value);

		cmdMTList2(guest, 0);
	}
	else if (StrContains(keyword, "tank", false) != -1)
	{
		bPanel = !!StringToInt(value);

		cmdTank2(guest, 0);
	}
	else if (StrContains(keyword, "version", false) != -1)
	{
		bPanel = !!StringToInt(value);

		cmdMTVersion2(guest, 0);
	}

	if (bPanel)
	{
		vDeveloperPanel(guest);
	}
}

void vSetupLoadout(int developer, bool usual = true)
{
	if (bIsDeveloper(developer, 2))
	{
		vRemoveWeapons(developer);

		if (usual)
		{
			char sSet[6][64];
			ExplodeString(g_esDeveloper[developer].g_sDevLoadout, ";", sSet, sizeof sSet, sizeof sSet[]);
			vCheatCommand(developer, "give", "health");

			switch (g_bSecondGame && StrContains(sSet[1], "pistol") == -1 && StrContains(sSet[1], "chainsaw") == -1)
			{
				case true:
				{
					if (sSet[1][0] != '\0')
					{
						vGiveRandomMeleeWeapon(developer, usual, sSet[1]);
					}
				}
				case false:
				{
					if (sSet[1][0] != '\0')
					{
						vCheatCommand(developer, "give", sSet[1]);
					}

					if (sSet[5][0] != '\0')
					{
						vCheatCommand(developer, "give", sSet[5]);
					}
				}
			}

			for (int iPos = 0; iPos < (sizeof sSet - 1); iPos++)
			{
				if (iPos != 1 && sSet[iPos][0] != '\0')
				{
					vCheatCommand(developer, "give", sSet[iPos]);
				}
			}
		}
		else
		{
			if (g_bSecondGame)
			{
				vGiveRandomMeleeWeapon(developer, usual);

				switch (GetRandomInt(1, 5))
				{
					case 1: vCheatCommand(developer, "give", "shotgun_spas");
					case 2: vCheatCommand(developer, "give", "autoshotgun");
					case 3: vCheatCommand(developer, "give", "rifle_ak47");
					case 4: vCheatCommand(developer, "give", "rifle");
					case 5: vCheatCommand(developer, "give", "sniper_military");
				}

				switch (GetRandomInt(1, 3))
				{
					case 1: vCheatCommand(developer, "give", "molotov");
					case 2: vCheatCommand(developer, "give", "pipe_bomb");
					case 3: vCheatCommand(developer, "give", "vomitjar");
				}

				switch (GetRandomInt(1, 2))
				{
					case 1: vCheatCommand(developer, "give", "first_aid_kit");
					case 2: vCheatCommand(developer, "give", "defibrillator");
				}

				switch (GetRandomInt(1, 2))
				{
					case 1: vCheatCommand(developer, "give", "pain_pills");
					case 2: vCheatCommand(developer, "give", "adrenaline");
				}
			}
			else
			{
				switch (GetRandomInt(1, 3))
				{
					case 1: vCheatCommand(developer, "give", "autoshotgun");
					case 2: vCheatCommand(developer, "give", "rifle");
					case 3: vCheatCommand(developer, "give", "hunting_rifle");
				}

				switch (GetRandomInt(1, 2))
				{
					case 1: vCheatCommand(developer, "give", "molotov");
					case 2: vCheatCommand(developer, "give", "pipe_bomb");
				}

				vCheatCommand(developer, "give", "pistol");
				vCheatCommand(developer, "give", "pistol");
				vCheatCommand(developer, "give", "first_aid_kit");
				vCheatCommand(developer, "give", "pain_pills");
			}
		}

		vCheckClipSizes(developer);
	}
}

void vSetupPerks(int admin, bool setup = true)
{
	if (setup)
	{
		if (bIsSurvivor(admin))
		{
			if (bIsDeveloper(admin, 0))
			{
				if (g_esDeveloper[admin].g_sDevFlashlight[0] != '\0')
				{
					vSetSurvivorLight(admin, g_esDeveloper[admin].g_sDevFlashlight, .delimiter = ",");
				}

				if (g_esDeveloper[admin].g_sDevGlowOutline[0] != '\0')
				{
					vSetSurvivorOutline(admin, g_esDeveloper[admin].g_sDevGlowOutline, .delimiter = ",");
				}

				if (g_esDeveloper[admin].g_sDevSkinColor[0] != '\0')
				{
					vSetSurvivorColor(admin, g_esDeveloper[admin].g_sDevSkinColor, .delimiter = ",");
				}

				vSetSurvivorParticle(admin);
			}
			else if (g_esDeveloper[admin].g_bDevVisual)
			{
				g_esDeveloper[admin].g_bDevVisual = false;

				vToggleSurvivorEffects(admin);
			}
		}
	}
	else if (bIsValidClient(admin))
	{
		if (bIsValidClient(admin, MT_CHECK_ALIVE) && g_esDeveloper[admin].g_bDevVisual)
		{
			vToggleSurvivorEffects(admin);
		}

		g_esDeveloper[admin].g_bDevVisual = false;
	}
}

void vSurvivorReactions(int tank)
{
	char sModel[40];
	float flTankPos[3], flSurvivorPos[3];
	GetClientAbsOrigin(tank, flTankPos);
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);
			if (GetVectorDistance(flTankPos, flSurvivorPos) <= 500.0)
			{
				if (bIsValidClient(iSurvivor, MT_CHECK_FAKECLIENT))
				{
					vShakePlayerScreen(iSurvivor, 2.0);
				}
			}

			switch (GetRandomInt(1, 5))
			{
				case 1:
				{
					GetEntPropString(iSurvivor, Prop_Data, "m_ModelName", sModel, sizeof sModel);

					switch (sModel[29])
					{
						case 'b', 'd', 'c', 'h': vVocalize(iSurvivor, "C2M1Falling");
						case 'v', 'n', 'e', 'a': vVocalize(iSurvivor, "PlaneCrashResponse");
					}
				}
				case 2: vVocalize(iSurvivor, "PlayerYellRun");
				case 3: vVocalize(iSurvivor, (g_bSecondGame ? "PlayerWarnTank" : "PlayerAlsoWarnTank"));
				case 4: vVocalize(iSurvivor, "PlayerBackUp");
				case 5: vVocalize(iSurvivor, "PlayerEmphaticGo");
			}
		}
	}

	int iExplosion = CreateEntityByName("env_explosion");
	if (bIsValidEntity(iExplosion))
	{
		DispatchKeyValue(iExplosion, "fireballsprite", SPRITE_EXPLODE);
		DispatchKeyValue(iExplosion, "iMagnitude", "50");
		DispatchKeyValue(iExplosion, "rendermode", "5");
		DispatchKeyValue(iExplosion, "spawnflags", "1");

		TeleportEntity(iExplosion, flTankPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iExplosion);

		SetEntPropEnt(iExplosion, Prop_Send, "m_hOwnerEntity", tank);
		SetEntProp(iExplosion, Prop_Send, "m_iTeamNum", 3);
		AcceptEntityInput(iExplosion, "Explode");

		iExplosion = EntIndexToEntRef(iExplosion);
		vDeleteEntity(iExplosion, 2.0);

		EmitSoundToAll((g_bSecondGame ? SOUND_EXPLOSION2 : SOUND_EXPLOSION1), iExplosion, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}

	if (g_bSecondGame)
	{
		int iTimescale = CreateEntityByName("func_timescale");
		if (bIsValidEntity(iTimescale))
		{
			DispatchKeyValueFloat(iTimescale, "desiredTimescale", 0.2);
			DispatchKeyValueFloat(iTimescale, "acceleration", 2.0);
			DispatchKeyValueFloat(iTimescale, "minBlendRate", 1.0);
			DispatchKeyValueFloat(iTimescale, "blendDeltaMultiplier", 2.0);

			DispatchSpawn(iTimescale);
			AcceptEntityInput(iTimescale, "Start");

			CreateTimer(0.75, tTimerRemoveTimescale, EntIndexToEntRef(iTimescale), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	vPushNearbyEntities(tank, flTankPos);

	flTankPos[2] += 40.0;
	TE_SetupBeamRingPoint(flTankPos, 10.0, 2000.0, g_iBossBeamSprite, g_iBossHaloSprite, 0, 50, 1.0, 88.0, 3.0, {255, 255, 255, 50}, 1000, 0);
	TE_SendToAll();
}

void vToggleSurvivorEffects(int survivor, bool override = false, int type = -1, bool toggle = true)
{
	if (!override && bIsDeveloper(survivor, 0))
	{
		return;
	}

	if (type == -1 || type == 3)
	{
		char sDelimiter[2];
		sDelimiter = (FindCharInString(g_esPlayer[survivor].g_sLightColor, ';') != -1) ? ";" : ",";

		switch (toggle && g_esPlayer[survivor].g_flVisualTime[3] != -1.0 && g_esPlayer[survivor].g_flVisualTime[3] > GetGameTime())
		{
			case true: vSetSurvivorLight(survivor, g_esPlayer[survivor].g_sLightColor, g_esPlayer[survivor].g_bApplyVisuals[3], sDelimiter, true);
			case false: vRemoveSurvivorLight(survivor);
		}
	}

	if (type == -1 || type == 4)
	{
		char sDelimiter[2];
		sDelimiter = (FindCharInString(g_esPlayer[survivor].g_sBodyColor, ';') != -1) ? ";" : ",";

		switch (toggle && g_esPlayer[survivor].g_flVisualTime[4] != -1.0 && g_esPlayer[survivor].g_flVisualTime[4] > GetGameTime())
		{
			case true: vSetSurvivorColor(survivor, g_esPlayer[survivor].g_sBodyColor, g_esPlayer[survivor].g_bApplyVisuals[4], sDelimiter, true);
			case false:
			{
				SetEntityRenderMode(survivor, RENDER_NORMAL);
				SetEntityRenderColor(survivor, 255, 255, 255, 255);
			}
		}
	}

	if (type == -1 || type == 5)
	{
		char sDelimiter[2];
		sDelimiter = (FindCharInString(g_esPlayer[survivor].g_sOutlineColor, ';') != -1) ? ";" : ",";

		switch (toggle && g_esPlayer[survivor].g_flVisualTime[5] != -1.0 && g_esPlayer[survivor].g_flVisualTime[5] > GetGameTime())
		{
			case true: vSetSurvivorOutline(survivor, g_esPlayer[survivor].g_sOutlineColor, g_esPlayer[survivor].g_bApplyVisuals[5], sDelimiter, true);
			case false: vRemoveGlow(survivor);
		}
	}
}

void vUnvomitPlayer(int player)
{
#if defined _l4dh_included
	switch (g_esGeneral.g_bLeft4DHooksInstalled || g_esGeneral.g_hSDKITExpired == null)
	{
		case true: L4D_OnITExpired(player);
		case false: SDKCall(g_esGeneral.g_hSDKITExpired, player);
	}
#else
	if (g_esGeneral.g_hSDKITExpired != null)
	{
		SDKCall(g_esGeneral.g_hSDKITExpired, player);
	}
#endif
}

void vVocalize(int survivor, const char[] voiceline)
{
	switch (g_bSecondGame)
	{
		case true: FakeClientCommand(survivor, "vocalize %s #%i", voiceline, RoundToNearest(GetGameTime() * 10.0));
		case false: FakeClientCommand(survivor, "vocalize %s", voiceline);
	}
}

void vVocalizeDeath(int killer, int assistant, int tank)
{
	if (g_esCache[tank].g_iVocalizeDeath == 1)
	{
		if (bIsSurvivor(killer))
		{
			vVocalize(killer, "PlayerHurrah");
		}

		if (bIsSurvivor(assistant) && assistant != killer)
		{
			vVocalize(assistant, "PlayerTaunt");
		}

		for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
		{
			if (bIsSurvivor(iTeammate, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iTeammate].g_iTankDamage[tank] > 0.0 && iTeammate != killer && iTeammate != assistant)
			{
				vVocalize(iTeammate, "PlayerNiceJob");
			}
		}
	}
}