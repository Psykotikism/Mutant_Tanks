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

public Action umNameChange(UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init)
{
	if (!g_esGeneral.g_bHideNameChange)
	{
		return Plugin_Continue;
	}

	msg.ReadByte();
	msg.ReadByte();

	char sMessage[255];
	msg.ReadString(sMessage, sizeof sMessage, true);
	if (StrEqual(sMessage, "#Cstrike_Name_Change"))
	{
		g_esGeneral.g_bHideNameChange = false;

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void OnEffectSpawnPost(int entity)
{
	int iAttacker = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (bIsTank(iAttacker, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esGeneral.g_iTeamID[entity] = GetClientTeam(iAttacker);
	}
}

public void OnInfectedSpawnPost(int entity)
{
	SDKHook(entity, SDKHook_OnTakeDamage, OnTakePlayerDamage);
	SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakePlayerDamagePost);
	SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
}

public Action OnInfectedSetTransmit(int entity, int client)
{
	return Plugin_Handled;
}

public Action OnPropSetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (g_esGeneral.g_bPluginEnabled && bIsValidClient(iOwner) && bIsValidClient(client) && iOwner == client && !bIsTankInThirdPerson(client))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public void OnPropSpawnPost(int entity)
{
	char sModel[45];
	GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof sModel);
	if (StrEqual(sModel, MODEL_OXYGENTANK) || StrEqual(sModel, MODEL_PROPANETANK) || StrEqual(sModel, MODEL_GASCAN) || (g_bSecondGame && StrEqual(sModel, MODEL_FIREWORKCRATE)))
	{
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakePropDamage);
	}
}

public void OnRainbowPreThinkPost(int player)
{
	if (!bIsValidClient(player) || !g_esPlayer[player].g_bRainbowColor)
	{
		g_esPlayer[player].g_bRainbowColor = false;

		SDKUnhook(player, SDKHook_PreThinkPost, OnRainbowPreThinkPost);

		return;
	}

	bool bHook = false, bRainbow = false;
	int iColor[4];
	GetEntityRenderColor(player, iColor[0], iColor[1], iColor[2], iColor[3]);
	iColor[0] = RoundToNearest((Cosine((GetGameTime() * 1.0) + player) * 127.5) + 127.5);
	iColor[1] = RoundToNearest((Cosine((GetGameTime() * 1.0) + player + 2) * 127.5) + 127.5);
	iColor[2] = RoundToNearest((Cosine((GetGameTime() * 1.0) + player + 4) * 127.5) + 127.5);
	if (bIsSurvivor(player))
	{
		bool bDeveloper = bIsDeveloper(player, 0);
		if (g_esPlayer[player].g_bApplyVisuals[0] && g_esPlayer[player].g_flVisualTime[0] != -1.0 && g_esPlayer[player].g_flVisualTime[0] > GetGameTime() && StrEqual(g_esPlayer[player].g_sScreenColor, "rainbow", false))
		{
			g_esPlayer[player].g_iScreenColorVisual[0] = iColor[0];
			g_esPlayer[player].g_iScreenColorVisual[1] = iColor[1];
			g_esPlayer[player].g_iScreenColorVisual[2] = iColor[2];
			g_esPlayer[player].g_iScreenColorVisual[3] = 50;
		}

		if ((g_esPlayer[player].g_bApplyVisuals[3] && g_esPlayer[player].g_flVisualTime[3] != -1.0 && g_esPlayer[player].g_flVisualTime[3] > GetGameTime()) || bDeveloper)
		{
			switch (bDeveloper)
			{
				case true: bRainbow = StrEqual(g_esDeveloper[player].g_sDevFlashlight, "rainbow", false);
				case false: bRainbow = StrEqual(g_esPlayer[player].g_sLightColor, "rainbow", false);
			}

			if (bRainbow)
			{
				bHook = true;

				vSetSurvivorFlashlight(player, iColor);
			}
		}

		if ((g_esPlayer[player].g_bApplyVisuals[4] && g_esPlayer[player].g_flVisualTime[4] != -1.0 && g_esPlayer[player].g_flVisualTime[4] > GetGameTime()) || bDeveloper)
		{
			switch (bDeveloper)
			{
				case true: bRainbow = StrEqual(g_esDeveloper[player].g_sDevSkinColor, "rainbow", false);
				case false: bRainbow = StrEqual(g_esPlayer[player].g_sBodyColor, "rainbow", false);
			}

			if (bRainbow)
			{
				bHook = true;

				SetEntityRenderColor(player, iColor[0], iColor[1], iColor[2], iColor[3]);
			}
		}

		if (g_bSecondGame && ((g_esPlayer[player].g_bApplyVisuals[5] && g_esPlayer[player].g_flVisualTime[5] != -1.0 && g_esPlayer[player].g_flVisualTime[5] > GetGameTime()) || bDeveloper) && !g_esPlayer[player].g_bVomited)
		{
			switch (bDeveloper)
			{
				case true: bRainbow = StrEqual(g_esDeveloper[player].g_sDevGlowOutline, "rainbow", false);
				case false: bRainbow = StrEqual(g_esPlayer[player].g_sOutlineColor, "rainbow", false);
			}

			if (bRainbow)
			{
				bHook = true;

				vSetSurvivorGlow(player, iColor[0], iColor[1], iColor[2]);
			}
		}
	}
	else if (bIsTank(player))
	{
		bRainbow = StrEqual(g_esCache[player].g_sSkinColor, "rainbow", false);
		if (bRainbow)
		{
			bHook = true;

			SetEntityRenderColor(player, iColor[0], iColor[1], iColor[2], iColor[3]);
		}

		int iProp = -1;
		if (bRainbow && bIsValidEntRef(g_esPlayer[player].g_iBlur))
		{
			bHook = true;
			iProp = EntRefToEntIndex(g_esPlayer[player].g_iBlur);
			if (bIsValidEntity(iProp))
			{
				SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
			}
		}

		if (g_bSecondGame && g_esCache[player].g_iGlowEnabled == 1 && !g_esPlayer[player].g_bVomited)
		{
			bRainbow = StrEqual(g_esCache[player].g_sGlowColor, "rainbow", false);
			if (bRainbow)
			{
				bHook = true;
				g_esCache[player].g_iGlowColor[0] = iColor[0];
				g_esCache[player].g_iGlowColor[1] = iColor[1];
				g_esCache[player].g_iGlowColor[2] = iColor[2];
				vSetTankGlow(player);
			}
		}

		bool bRainbow2[4];
		bRainbow2[0] = StrEqual(g_esCache[player].g_sOzTankColor, "rainbow", false);
		bRainbow2[1] = StrEqual(g_esCache[player].g_sFlameColor, "rainbow", false);
		bRainbow2[2] = StrEqual(g_esCache[player].g_sTireColor, "rainbow", false);
		bRainbow2[3] = StrEqual(g_esCache[player].g_sRockColor, "rainbow", false);
		for (int iPos = 0; iPos < sizeof esPlayer::g_iRock; iPos++)
		{
			if (iPos < sizeof esPlayer::g_iOzTank)
			{
				if (bRainbow2[0] && bIsValidEntRef(g_esPlayer[player].g_iOzTank[iPos]))
				{
					bHook = true;
					iProp = EntRefToEntIndex(g_esPlayer[player].g_iOzTank[iPos]);
					if (bIsValidEntity(iProp))
					{
						SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
					}
				}

				if (bRainbow2[1] && bIsValidEntRef(g_esPlayer[player].g_iFlame[iPos]))
				{
					bHook = true;
					iProp = EntRefToEntIndex(g_esPlayer[player].g_iFlame[iPos]);
					if (bIsValidEntity(iProp))
					{
						SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
					}
				}
			}

			if (iPos < sizeof esPlayer::g_iTire)
			{
				if (bRainbow2[2] && bIsValidEntRef(g_esPlayer[player].g_iTire[iPos]))
				{
					bHook = true;
					iProp = EntRefToEntIndex(g_esPlayer[player].g_iTire[iPos]);
					if (bIsValidEntity(iProp))
					{
						SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
					}
				}
			}

			if (bRainbow2[3] && bIsValidEntRef(g_esPlayer[player].g_iRock[iPos]))
			{
				bHook = true;
				iProp = EntRefToEntIndex(g_esPlayer[player].g_iRock[iPos]);
				if (bIsValidEntity(iProp))
				{
					SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
				}
			}
		}

		bRainbow = StrEqual(g_esCache[player].g_sPropTankColor, "rainbow", false);
		if (bRainbow && bIsValidEntRef(g_esPlayer[player].g_iPropaneTank))
		{
			bHook = true;
			iProp = EntRefToEntIndex(g_esPlayer[player].g_iPropaneTank);
			if (bIsValidEntity(iProp))
			{
				SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
			}
		}

		bRainbow = StrEqual(g_esCache[player].g_sFlashlightColor, "rainbow", false);
		if (bRainbow && bIsValidEntRef(g_esPlayer[player].g_iFlashlight))
		{
			bHook = true;
			iProp = EntRefToEntIndex(g_esPlayer[player].g_iFlashlight);
			if (bIsValidEntity(iProp))
			{
				char sColor[16];
				FormatEx(sColor, sizeof sColor, "%i %i %i %i", iGetRandomColor(iColor[0]), iGetRandomColor(iColor[1]), iGetRandomColor(iColor[2]), iGetRandomColor(iColor[3]));
				DispatchKeyValue(g_esPlayer[player].g_iFlashlight, "_light", sColor);
			}
		}

		for (int iPos = 0; iPos < sizeof esPlayer::g_iThrownRock; iPos++)
		{
			if (bRainbow2[3] && bIsValidEntRef(g_esPlayer[player].g_iThrownRock[iPos]))
			{
				bHook = true;
				iProp = EntRefToEntIndex(g_esPlayer[player].g_iThrownRock[iPos]);
				if (bIsValidEntity(iProp))
				{
					SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], iColor[3]);
				}
			}
		}
	}

	if (!bHook)
	{
		g_esPlayer[player].g_bRainbowColor = false;

		SDKUnhook(player, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
	}
}

public void OnSpeedPreThinkPost(int survivor)
{
	switch (bIsSurvivor(survivor))
	{
		case true:
		{
			bool bDeveloper = bIsDeveloper(survivor, 5);
			if (bDeveloper || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				float flSpeed = (bDeveloper && g_esDeveloper[survivor].g_flDevSpeedBoost > g_esPlayer[survivor].g_flSpeedBoost) ? g_esDeveloper[survivor].g_flDevSpeedBoost : g_esPlayer[survivor].g_flSpeedBoost;

				switch (flSpeed > 0.0)
				{
					case true: SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", flSpeed);
					case false: SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
				}
			}
			else
			{
				SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
				SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
			}
		}
		case false:
		{
			SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
			SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
	}
}

public void OnSurvivorPostThinkPost(int survivor)
{
	switch (bIsSurvivor(survivor))
	{
		case true:
		{
			if (bIsDeveloper(survivor, 6) || (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
			{
				bool bFast = false;
				if (g_bSecondGame)
				{
					char sModel[40];
					int iSequence = GetEntProp(survivor, Prop_Send, "m_nSequence");
					GetEntPropString(survivor, Prop_Data, "m_ModelName", sModel, sizeof sModel);

					switch (sModel[29])
					{
						case 'b': bFast = (iSequence == 620 || (627 <= iSequence <= 630) || iSequence == 667 || iSequence == 671 || iSequence == 672 || iSequence == 680);
						case 'd': bFast = (iSequence == 629 || (635 <= iSequence <= 638) || iSequence == 664 || iSequence == 678 || iSequence == 679 || iSequence == 687);
						case 'c': bFast = (iSequence == 621 || (627 <= iSequence <= 630) || iSequence == 656 || iSequence == 660 || iSequence == 661 || iSequence == 669);
						case 'h': bFast = (iSequence == 625 || (632 <= iSequence <= 635) || iSequence == 671 || iSequence == 675 || iSequence == 676 || iSequence == 684);
						case 'v': bFast = (iSequence == 528 || (535 <= iSequence <= 538) || iSequence == 759 || iSequence == 763 || iSequence == 764 || iSequence == 772);
						case 'n': bFast = (iSequence == 537 || (544 <= iSequence <= 547) || iSequence == 809 || iSequence == 819 || iSequence == 823 || iSequence == 824);
						case 'e': bFast = (iSequence == 531 || (539 <= iSequence <= 541) || iSequence == 762 || iSequence == 766 || iSequence == 767 || iSequence == 775);
						case 'a': bFast = (iSequence == 528 || (535 <= iSequence <= 538) || iSequence == 759 || iSequence == 763 || iSequence == 764 || iSequence == 772);
					}
				}

				switch (bFast)
				{
					case true: SetEntPropFloat(survivor, Prop_Send, "m_flPlaybackRate", 2.0);
					case false:
					{
						float flTime = GetGameTime();
						if (g_esPlayer[survivor].g_flStaggerTime > flTime)
						{
							return;
						}

						float flStagger = GetEntPropFloat(survivor, Prop_Send, "m_staggerTimer", 1);
						if (flStagger <= (flTime + g_esGeneral.g_flTickInterval))
						{
							return;
						}

						flStagger = (((flStagger - flTime) / 2.0) + flTime);
						SetEntPropFloat(survivor, Prop_Send, "m_staggerTimer", flStagger, 1);
						g_esPlayer[survivor].g_flStaggerTime = flStagger;
					}
				}
			}
			else
			{
				SDKUnhook(survivor, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
			}
		}
		case false: SDKUnhook(survivor, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
	}
}

public void OnTankPostThinkPost(int tank)
{
	switch (bIsTank(tank))
	{
		case true:
		{
			if (g_esCache[tank].g_iSkipTaunt == 1)
			{
				switch (GetEntProp(tank, Prop_Send, "m_nSequence"))
				{
					case 17: SetEntPropFloat(tank, Prop_Send, "m_flPlaybackRate", 2.0);
					case 18, 19, 20, 21, 22, 23: SetEntPropFloat(tank, Prop_Send, "m_flPlaybackRate", 10.0);
				}
			}
			else
			{
				SDKUnhook(tank, SDKHook_PostThinkPost, OnTankPostThinkPost);
			}
		}
		case false: SDKUnhook(tank, SDKHook_PostThinkPost, OnTankPostThinkPost);
	}
}

public Action OnTakeCombineDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && bIsValidClient(victim) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		if (bIsTankSupported(attacker) && bIsSurvivor(victim))
		{
			if (!bHasCoreAdminAccess(attacker) || bIsCoreAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vCombineAbilitiesForward(attacker, MT_COMBO_MELEEHIT, victim, .classname = sClassname);
			}
		}
		else if (bIsTankSupported(victim) && bIsSurvivor(attacker))
		{
			if (!bHasCoreAdminAccess(victim) || bIsCoreAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vCombineAbilitiesForward(victim, MT_COMBO_MELEEHIT, attacker, .classname = sClassname);
			}
		}
	}

	return Plugin_Continue;
}

public Action OnTakePlayerDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && damage > 0.0)
	{
		char sClassname[32];
		int iLauncherOwner = 0, iRockOwner = 0;
		if (bIsValidEntity(inflictor))
		{
			iLauncherOwner = HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") : 0;
			iRockOwner = HasEntProp(inflictor, Prop_Data, "m_hThrower") ? GetEntPropEnt(inflictor, Prop_Data, "m_hThrower") : 0;
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		bool bDeveloper, bRewarded;
		float flResistance;
		if (bIsSurvivor(victim))
		{
			bDeveloper = bIsDeveloper(victim, 4);
			bRewarded = bDeveloper || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_DAMAGEBOOST);
			static int iIndex = -1;
			if (iIndex == -1)
			{
				iIndex = iGetPatchIndex("DoJumpHeight");
			}

			if (bIsDeveloper(victim, 11) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				if (StrEqual(sClassname, "tank_rock"))
				{
					RequestFrame(vDetonateRockFrame, EntIndexToEntRef(inflictor));
				}
				else if (((damagetype & DMG_DROWN) && GetEntProp(victim, Prop_Send, "m_nWaterLevel") > 0) || ((damagetype & DMG_FALL) && !bIsSafeFalling(victim) && g_esPlayer[victim].g_bFatalFalling))
				{
					SetEntProp(victim, Prop_Data, "m_takedamage", 2, 1);

					return Plugin_Continue;
				}

				return Plugin_Handled;
			}
			else if ((g_esPlayer[victim].g_iFallPasses > 0 || (iIndex != -1 && g_bPermanentPatch[iIndex]) || bIsDeveloper(victim, 5) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_SPEEDBOOST)) && (damagetype & DMG_FALL) && (bIsSafeFalling(victim) || RoundToNearest(damage) < GetEntProp(victim, Prop_Data, "m_iHealth") || !g_esPlayer[victim].g_bFatalFalling))
			{
				if (g_esPlayer[victim].g_iFallPasses > 0)
				{
					g_esPlayer[victim].g_iFallPasses--;
				}

				return Plugin_Handled;
			}
			else if ((bIsDeveloper(victim, 8) || bIsDeveloper(victim, 10)) && StrEqual(sClassname, "insect_swarm"))
			{
				return Plugin_Handled;
			}
			else if (bIsTank(attacker))
			{
				flResistance = (bDeveloper && g_esDeveloper[victim].g_flDevDamageResistance > g_esPlayer[victim].g_flDamageResistance) ? g_esDeveloper[victim].g_flDevDamageResistance : g_esPlayer[victim].g_flDamageResistance;
				if (!bIsCoreAdminImmune(victim, attacker))
				{
					if (StrEqual(sClassname, "weapon_tank_claw") && g_esCache[attacker].g_flClawDamage >= 0.0)
					{
						damage = flGetScaledDamage(g_esCache[attacker].g_flClawDamage);
						damage = (bRewarded && flResistance > 0.0) ? (damage * flResistance) : damage;

						return (g_esCache[attacker].g_flClawDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
					}
					else if ((damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable") && g_esCache[attacker].g_flHittableDamage >= 0.0)
					{
						damage = flGetScaledDamage(g_esCache[attacker].g_flHittableDamage);
						damage = (bRewarded && flResistance > 0.0) ? (damage * flResistance) : damage;

						return (g_esCache[attacker].g_flHittableDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
					}
					else if (StrEqual(sClassname, "tank_rock") && !bIsValidEntity(iLauncherOwner) && g_esCache[attacker].g_flRockDamage >= 0.0)
					{
						damage = flGetScaledDamage(g_esCache[attacker].g_flRockDamage);
						damage = (bRewarded && flResistance > 0.0) ? (damage * flResistance) : damage;

						return (g_esCache[attacker].g_flRockDamage > 0.0) ? Plugin_Changed : Plugin_Handled;
					}
				}
				else if (bRewarded && flResistance > 0.0)
				{
					damage *= flResistance;

					return Plugin_Changed;
				}
			}
			else if (bRewarded)
			{
				if (bDeveloper || g_esPlayer[victim].g_iThorns == 1)
				{
					if (bIsSpecialInfected(attacker))
					{
						char sDamageType[32];
						IntToString(damagetype, sDamageType, sizeof sDamageType);
						vDamagePlayer(attacker, victim, damage, sDamageType);
					}
					else if (bIsCommonInfected(attacker))
					{
						SDKHooks_TakeDamage(attacker, victim, victim, damage, damagetype);
					}
				}

				flResistance = (bDeveloper && g_esDeveloper[victim].g_flDevDamageResistance > g_esPlayer[victim].g_flDamageResistance) ? g_esDeveloper[victim].g_flDevDamageResistance : g_esPlayer[victim].g_flDamageResistance;
				if (flResistance > 0.0)
				{
					damage *= flResistance;

					return Plugin_Changed;
				}
			}
		}
		else if (bIsInfected(victim) || bIsCommonInfected(victim) || bIsWitch(victim))
		{
			g_esGeneral.g_iInfectedHealth[victim] = GetEntProp(victim, Prop_Data, "m_iHealth");

			bool bPlayer = bIsValidClient(attacker), bSurvivor = bIsSurvivor(attacker);
			float flDamage;
			bDeveloper = bSurvivor && bIsDeveloper(attacker, 4), bRewarded = bDeveloper || (bSurvivor && (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST));
			if (bIsTank(victim))
			{
				if (StrEqual(sClassname, "tank_rock"))
				{
					RequestFrame(vDetonateRockFrame, EntIndexToEntRef(inflictor));

					return Plugin_Handled;
				}

				bool bBlockBullets = (damagetype & DMG_BULLET) && g_esCache[victim].g_iBulletImmunity == 1,
					bBlockExplosives = ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA)) && g_esCache[victim].g_iExplosiveImmunity == 1,
					bBlockFire = (damagetype & DMG_BURN) && g_esCache[victim].g_iFireImmunity == 1,
					bBlockHittables = (damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable") && g_esCache[victim].g_iHittableImmunity == 1,
					bBlockMelee = ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)) && g_esCache[victim].g_iMeleeImmunity == 1;
				if (attacker == victim || bBlockBullets || bBlockExplosives || bBlockFire || bBlockHittables || bBlockMelee)
				{
					if (bRewarded)
					{
						if (bBlockBullets || bBlockMelee)
						{
							vKnockbackTank(victim, attacker, damagetype);
						}

						flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
						if (flDamage > 0.0)
						{
							damage *= flDamage;

							return Plugin_Changed;
						}

						return Plugin_Continue;
					}

					if (bBlockFire)
					{
						ExtinguishEntity(victim);
					}

					if (bPlayer && attacker != victim && (bBlockBullets || bBlockExplosives || bBlockHittables || bBlockMelee))
					{
						EmitSoundToAll(SOUND_METAL, victim);

						if (bPlayer && bBlockMelee)
						{
							float flTankPos[3];
							GetClientAbsOrigin(victim, flTankPos);

							switch (bSurvivor && (bIsDeveloper(attacker, 11) || (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_GODMODE)))
							{
								case true: vPushNearbyEntities(victim, flTankPos, 300.0, 100.0);
								case false: vPushNearbyEntities(victim, flTankPos);
							}
						}
					}

					return Plugin_Handled;
				}

				if ((damagetype & DMG_BURN) && g_esCache[victim].g_flBurnDuration > 0.0)
				{
					int iFlame = GetEntPropEnt(victim, Prop_Send, "m_hEffectEntity");
					if (bIsValidEntity(iFlame))
					{
						float flTime = GetGameTime();
						if (GetEntPropFloat(iFlame, Prop_Data, "m_flLifetime") > (flTime + g_esCache[victim].g_flBurnDuration))
						{
							SetEntPropFloat(iFlame, Prop_Data, "m_flLifetime", (flTime + g_esCache[victim].g_flBurnDuration));
						}
					}
				}

				if (bSurvivor)
				{
					if ((damagetype & DMG_BULLET) || (damagetype & DMG_CLUB) || (damagetype & DMG_SLASH))
					{
						vKnockbackTank(victim, attacker, damagetype);
					}

					if ((damagetype & DMG_BURN) && g_esGeneral.g_iCreditIgniters == 0)
					{
						if (bIsTankSupported(victim) && bRewarded)
						{
							flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
							if (flDamage > 0.0)
							{
								damage *= flDamage;
							}
						}

						inflictor = 0;
						attacker = 0;

						return Plugin_Changed;
					}
				}
			}
			else if (bSurvivor && (damagetype & DMG_BULLET))
			{
				bool bChanged = false;
				bDeveloper = bIsDeveloper(attacker, 9), bRewarded = !!(g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST);
				if (bDeveloper || bRewarded)
				{
					if (bDeveloper || (bRewarded && g_esPlayer[attacker].g_iHollowpointAmmo == 1))
					{
						if (bIsCommonInfected(victim) || bIsWitch(victim))
						{
							if (g_bSecondGame)
							{
								if (GetEntProp(victim, Prop_Data, "m_iHealth") <= RoundToNearest(damage))
								{
									float flOrigin[3], flAngles[3];
									GetEntPropVector(victim, Prop_Data, "m_vecOrigin", flOrigin);
									GetEntPropVector(victim, Prop_Data, "m_angRotation", flAngles);
									flOrigin[2] += 48.0;

									RequestFrame(vInfectedTransmitFrame, EntIndexToEntRef(victim));
									vAttachParticle2(flOrigin, flAngles, PARTICLE_GORE, 0.2);
								}
							}
							else
							{
								bChanged = true;
								damagetype |= DMG_DISSOLVE;
							}
						}
					}

					if (bDeveloper || (bRewarded && g_esPlayer[attacker].g_iSledgehammerRounds == 1))
					{
						if (bIsSpecialInfected(victim))
						{
							vPerformKnockback(victim, attacker);
						}
						else if (bIsCommonInfected(victim) || bIsWitch(victim))
						{
							bRewarded = bDeveloper || (bSurvivor && (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST));
							if (bRewarded)
							{
								bDeveloper = bSurvivor && bIsDeveloper(attacker, 4);
								flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
								if (flDamage > 0.0)
								{
									bChanged = true;
									damage *= flDamage;
								}
							}

							bChanged = true;
							damagetype |= DMG_BUCKSHOT;
						}
					}

					if (bChanged)
					{
						return Plugin_Changed;
					}
				}
			}

			bDeveloper = bSurvivor && bIsDeveloper(attacker, 4);
			bRewarded = bDeveloper || (bSurvivor && (g_esPlayer[attacker].g_iRewardTypes & MT_REWARD_DAMAGEBOOST));
			if (bRewarded)
			{
				flDamage = (bDeveloper && g_esDeveloper[attacker].g_flDevDamageBoost > g_esPlayer[attacker].g_flDamageBoost) ? g_esDeveloper[attacker].g_flDevDamageBoost : g_esPlayer[attacker].g_flDamageBoost;
				if (flDamage > 0.0)
				{
					damage *= flDamage;

					return Plugin_Changed;
				}
			}
			else if ((bIsTankSupported(attacker) && victim != attacker) || (bIsTankSupported(iLauncherOwner) && victim != iLauncherOwner) || (bIsTankSupported(iRockOwner) && victim != iRockOwner))
			{
				if (StrEqual(sClassname, "weapon_tank_claw"))
				{
					return Plugin_Continue;
				}

				if (StrEqual(sClassname, "tank_rock") || ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA) || (damagetype & DMG_BURN)))
				{
					vRemoveDamage(victim, damagetype);

					if (StrEqual(sClassname, "tank_rock"))
					{
						RequestFrame(vDetonateRockFrame, EntIndexToEntRef(inflictor));
					}

					return Plugin_Handled;
				}
			}
		}
	}

	return Plugin_Continue;
}

public void OnTakePlayerDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && bIsSurvivor(attacker) && (bIsInfected(victim) || bIsCommonInfected(victim) || bIsWitch(victim)) && g_esGeneral.g_iInfectedHealth[victim] > GetEntProp(victim, Prop_Data, "m_iHealth") && damage >= 1.0)
	{
		vLifeLeech(attacker, damagetype, victim);
	}
}

public Action OnTakePlayerDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && damage > 0.0 && bIsSurvivor(victim) && bIsSurvivorDisabled(victim))
	{
		int iReviver = GetClientOfUserId(g_esPlayer[victim].g_iReviver);
		if ((bIsDeveloper(victim, 6) || (g_esPlayer[victim].g_iRewardTypes & MT_REWARD_ATTACKBOOST)) || (bIsSurvivor(iReviver) && (bIsDeveloper(iReviver, 6) || (g_esPlayer[iReviver].g_iRewardTypes & MT_REWARD_ATTACKBOOST))))
		{
			static int iIndex = -1;
			if (iIndex == -1)
			{
				iIndex = iGetPatchIndex("ReviveInterrupt");
			}

			if (iIndex != -1)
			{
				bInstallPatch(iIndex);
			}
		}
	}

	return Plugin_Continue;
}

public void OnTakePlayerDamageAlivePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	static int iIndex = -1;
	if (iIndex == -1)
	{
		iIndex = iGetPatchIndex("ReviveInterrupt");
	}

	if (iIndex != -1)
	{
		bRemovePatch(iIndex);
	}
}

public Action OnTakePropDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_esGeneral.g_bPluginEnabled && (bIsInfected(victim) || bIsCommonInfected(victim) || bIsWitch(victim)) && damage > 0.0)
	{
		if (bIsValidEntity(inflictor) && attacker == inflictor && g_esGeneral.g_iTeamID[inflictor] == 3)
		{
			attacker = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
			if (attacker == -1 || (0 < attacker <= MaxClients && (!IsClientInGame(attacker) || GetClientUserId(attacker) != g_esPlayer[attacker].g_iUserID)))
			{
				vRemoveDamage(victim, damagetype);

				return Plugin_Handled;
			}
		}
		else if (0 < attacker <= MaxClients)
		{
			if (g_esGeneral.g_iTeamID[inflictor] == 3 && (!IsClientInGame(attacker) || GetClientUserId(attacker) != g_esPlayer[attacker].g_iUserID || GetClientTeam(attacker) != 3))
			{
				vRemoveDamage(victim, damagetype);

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void OnWeaponEquipPost(int client, int weapon)
{
	if (bIsSurvivor(client) && weapon > MaxClients)
	{
		vCheckClipSizes(client);

		char sWeapon[32];
		GetEntityClassname(weapon, sWeapon, sizeof sWeapon);
		if (GetPlayerWeaponSlot(client, 2) == weapon)
		{
			strcopy(g_esPlayer[client].g_sStoredThrowable, sizeof esPlayer::g_sStoredThrowable, sWeapon);
		}
		else if (GetPlayerWeaponSlot(client, 3) == weapon)
		{
			strcopy(g_esPlayer[client].g_sStoredMedkit, sizeof esPlayer::g_sStoredMedkit, sWeapon);
		}
		else if (GetPlayerWeaponSlot(client, 4) == weapon)
		{
			strcopy(g_esPlayer[client].g_sStoredPills, sizeof esPlayer::g_sStoredPills, sWeapon);
		}
	}
}

public void OnWeaponSwitchPost(int client, int weapon)
{
	if (g_esGeneral.g_bPluginEnabled && g_bSecondGame && bIsSurvivor(client) && bIsDeveloper(client, 2) && weapon > MaxClients)
	{
		RequestFrame(vWeaponSkinFrame, GetClientUserId(client));
	}
}

public Action FallSoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (g_esGeneral.g_bPluginEnabled && bIsSurvivor(entity))
	{
		static int iIndex = -1;
		if (iIndex == -1)
		{
			iIndex = iGetPatchIndex("DoJumpHeight");
		}

		if (g_esPlayer[entity].g_iFallPasses > 0 || (iIndex != -1 && g_bPermanentPatch[iIndex]) || bIsDeveloper(entity, 5) || bIsDeveloper(entity, 11) || (g_esPlayer[entity].g_iRewardTypes & MT_REWARD_SPEEDBOOST) || (g_esPlayer[entity].g_iRewardTypes & MT_REWARD_GODMODE))
		{
			float flOrigin[3];
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", flOrigin);
			if ((g_esPlayer[entity].g_bFallDamage && !g_esPlayer[entity].g_bFatalFalling) || (0.0 < (g_esPlayer[entity].g_flPreFallZ - flOrigin[2]) < 900.0 && !g_esPlayer[entity].g_bFalling))
			{
				if (StrEqual(sample, SOUND_NULL, false))
				{
					return Plugin_Stop;
				}
				else if (0 <= StrContains(sample, SOUND_DAMAGE, false) <= 1 || 0 <= StrContains(sample, SOUND_DAMAGE2, false) <= 1)
				{
					g_esPlayer[entity].g_bFallDamage = false;

					return Plugin_Stop;
				}
			}
		}
	}

	return Plugin_Continue;
}

public void vDetonateRockFrame(int ref)
{
	int iRock = EntRefToEntIndex(ref);
	if (bIsValidEntity(iRock) && g_esGeneral.g_hSDKRockDetonate != null)
	{
		SDKCall(g_esGeneral.g_hSDKRockDetonate, iRock);
	}
}

public void vInfectedTransmitFrame(int ref)
{
	int iCommon = EntRefToEntIndex(ref);
	if (bIsValidEntity(iCommon))
	{
		SDKHook(iCommon, SDKHook_SetTransmit, OnInfectedSetTransmit);
	}
}

public void vPlayerSpawnFrame(DataPack pack)
{
	pack.Reset();
	int iPlayer = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	delete pack;

	if (bIsSurvivor(iPlayer))
	{
		if (!g_esPlayer[iPlayer].g_bSetup)
		{
			g_esPlayer[iPlayer].g_bSetup = true;

			if (bIsDeveloper(iPlayer))
			{
				if (bIsDeveloper(iPlayer, .real = true) && !CheckCommandAccess(iPlayer, "sm_mt_dev", ADMFLAG_ROOT, false) && g_esDeveloper[iPlayer].g_iDevAccess == 0)
				{
					g_esDeveloper[iPlayer].g_iDevAccess = 1661;
				}

				vSetupDeveloper(iPlayer, .usual = true);
			}
		}

		if (!bIsDeveloper(iPlayer, 0))
		{
			char sDelimiter[2];
			float flTime = GetGameTime();
			if (g_esPlayer[iPlayer].g_flVisualTime[3] != -1.0 && g_esPlayer[iPlayer].g_flVisualTime[3] > flTime)
			{
				sDelimiter = (FindCharInString(g_esPlayer[iPlayer].g_sLightColor, ';') != -1) ? ";" : ",";
				vSetSurvivorLight(iPlayer, g_esPlayer[iPlayer].g_sLightColor, g_esPlayer[iPlayer].g_bApplyVisuals[3], sDelimiter, true);
			}

			if (g_esPlayer[iPlayer].g_flVisualTime[4] != -1.0 && g_esPlayer[iPlayer].g_flVisualTime[4] > flTime)
			{
				sDelimiter = (FindCharInString(g_esPlayer[iPlayer].g_sBodyColor, ';') != -1) ? ";" : ",";
				vSetSurvivorColor(iPlayer, g_esPlayer[iPlayer].g_sBodyColor, g_esPlayer[iPlayer].g_bApplyVisuals[4], sDelimiter, true);
			}

			if (g_esPlayer[iPlayer].g_flVisualTime[5] != -1.0 && g_esPlayer[iPlayer].g_flVisualTime[5] > flTime)
			{
				sDelimiter = (FindCharInString(g_esPlayer[iPlayer].g_sOutlineColor, ';') != -1) ? ";" : ",";
				vSetSurvivorOutline(iPlayer, g_esPlayer[iPlayer].g_sOutlineColor, g_esPlayer[iPlayer].g_bApplyVisuals[5], sDelimiter, true);
			}
		}
		else if (g_esDeveloper[iPlayer].g_iDevAccess == 1)
		{
			vSetupPerks(iPlayer);
		}

		vRefillAmmo(iPlayer, .reset = true);
	}
	else if (bIsTank(iPlayer) && !g_esPlayer[iPlayer].g_bFirstSpawn)
	{
		if (g_bSecondGame)
		{
			g_esPlayer[iPlayer].g_bStasis = bIsTankInStasis(iPlayer) || (g_esGeneral.g_hSDKIsInStasis != null && SDKCall(g_esGeneral.g_hSDKIsInStasis, iPlayer));
		}

		if (g_esPlayer[iPlayer].g_bStasis && g_esGeneral.g_iStasisMode == 1 && g_esGeneral.g_hSDKLeaveStasis != null)
		{
			SDKCall(g_esGeneral.g_hSDKLeaveStasis, iPlayer);
		}

		g_esPlayer[iPlayer].g_bFirstSpawn = true;

		if (g_esPlayer[iPlayer].g_bDied)
		{
			g_esPlayer[iPlayer].g_bDied = false;
			g_esPlayer[iPlayer].g_iOldTankType = 0;
			g_esPlayer[iPlayer].g_iTankType = 0;
		}

		if (g_esGeneral.g_flIdleCheck > 0.0)
		{
			CreateTimer(g_esGeneral.g_flIdleCheck, tTimerKillIdleTank, GetClientUserId(iPlayer), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (g_esGeneral.g_bForceSpawned)
		{
			g_esPlayer[iPlayer].g_bArtificial = true;
		}

		switch (iType)
		{
			case 0:
			{
				switch (bIsTank(iPlayer, MT_CHECK_FAKECLIENT))
				{
					case true:
					{
						switch (g_esGeneral.g_iSpawnMode)
						{
							case 0:
							{
								g_esPlayer[iPlayer].g_bNeedHealth = true;

								vTankMenu(iPlayer);
							}
							case 1: vMutateTank(iPlayer, iType);
						}
					}
					case false: vMutateTank(iPlayer, iType);
				}
			}
			default: vMutateTank(iPlayer, iType);
		}
	}
}

public void vRespawnFrame(int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (g_esGeneral.g_bPluginEnabled && bIsSurvivor(iSurvivor, MT_CHECK_INDEX|MT_CHECK_INGAME) && bIsDeveloper(iSurvivor, 10))
	{
		bRespawnSurvivor(iSurvivor, true);
	}
}

public void vRockThrowFrame(int ref)
{
	int iRock = EntRefToEntIndex(ref);
	if (g_esGeneral.g_bPluginEnabled && bIsValidEntity(iRock))
	{
		int iThrower = GetEntPropEnt(iRock, Prop_Data, "m_hThrower");
		if (bIsTankSupported(iThrower) && bHasCoreAdminAccess(iThrower) && !bIsTankIdle(iThrower) && g_esCache[iThrower].g_iTankEnabled == 1)
		{
			switch (StrEqual(g_esCache[iThrower].g_sRockColor, "rainbow", false))
			{
				case true:
				{
					g_esPlayer[iThrower].g_iThrownRock[iRock] = ref;

					if (!g_esPlayer[iThrower].g_bRainbowColor)
					{
						g_esPlayer[iThrower].g_bRainbowColor = SDKHookEx(iThrower, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
					}
				}
				case false: SetEntityRenderColor(iRock, iGetRandomColor(g_esCache[iThrower].g_iRockColor[0]), iGetRandomColor(g_esCache[iThrower].g_iRockColor[1]), iGetRandomColor(g_esCache[iThrower].g_iRockColor[2]), iGetRandomColor(g_esCache[iThrower].g_iRockColor[3]));
			}

			vSetRockModel(iThrower, iRock);

			if (g_esCache[iThrower].g_iRockEffects > 0)
			{
				DataPack dpRockEffects;
				CreateDataTimer(0.75, tTimerRockEffects, dpRockEffects, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpRockEffects.WriteCell(ref);
				dpRockEffects.WriteCell(GetClientUserId(iThrower));
			}

			Call_StartForward(g_esGeneral.g_gfRockThrowForward);
			Call_PushCell(iThrower);
			Call_PushCell(iRock);
			Call_Finish();

			vCombineAbilitiesForward(iThrower, MT_COMBO_ROCKTHROW, .weapon = iRock);
		}
	}
}

public void vTankSpawnFrame(DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell()), iMode = pack.ReadCell();
	delete pack;

	if (bIsTankSupported(iTank) && bHasCoreAdminAccess(iTank))
	{
		vCacheSettings(iTank);

		if (!bIsInfectedGhost(iTank) && !g_esPlayer[iTank].g_bStasis)
		{
			g_esPlayer[iTank].g_bKeepCurrentType = false;

			char sOldName[33], sNewName[33];
			vGetTranslatedName(sOldName, sizeof sOldName, .type = g_esPlayer[iTank].g_iOldTankType);
			vGetTranslatedName(sNewName, sizeof sNewName, .type = g_esPlayer[iTank].g_iTankType);
			vSetTankName(iTank, sOldName, sNewName, iMode);

			vParticleEffects(iTank);
			vResetTankSpeed(iTank, false);
			vSetTankProps(iTank);
			vThrowInterval(iTank);

			SDKHook(iTank, SDKHook_PostThinkPost, OnTankPostThinkPost);

			Call_StartForward(g_esGeneral.g_gfPostTankSpawnForward);
			Call_PushCell(iTank);
			Call_Finish();

			vCombineAbilitiesForward(iTank, MT_COMBO_POSTSPAWN);
		}

		switch (iMode)
		{
			case -1:
			{
				vSetTankRainbowColor(iTank);
				vSpawnMessages(iTank);
			}
			case 0:
			{
				if (!bIsCustomTank(iTank) && !bIsInfectedGhost(iTank))
				{
					vSetTankHealth(iTank);
					vSpawnMessages(iTank);

					g_esGeneral.g_iTankCount++;
				}

				g_esPlayer[iTank].g_iTankHealth = GetEntProp(iTank, Prop_Data, "m_iMaxHealth");
			}
		}
	}
}

public void vWeaponSkinFrame(int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (bIsSurvivor(iSurvivor) && bIsDeveloper(iSurvivor, 2))
	{
		vSetSurvivorWeaponSkin(iSurvivor);
	}
}

public void vGameMode(const char[] output, int caller, int activator, float delay)
{
	if (StrEqual(output, "OnCoop"))
	{
		g_esGeneral.g_iCurrentMode = 1;
	}
	else if (StrEqual(output, "OnVersus"))
	{
		g_esGeneral.g_iCurrentMode = 2;
	}
	else if (StrEqual(output, "OnSurvival"))
	{
		g_esGeneral.g_iCurrentMode = 4;
	}
	else if (StrEqual(output, "OnScavenge"))
	{
		g_esGeneral.g_iCurrentMode = 8;
	}
}