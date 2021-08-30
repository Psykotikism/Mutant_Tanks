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

public void vEventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (g_esGeneral.g_bPluginEnabled)
	{
		if (StrEqual(name, "ability_use"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank))
			{
				vThrowInterval(iTank);
			}
		}
		else if (StrEqual(name, "bot_player_replace"))
		{
			int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
				iPlayerId = event.GetInt("player"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iBot))
			{
				if (bIsTank(iPlayer))
				{
					vSetTankColor(iPlayer, g_esPlayer[iBot].g_iTankType);
					vCopyTankStats(iBot, iPlayer);
					vTankSpawn(iPlayer, -1);
					vResetTank(iBot, 0);
					vResetTank2(iBot, false);
					vCacheSettings(iBot);
				}
				else if (bIsSurvivor(iPlayer))
				{
					vRemoveSurvivorEffects(iBot);
					vCopySurvivorStats(iBot, iPlayer);
					vSetupDeveloper(iPlayer, .usual = true);
					vResetSurvivorStats(iBot, false);
				}
			}
		}
		else if (StrEqual(name, "choke_start") || StrEqual(name, "lunge_pounce") || StrEqual(name, "tongue_grab") || StrEqual(name, "charger_carry_start") || StrEqual(name, "charger_pummel_start") || StrEqual(name, "jockey_ride"))
		{
			int iSpecialId = event.GetInt("userid"), iSpecial = GetClientOfUserId(iSpecialId),
				iSurvivorId = event.GetInt("victim"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSpecialInfected(iSpecial) && bIsSurvivor(iSurvivor) && (bIsDeveloper(iSurvivor, 11) || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_GODMODE)))
			{
				vSaveCaughtSurvivor(iSurvivor, iSpecial);
			}
		}
		else if (StrEqual(name, "create_panic_event"))
		{
			if (g_esGeneral.g_iCurrentMode == 4 && g_esGeneral.g_iSurvivalBlock == 0)
			{
				delete g_esGeneral.g_hSurvivalTimer;

				g_esGeneral.g_iSurvivalBlock = 1;
				g_esGeneral.g_hSurvivalTimer = CreateTimer(g_esGeneral.g_flSurvivalDelay, tTimerDelaySurvival);
			}
		}
		else if (StrEqual(name, "entity_shoved"))
		{
			int iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId),
				iWitch = event.GetInt("entityid");
			if (bIsWitch(iWitch) && bIsSurvivor(iSurvivor))
			{
				bool bDeveloper = bIsDeveloper(iSurvivor, 9);
				if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
				{
					float flMultiplier = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevShoveDamage > g_esPlayer[iSurvivor].g_flShoveDamage) ? g_esDeveloper[iSurvivor].g_flDevShoveDamage : g_esPlayer[iSurvivor].g_flShoveDamage;
					if (flMultiplier > 0.0)
					{
						SDKHooks_TakeDamage(iWitch, iSurvivor, iSurvivor, (float(GetEntProp(iWitch, Prop_Data, "m_iMaxHealth")) * flMultiplier), DMG_CLUB);
					}
				}
			}
		}
		else if (StrEqual(name, "finale_escape_start") || StrEqual(name, "finale_vehicle_incoming") || StrEqual(name, "finale_vehicle_ready"))
		{
			g_esGeneral.g_iTankWave = 3;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_vehicle_leaving"))
		{
			g_esGeneral.g_bFinaleEnded = true;
			g_esGeneral.g_iTankWave = 4;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_rush") || StrEqual(name, "finale_radio_start") || StrEqual(name, "finale_radio_damaged") || StrEqual(name, "finale_bridge_lowering"))
		{
			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_start") || StrEqual(name, "gauntlet_finale_start"))
		{
			g_esGeneral.g_iTankWave = 1;

			vExecuteFinaleConfigs(name);
		}
		else if (StrEqual(name, "finale_win"))
		{
			vExecuteFinaleConfigs(name);
			vResetLadyKiller(true);
		}
		else if (StrEqual(name, "heal_success"))
		{
			int iSurvivorId = event.GetInt("subject"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSurvivor(iSurvivor))
			{
				g_esPlayer[iSurvivor].g_bLastLife = false;
				g_esPlayer[iSurvivor].g_iReviveCount = 0;
			}
		}
		else if (StrEqual(name, "infected_hurt"))
		{
			int iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId),
				iWitch = event.GetInt("entityid"), iDamageType = event.GetInt("type");
			if (bIsSurvivor(iSurvivor) && bIsWitch(iWitch) && !g_esGeneral.g_bWitchKilled[iWitch])
			{
				bool bDeveloper = bIsDeveloper(iSurvivor, 11);
				if (bDeveloper || (g_esPlayer[iSurvivor].g_iLadyKillerCount < g_esPlayer[iSurvivor].g_iLadyKiller))
				{
					g_esGeneral.g_bWitchKilled[iWitch] = true;

					SDKHooks_TakeDamage(iWitch, iSurvivor, iSurvivor, float(GetEntProp(iWitch, Prop_Data, "m_iHealth")), iDamageType);
					EmitSoundToClient(iSurvivor, SOUND_LADYKILLER, iSurvivor, SNDCHAN_AUTO, SNDLEVEL_NORMAL);

					if (!bDeveloper)
					{
						g_esPlayer[iSurvivor].g_iLadyKillerCount++;

						MT_PrintToChat(iSurvivor, "%s %t", MT_TAG2, "RewardLadyKiller2", (g_esPlayer[iSurvivor].g_iLadyKiller - g_esPlayer[iSurvivor].g_iLadyKillerCount));
					}
				}
			}
		}
		else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_end"))
		{
			vResetRound();
		}
		else if (StrEqual(name, "player_bot_replace"))
		{
			int iPlayerId = event.GetInt("player"), iPlayer = GetClientOfUserId(iPlayerId),
				iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
			if (bIsValidClient(iPlayer))
			{
				if (bIsTank(iBot))
				{
					vSetTankColor(iBot, g_esPlayer[iPlayer].g_iTankType);
					vCopyTankStats(iPlayer, iBot);
					vTankSpawn(iBot, -1);
					vResetTank(iPlayer, 0);
					vResetTank2(iPlayer, false);
					vCacheSettings(iPlayer);
				}
				else if (bIsSurvivor(iBot))
				{
					vRemoveSurvivorEffects(iPlayer);
					vCopySurvivorStats(iPlayer, iBot);
					vSetupDeveloper(iPlayer, false);
					vResetSurvivorStats(iPlayer, false);
				}
			}
		}
		else if (StrEqual(name, "player_connect") || StrEqual(name, "player_disconnect"))
		{
			int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
			g_esPlayer[iSurvivor].g_iLadyKiller = 0;
			g_esPlayer[iSurvivor].g_iLadyKillerCount = 0;

			vDeveloperSettings(iSurvivor);
			vResetTank2(iSurvivor);
		}
		else if (StrEqual(name, "player_death"))
		{
			int iVictimId = event.GetInt("userid"), iVictim = GetClientOfUserId(iVictimId),
				iAttackerId = event.GetInt("attacker"), iAttacker = GetClientOfUserId(iAttackerId);
			if (bIsTank(iVictim, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				g_esPlayer[iVictim].g_bDied = true;
				g_esPlayer[iVictim].g_bTriggered = false;

				SDKUnhook(iVictim, SDKHook_PostThinkPost, OnTankPostThinkPost);
				vCalculateDeath(iVictim, iAttacker);

				if (g_esPlayer[iVictim].g_iTankType > 0)
				{
					if (g_esCache[iVictim].g_iDeathRevert == 1)
					{
						int iType = g_esPlayer[iVictim].g_iTankType;
						vSetTankColor(iVictim, .revert = true);
						g_esPlayer[iVictim].g_iTankType = iType;
					}

					vResetTank(iVictim, g_esCache[iVictim].g_iDeathRevert);
					CreateTimer(1.0, tTimerResetType, iVictimId, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else if (bIsSurvivor(iVictim, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				if (bIsTank(iAttacker, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esCache[iAttacker].g_iAnnounceKill == 1)
				{
					int iOption = iGetMessageType(g_esCache[iAttacker].g_iKillMessage);
					if (iOption > 0)
					{
						char sPhrase[32], sTankName[33];
						FormatEx(sPhrase, sizeof sPhrase, "Kill%i", iOption);
						vGetTranslatedName(sTankName, sizeof sTankName, iAttacker);
						MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName, iVictim);
						vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName, iVictim);
					}
				}

				vRemoveSurvivorEffects(iVictim, true);
			}
		}
		else if (StrEqual(name, "player_hurt"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
				iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsTank(iTank) && !bIsPlayerIncapacitated(iTank) && bIsSurvivor(iSurvivor))
			{
				g_esPlayer[iSurvivor].g_iTankDamage[iTank] += event.GetInt("dmg_health");
			}
		}
		else if (StrEqual(name, "player_incapacitated"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsTank(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
			{
				g_esPlayer[iPlayer].g_bDied = false;

				CreateTimer(10.0, tTimerKillStuckTank, iPlayerId, TIMER_FLAG_NO_MAPCHANGE);
				vCombineAbilitiesForward(iPlayer, MT_COMBO_UPONINCAP);
			}
		}
		else if (StrEqual(name, "player_now_it"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsTank(iPlayer) || bIsSurvivor(iPlayer))
			{
				vRemoveGlow(iPlayer);
			}

			if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && !g_esPlayer[iPlayer].g_bVomited)
			{
				g_esPlayer[iPlayer].g_bVomited = true;
			}
		}
		else if (StrEqual(name, "player_no_longer_it"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsTank(iPlayer) && !bIsPlayerIncapacitated(iPlayer))
			{
				vSetTankGlow(iPlayer);
			}
			else if (bIsSurvivor(iPlayer) && g_bSecondGame)
			{
				switch (bIsDeveloper(iPlayer, 0))
				{
					case true: vSetSurvivorOutline(iPlayer, g_esDeveloper[iPlayer].g_sDevGlowOutline, .delimiter = ",");
					case false: vToggleSurvivorEffects(iPlayer, .type = 5);
				}
			}

			if (bIsValidClient(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esPlayer[iPlayer].g_bVomited)
			{
				g_esPlayer[iPlayer].g_bVomited = false;
			}
		}
		else if (StrEqual(name, "player_shoved"))
		{
			int iSpecialId = event.GetInt("userid"), iSpecial = GetClientOfUserId(iSpecialId),
				iSurvivorId = event.GetInt("attacker"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if ((bIsTank(iSpecial) || bIsCharger(iSpecial)) && bIsSurvivor(iSurvivor))
			{
				bool bDeveloper = bIsDeveloper(iSurvivor, 9);
				if (bDeveloper || (g_esPlayer[iSurvivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
				{
					float flMultiplier = (bDeveloper && g_esDeveloper[iSurvivor].g_flDevShoveDamage > g_esPlayer[iSurvivor].g_flShoveDamage) ? g_esDeveloper[iSurvivor].g_flDevShoveDamage : g_esPlayer[iSurvivor].g_flShoveDamage;
					if (flMultiplier > 0.0)
					{
						vDamagePlayer(iSpecial, iSurvivor, (float(GetEntProp(iSpecial, Prop_Data, "m_iMaxHealth")) * flMultiplier), "128");
					}
				}
			}
		}
		else if (StrEqual(name, "player_spawn"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iPlayer))
			{
				SDKUnhook(iPlayer, SDKHook_PostThinkPost, OnTankPostThinkPost);

				DataPack dpPlayerSpawn = new DataPack();
				RequestFrame(vPlayerSpawnFrame, dpPlayerSpawn);
				dpPlayerSpawn.WriteCell(iPlayerId);
				dpPlayerSpawn.WriteCell(g_esGeneral.g_iChosenType);
			}
		}
		else if (StrEqual(name, "player_team"))
		{
			int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
			if (bIsValidClient(iPlayer))
			{
				vRemoveSurvivorEffects(iPlayer);
			}
		}
		else if (StrEqual(name, "revive_success"))
		{
			int iSurvivorId = event.GetInt("subject"), iSurvivor = GetClientOfUserId(iSurvivorId);
			if (bIsSurvivor(iSurvivor))
			{
				g_esPlayer[iSurvivor].g_bLastLife = event.GetBool("lastlife");
				g_esPlayer[iSurvivor].g_iReviveCount++;
				g_esPlayer[iSurvivor].g_iReviver = 0;
			}
		}
		else if (StrEqual(name, "round_start"))
		{
			g_esGeneral.g_bNextRound = !!GameRules_GetProp("m_bInSecondHalfOfRound");

			vResetRound();
		}
		else if (StrEqual(name, "weapon_fire"))
		{
			int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
			if (bIsTank(iTank) && g_esCache[iTank].g_flAttackInterval > 0.0)
			{
				char sWeapon[32];
				event.GetString("weapon", sWeapon, sizeof sWeapon);
				if (StrEqual(sWeapon, "tank_claw"))
				{
					if (!g_esPlayer[iTank].g_bAttacked)
					{
						g_esPlayer[iTank].g_bAttacked = true;

						vAttackInterval(iTank);
					}
					else if (g_esPlayer[iTank].g_flAttackDelay == -1.0 && g_esPlayer[iTank].g_bAttackedAgain)
					{
						CreateTimer(g_esCache[iTank].g_flAttackInterval, tTimerResetAttackDelay, iTankId, TIMER_FLAG_NO_MAPCHANGE);
						vAttackInterval(iTank);
					}
					else if (g_esPlayer[iTank].g_flAttackDelay < GetGameTime())
					{
						g_esPlayer[iTank].g_flAttackDelay = -1.0;
					}
				}
			}
		}
		else if (StrEqual(name, "witch_harasser_set"))
		{
			int iHarasserId = event.GetInt("userid"), iHarasser = GetClientOfUserId(iHarasserId);
			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor) && g_esPlayer[iSurvivor].g_iLadyKiller > 0 && iSurvivor != iHarasser)
				{
					MT_PrintToChat(iSurvivor, "%s %t", MT_TAG2, "RewardLadyKiller2", (g_esPlayer[iSurvivor].g_iLadyKiller - g_esPlayer[iSurvivor].g_iLadyKillerCount));
				}
			}
		}
		else if (StrEqual(name, "witch_killed"))
		{
			int iWitch = event.GetInt("witchid");
			g_esGeneral.g_bWitchKilled[iWitch] = false;
		}

		Call_StartForward(g_esGeneral.g_gfEventFiredForward);
		Call_PushCell(event);
		Call_PushString(name);
		Call_PushCell(dontBroadcast);
		Call_Finish();
	}
}

void vHookEvents(bool hook)
{
	static bool bHooked, bCheck[41];
	if (hook && !bHooked)
	{
		bHooked = true;

		bCheck[0] = HookEventEx("ability_use", vEventHandler);
		bCheck[1] = HookEventEx("bot_player_replace", vEventHandler);
		bCheck[2] = HookEventEx("choke_start", vEventHandler);
		bCheck[3] = HookEventEx("create_panic_event", vEventHandler);
		bCheck[4] = HookEventEx("entity_shoved", vEventHandler);
		bCheck[5] = HookEventEx("finale_escape_start", vEventHandler);
		bCheck[6] = HookEventEx("finale_start", vEventHandler, EventHookMode_Pre);
		bCheck[7] = HookEventEx("finale_vehicle_leaving", vEventHandler);
		bCheck[8] = HookEventEx("finale_vehicle_ready", vEventHandler);
		bCheck[9] = HookEventEx("finale_rush", vEventHandler);
		bCheck[10] = HookEventEx("finale_radio_start", vEventHandler);
		bCheck[11] = HookEventEx("finale_radio_damaged", vEventHandler);
		bCheck[12] = HookEventEx("finale_win", vEventHandler);
		bCheck[13] = HookEventEx("heal_success", vEventHandler);
		bCheck[14] = HookEventEx("infected_hurt", vEventHandler);
		bCheck[15] = HookEventEx("lunge_pounce", vEventHandler);
		bCheck[16] = HookEventEx("mission_lost", vEventHandler);
		bCheck[17] = HookEventEx("player_bot_replace", vEventHandler);
		bCheck[18] = HookEventEx("player_connect", vEventHandler, EventHookMode_Pre);
		bCheck[19] = HookEventEx("player_death", vEventHandler, EventHookMode_Pre);
		bCheck[20] = HookEventEx("player_disconnect", vEventHandler, EventHookMode_Pre);
		bCheck[21] = HookEventEx("player_hurt", vEventHandler);
		bCheck[22] = HookEventEx("player_incapacitated", vEventHandler);
		bCheck[23] = HookEventEx("player_jump", vEventHandler);
		bCheck[24] = HookEventEx("player_ledge_grab", vEventHandler);
		bCheck[25] = HookEventEx("player_now_it", vEventHandler);
		bCheck[26] = HookEventEx("player_no_longer_it", vEventHandler);
		bCheck[27] = HookEventEx("player_shoved", vEventHandler);
		bCheck[28] = HookEventEx("player_spawn", vEventHandler);
		bCheck[29] = HookEventEx("player_team", vEventHandler);
		bCheck[30] = HookEventEx("revive_success", vEventHandler);
		bCheck[31] = HookEventEx("tongue_grab", vEventHandler);
		bCheck[32] = HookEventEx("weapon_fire", vEventHandler);
		bCheck[33] = HookEventEx("witch_harasser_set", vEventHandler);
		bCheck[34] = HookEventEx("witch_killed", vEventHandler);

		if (g_bSecondGame)
		{
			bCheck[35] = HookEventEx("charger_carry_start", vEventHandler);
			bCheck[36] = HookEventEx("charger_pummel_start", vEventHandler);
			bCheck[37] = HookEventEx("finale_vehicle_incoming", vEventHandler);
			bCheck[38] = HookEventEx("finale_bridge_lowering", vEventHandler);
			bCheck[39] = HookEventEx("gauntlet_finale_start", vEventHandler);
			bCheck[40] = HookEventEx("jockey_ride", vEventHandler);
		}

		vHookEventForward(true);
	}
	else if (!hook && bHooked)
	{
		bHooked = false;
		bool bPreHook[41];
		char sEvent[32];

		for (int iPos = 0; iPos < sizeof bCheck; iPos++)
		{
			switch (iPos)
			{
				case 0: sEvent = "ability_use";
				case 1: sEvent = "bot_player_replace";
				case 2: sEvent = "choke_start";
				case 3: sEvent = "create_panic_event";
				case 4: sEvent = "entity_shoved";
				case 5: sEvent = "finale_escape_start";
				case 6: sEvent = "finale_start";
				case 7: sEvent = "finale_vehicle_leaving";
				case 8: sEvent = "finale_vehicle_ready";
				case 9: sEvent = "finale_rush";
				case 10: sEvent = "finale_radio_start";
				case 11: sEvent = "finale_radio_damaged";
				case 12: sEvent = "finale_win";
				case 13: sEvent = "heal_success";
				case 14: sEvent = "infected_hurt";
				case 15: sEvent = "lunge_pounce";
				case 16: sEvent = "mission_lost";
				case 17: sEvent = "player_bot_replace";
				case 18: sEvent = "player_connect";
				case 19: sEvent = "player_death";
				case 20: sEvent = "player_disconnect";
				case 21: sEvent = "player_hurt";
				case 22: sEvent = "player_incapacitated";
				case 23: sEvent = "player_jump";
				case 24: sEvent = "player_ledge_grab";
				case 25: sEvent = "player_now_it";
				case 26: sEvent = "player_no_longer_it";
				case 27: sEvent = "player_shoved";
				case 28: sEvent = "player_spawn";
				case 29: sEvent = "player_team";
				case 30: sEvent = "revive_success";
				case 31: sEvent = "tongue_grab";
				case 32: sEvent = "weapon_fire";
				case 33: sEvent = "witch_harasser_set";
				case 34: sEvent = "witch_killed";
				case 35: sEvent = "charger_carry_start";
				case 36: sEvent = "charger_pummel_start";
				case 37: sEvent = "finale_vehicle_incoming";
				case 38: sEvent = "finale_bridge_lowering";
				case 39: sEvent = "gauntlet_finale_start";
				case 40: sEvent = "jockey_ride";
			}

			if (bCheck[iPos])
			{
				bPreHook[iPos] = (iPos == 6) || (iPos >= 18 && iPos <= 20);

				if (!g_bSecondGame && iPos >= 35 && iPos <= 40)
				{
					continue;
				}

				UnhookEvent(sEvent, vEventHandler, (bPreHook[iPos] ? EventHookMode_Pre : EventHookMode_Post));
			}
		}

		vHookEventForward(false);
	}
}

void vHookGlobalEvents()
{
	HookEvent("round_start", vEventHandler);
	HookEvent("round_end", vEventHandler);
}