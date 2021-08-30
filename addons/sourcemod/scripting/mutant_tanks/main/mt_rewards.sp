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

void vCalculateDeath(int tank, int survivor)
{
	if (!g_esGeneral.g_bFinaleEnded)
	{
		if (g_esPlayer[tank].g_iTankType <= 0 || !bIsCustomTank(tank))
		{
			int iAssistant = bIsSurvivor(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME) ? survivor : 0;
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer, MT_CHECK_INGAME) && GetClientTeam(iPlayer) != 3 && g_esPlayer[iPlayer].g_iTankDamage[tank] > g_esPlayer[iAssistant].g_iTankDamage[tank])
				{
					iAssistant = iPlayer;
				}
			}

			float flPercentage = ((float(g_esPlayer[survivor].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100.0),
				flAssistPercentage = ((float(g_esPlayer[iAssistant].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100.0);

			switch (flAssistPercentage < 90.0)
			{
				case true: vAnnounceDeath(tank, survivor, flPercentage, iAssistant, flAssistPercentage);
				case false: vAnnounceDeath(tank, 0, 0.0, 0, 0.0, false);
			}

			switch (survivor == iAssistant)
			{
				case true: vRewardPriority(tank, 4, survivor);
				case false:
				{
					vRewardPriority(tank, 1, survivor);
					vRewardPriority(tank, 2, iAssistant);
				}
			}

			vRewardPriority(tank, 3, survivor, iAssistant);
			vResetDamage(tank);
			vResetSurvivorStats2(survivor);
			vResetSurvivorStats2(iAssistant);
		}
		else if (g_esCache[tank].g_iAnnounceDeath > 0)
		{
			vAnnounceDeath(tank, 0, 0.0, 0, 0.0);
		}
	}
}

void vChooseRecipient(int survivor, int recipient, const char[] phrase, char[] buffer, int size, char[] buffer2, int size2, bool condition)
{
	switch (condition && survivor != recipient)
	{
		case true: FormatEx(buffer2, size2, "%T", phrase, recipient);
		case false: FormatEx(buffer, size, "%T", phrase, survivor);
	}
}

void vChooseReward(int survivor, int tank, int priority, int setting)
{
	int iType = (setting > 0) ? setting : (1 << GetRandomInt(0, 7));
	if (bIsDeveloper(survivor, 3))
	{
		iType = g_esDeveloper[survivor].g_iDevRewardTypes;
	}

	iType |= iGetUsefulRewards(survivor, tank, iType, priority);
	vRewardSurvivor(survivor, iType, tank, true, priority);
}

void vEndRewards(int survivor, bool force)
{
	bool bCheck = false;
	float flDuration = 0.0, flTime = GetGameTime();
	int iType = 0;
	for (int iPos = 0; iPos < sizeof esPlayer::g_flRewardTime; iPos++)
	{
		if (iPos < sizeof esPlayer::g_flVisualTime)
		{
			if ((g_esPlayer[survivor].g_flVisualTime[0] != -1.0 && g_esPlayer[survivor].g_flVisualTime[0] < flTime) || g_esGeneral.g_bFinaleEnded)
			{
				g_esPlayer[survivor].g_flVisualTime[0] = -1.0;
				g_esPlayer[survivor].g_sScreenColor[0] = '\0';
				g_esPlayer[survivor].g_iScreenColorVisual[0] = -1;
				g_esPlayer[survivor].g_iScreenColorVisual[1] = -1;
				g_esPlayer[survivor].g_iScreenColorVisual[2] = -1;
				g_esPlayer[survivor].g_iScreenColorVisual[3] = -1;
			}

			if ((g_esPlayer[survivor].g_flVisualTime[1] != -1.0 && g_esPlayer[survivor].g_flVisualTime[1] < flTime) || g_esGeneral.g_bFinaleEnded)
			{
				g_esPlayer[survivor].g_flVisualTime[1] = -1.0;
				g_esPlayer[survivor].g_iParticleEffect = 0;
			}

			if ((g_esPlayer[survivor].g_flVisualTime[2] != -1.0 && g_esPlayer[survivor].g_flVisualTime[2] < flTime) || g_esGeneral.g_bFinaleEnded)
			{
				g_esPlayer[survivor].g_flVisualTime[2] = -1.0;
				g_esPlayer[survivor].g_sLoopingVoiceline[0] = '\0';
			}

			if ((g_esPlayer[survivor].g_flVisualTime[3] != -1.0 && g_esPlayer[survivor].g_flVisualTime[3] < flTime) || g_esGeneral.g_bFinaleEnded)
			{
				g_esPlayer[survivor].g_flVisualTime[3] = -1.0;
				g_esPlayer[survivor].g_sLightColor[0] = '\0';

				if (!bIsDeveloper(survivor, 0))
				{
					vRemoveSurvivorLight(survivor);
				}
			}

			if ((g_esPlayer[survivor].g_flVisualTime[4] != -1.0 && g_esPlayer[survivor].g_flVisualTime[4] < flTime) || g_esGeneral.g_bFinaleEnded)
			{
				g_esPlayer[survivor].g_flVisualTime[4] = -1.0;
				g_esPlayer[survivor].g_sBodyColor[0] = '\0';

				if (!bIsDeveloper(survivor, 0))
				{
					SetEntityRenderMode(survivor, RENDER_NORMAL);
					SetEntityRenderColor(survivor, 255, 255, 255, 255);
				}
			}

			if ((g_esPlayer[survivor].g_flVisualTime[5] != -1.0 && g_esPlayer[survivor].g_flVisualTime[5] < flTime) || g_esGeneral.g_bFinaleEnded)
			{
				g_esPlayer[survivor].g_flVisualTime[5] = -1.0;
				g_esPlayer[survivor].g_sOutlineColor[0] = '\0';

				if (!bIsDeveloper(survivor, 0))
				{
					vRemoveGlow(survivor);
				}
			}
		}

		switch (iPos)
		{
			case 0: bCheck = !!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH);
			case 1: bCheck = !!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST);
			case 2: bCheck = !!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST);
			case 3: bCheck = !!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST);
			case 4: bCheck = !!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO);
			case 5: bCheck = !!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_GODMODE);
			case 6: bCheck = !!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_INFAMMO);
		}

		flDuration = g_esPlayer[survivor].g_flRewardTime[iPos];
		if (bCheck && ((flDuration != -1.0 && flDuration < flTime) || g_esGeneral.g_bFinaleEnded || force))
		{
			switch (iPos)
			{
				case 0: iType |= MT_REWARD_HEALTH;
				case 1: iType |= MT_REWARD_SPEEDBOOST;
				case 2: iType |= MT_REWARD_DAMAGEBOOST;
				case 3: iType |= MT_REWARD_ATTACKBOOST;
				case 4: iType |= MT_REWARD_AMMO;
				case 5: iType |= MT_REWARD_GODMODE;
				case 6: iType |= MT_REWARD_INFAMMO;
			}
		}
	}

	if (iType > 0)
	{
		vRewardSurvivor(survivor, iType);
	}
}

void vListRewards(int survivor, int count, const char[][] buffers, int maxStrings, char[] buffer, int size)
{
	bool bListed = false;
	for (int iPos = 0; iPos < maxStrings; iPos++)
	{
		if (buffers[iPos][0] != '\0')
		{
			switch (bListed)
			{
				case true:
				{
					switch (iPos < (maxStrings - 1) && buffers[iPos + 1][0] != '\0')
					{
						case true: Format(buffer, size, "%s{default}, {yellow}%s", buffer, buffers[iPos]);
						case false:
						{
							switch (count)
							{
								case 2: Format(buffer, size, "%s{default} %T{yellow} %s", buffer, "AndConjunction", survivor, buffers[iPos]);
								default: Format(buffer, size, "%s{default}, %T{yellow} %s", buffer, "AndConjunction", survivor, buffers[iPos]);
							}
						}
					}
				}
				case false:
				{
					bListed = true;

					FormatEx(buffer, size, "%s", buffers[iPos]);
				}
			}
		}
	}
}

void vListTeammates(int tank, int killer, int assistant, int setting, char[][] lists, int maxLists, int listSize)
{
	if (setting < 3)
	{
		return;
	}

	bool bListed = false;
	char sList[5][768], sTemp[768];
	float flPercentage = 0.0;
	int iIndex = 0, iSize = 0;
	for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
	{
		if (bIsValidClient(iTeammate) && g_esPlayer[iTeammate].g_iTankDamage[tank] > 0 && iTeammate != killer && iTeammate != assistant)
		{
			flPercentage = (float(g_esPlayer[iTeammate].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100;

			switch (bListed)
			{
				case true:
				{
					switch (setting)
					{
						case 3: iSize = FormatEx(sTemp, sizeof sTemp, "{mint}%N{default} ({olive}%i HP{default})", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank]);
						case 4: iSize = FormatEx(sTemp, sizeof sTemp, "{mint}%N{default} ({olive}%.0f{percent}{default})", iTeammate, flPercentage);
						case 5: iSize = FormatEx(sTemp, sizeof sTemp, "{mint}%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank], flPercentage);
					}

					switch (iIndex < sizeof sList - 1 && sList[iIndex][0] != '\0' && (strlen(sList[iIndex]) + iSize + 150) >= sizeof sList[])
					{
						case true:
						{
							iIndex++;

							strcopy(sList[iIndex], sizeof sList[], sTemp);
						}
						case false: Format(sList[iIndex], sizeof sList[], "%s{default}, %s", sList[iIndex], sTemp);
					}

					sTemp[0] = '\0';
				}
				case false:
				{
					bListed = true;

					switch (setting)
					{
						case 3: FormatEx(sList[iIndex], sizeof sList[], "%N{default} ({olive}%i HP{default})", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank]);
						case 4: FormatEx(sList[iIndex], sizeof sList[], "%N{default} ({olive}%.0f{percent}{default})", iTeammate, flPercentage);
						case 5: FormatEx(sList[iIndex], sizeof sList[], "%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", iTeammate, g_esPlayer[iTeammate].g_iTankDamage[tank], flPercentage);
					}
				}
			}
		}
	}

	for (int iPos = 0; iPos < maxLists; iPos++)
	{
		if (sList[iPos][0] != '\0')
		{
			strcopy(lists[iPos], listSize, sList[iPos]);
		}
	}
}

void vRecordDamage(int tank, int killer, int assistant, float percentage, char[] solo, int soloSize, char[][] lists, int maxLists, int listSize)
{
	char sList[5][768];
	int iSetting = g_esCache[tank].g_iDeathDetails;

	switch (iSetting)
	{
		case 0, 3:
		{
			FormatEx(solo, soloSize, "%N{default} ({olive}%i HP{default})", assistant, g_esPlayer[assistant].g_iTankDamage[tank]);
			vListTeammates(tank, killer, assistant, iSetting, sList, sizeof sList, sizeof sList[]);
		}
		case 1, 4:
		{
			FormatEx(solo, soloSize, "%N{default} ({olive}%.0f{percent}{default})", assistant, percentage);
			vListTeammates(tank, killer, assistant, iSetting, sList, sizeof sList, sizeof sList[]);
		}
		case 2, 5:
		{
			FormatEx(solo, soloSize, "%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", assistant, g_esPlayer[assistant].g_iTankDamage[tank], percentage);
			vListTeammates(tank, killer, assistant, iSetting, sList, sizeof sList, sizeof sList[]);
		}
	}

	for (int iPos = 0; iPos < maxLists; iPos++)
	{
		if (sList[iPos][0] != '\0')
		{
			strcopy(lists[iPos], listSize, sList[iPos]);
		}
	}
}

void vRecordKiller(int tank, int killer, float percentage, int assistant, char[] buffer, int size)
{
	if (killer == assistant)
	{
		FormatEx(buffer, size, "%N", killer);

		return;
	}

	switch (g_esCache[tank].g_iDeathDetails)
	{
		case 0, 3: FormatEx(buffer, size, "%N{default} ({olive}%i HP{default})", killer, g_esPlayer[killer].g_iTankDamage[tank]);
		case 1, 4: FormatEx(buffer, size, "%N{default} ({olive}%.0f{percent}{default})", killer, percentage);
		case 2, 5: FormatEx(buffer, size, "%N{default} ({yellow}%i HP{default}) [{olive}%.0f{percent}{default}]", killer, g_esPlayer[killer].g_iTankDamage[tank], percentage);
	}
}

void vResetLadyKiller(bool override)
{
	if (bIsFirstMap() || !g_esGeneral.g_bSameMission || override)
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			g_esPlayer[iSurvivor].g_iLadyKiller = 0;
			g_esPlayer[iSurvivor].g_iLadyKillerCount = 0;
		}
	}
}

void vRewardPriority(int tank, int priority, int recipient = 0, int recipient2 = 0)
{
	char sTankName[33];
	vGetTranslatedName(sTankName, sizeof sTankName, tank);
	float flPercentage = 0.0, flRandom = GetRandomFloat(0.1, 100.0);
	int iPriority = (priority - 1), iSetting = 0;

	switch (priority)
	{
		case 0: return;
		case 1, 2, 4:
		{
			iSetting = bIsValidClient(recipient, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[iPriority] : g_esCache[tank].g_iRewardBots[iPriority];
			if (bIsSurvivor(recipient, MT_CHECK_INDEX|MT_CHECK_INGAME) && iSetting != -1 && flRandom <= g_esCache[tank].g_flRewardChance[iPriority])
			{
				flPercentage = ((float(g_esPlayer[recipient].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100.0);
				if (flPercentage >= g_esCache[tank].g_flRewardPercentage[iPriority])
				{
					vRewardSolo(recipient, tank, iPriority, flPercentage, sTankName);
					vChooseReward(recipient, tank, iPriority, iSetting);
				}
				else if (flPercentage >= g_esCache[tank].g_flRewardPercentage[2])
				{
					vRewardSolo(recipient, tank, 2, flPercentage, sTankName);
					vChooseReward(recipient, tank, 2, iSetting);
				}
				else
				{
					vRewardNotify(recipient, tank, iPriority, "RewardNone", sTankName);
				}
			}
		}
		case 3:
		{
			if (flRandom <= g_esCache[tank].g_flRewardChance[iPriority])
			{
				float[] flPercentages = new float[MaxClients + 1];
				int[] iSurvivors = new int[MaxClients + 1];
				int iSurvivorCount = 0;
				for (int iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
				{
					iSetting = bIsValidClient(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[iPriority] : g_esCache[tank].g_iRewardBots[iPriority];
					if (bIsSurvivor(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME) && g_esPlayer[iTeammate].g_iTankDamage[tank] > 0 && iSetting != -1 && iTeammate != recipient && iTeammate != recipient2)
					{
						flPercentages[iSurvivorCount] = ((float(g_esPlayer[iTeammate].g_iTankDamage[tank]) / float(g_esPlayer[tank].g_iTankHealth)) * 100.0);
						iSurvivors[iSurvivorCount] = iTeammate;
						iSurvivorCount++;
					}
				}

				if (iSurvivorCount > 0)
				{
					SortFloats(flPercentages, (MaxClients + 1), Sort_Descending);
				}

				int iTeammate = 0, iTeammateCount = 0;
				for (int iPos = 0; iPos < iSurvivorCount; iPos++)
				{
					iTeammate = iSurvivors[iPos];
					flPercentage = flPercentages[iPos];
					if (bIsSurvivor(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME))
					{
						if (0 < g_esCache[tank].g_iTeammateLimit <= iTeammateCount)
						{
							vRewardNotify(iTeammate, tank, iPriority, "RewardNone", sTankName);

							continue;
						}

						if (flPercentage >= g_esCache[tank].g_flRewardPercentage[iPriority])
						{
							iSetting = bIsValidClient(iTeammate, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) ? g_esCache[tank].g_iRewardEnabled[iPriority] : g_esCache[tank].g_iRewardBots[iPriority];
							vRewardSolo(iTeammate, tank, iPriority, flPercentage, sTankName);
							vChooseReward(iTeammate, tank, iPriority, iSetting);
							vResetSurvivorStats2(iTeammate);
						}
						else
						{
							vRewardNotify(iTeammate, tank, iPriority, "RewardNone", sTankName);
						}

						iTeammateCount++;
					}
				}
			}
		}
	}
}

void vRewardSolo(int survivor, int tank, int priority, float percentage, const char[] namePhrase)
{
	if (percentage >= 90.0)
	{
		vRewardNotify(survivor, tank, priority, "RewardSolo", namePhrase);
	}
}

void vRewardSurvivor(int survivor, int type, int tank = 0, bool apply = false, int priority = 0)
{
	int iRecipient = iGetRandomRecipient(survivor, tank, priority, false);
	iRecipient = (survivor == iRecipient) ? iGetRandomRecipient(survivor, tank, priority, true) : iRecipient;
	Action aResult = Plugin_Continue;
	bool bDeveloper = bIsDeveloper(survivor, 3), bDeveloper2 = bIsDeveloper(iRecipient, 3);
	float flTime = (bDeveloper && g_esDeveloper[survivor].g_flDevRewardDuration > g_esCache[tank].g_flRewardDuration[priority]) ? g_esDeveloper[survivor].g_flDevRewardDuration : g_esCache[tank].g_flRewardDuration[priority],
		flTime2 = (bDeveloper2 && g_esDeveloper[iRecipient].g_flDevRewardDuration > g_esCache[tank].g_flRewardDuration[priority]) ? g_esDeveloper[iRecipient].g_flDevRewardDuration : g_esCache[tank].g_flRewardDuration[priority];
	int iType = type;

	Call_StartForward(g_esGeneral.g_gfRewardSurvivorForward);
	Call_PushCell(survivor);
	Call_PushCell(tank);
	Call_PushCellRef(iType);
	Call_PushCell(priority);
	Call_PushFloatRef(flTime);
	Call_PushCell(apply);
	Call_Finish(aResult);

	if (aResult == Plugin_Handled)
	{
		return;
	}

	switch (apply)
	{
		case true:
		{
			char sSet[9][64], sSet2[9][64], sTankName[33];
			int iRewardCount = 0, iRewardCount2 = 0;
			vGetTranslatedName(sTankName, sizeof sTankName, tank);

			g_esPlayer[survivor].g_iNotify = g_esCache[tank].g_iRewardNotify[priority];
			g_esPlayer[survivor].g_iPrefsAccess = g_esCache[tank].g_iPrefsNotify[priority];
			g_esPlayer[iRecipient].g_iNotify = g_esCache[tank].g_iRewardNotify[priority];
			g_esPlayer[iRecipient].g_iPrefsAccess = g_esCache[tank].g_iPrefsNotify[priority];

			if ((iType & MT_REWARD_RESPAWN) && bRespawnSurvivor(survivor, (bDeveloper || g_esCache[tank].g_iRespawnLoadoutReward[priority] == 1)) && !(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_RESPAWN))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardRespawn", survivor);
				g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_RESPAWN;
				iRewardCount++;
			}

			if (bIsSurvivor(survivor))
			{
				char sReceived[1024], sShared[1024];
				float flCurrentTime = GetGameTime(), flDuration = flCurrentTime + flTime, flDuration2 = flCurrentTime + flTime2;
				if (iType & MT_REWARD_HEALTH)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
					{
						FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardHealth", survivor);
						vSetupHealthReward(survivor, tank, priority);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_HEALTH;
						iRewardCount++;
					}
					else
					{
						vChooseRecipient(survivor, iRecipient, "RewardHealth", sSet[iRewardCount], sizeof sSet[], sSet2[iRewardCount2], sizeof sSet2[], (g_esPlayer[survivor].g_iRewardStack[0] >= g_esCache[tank].g_iStackLimits[0]));
						if (g_esPlayer[survivor].g_iRewardStack[0] >= g_esCache[tank].g_iStackLimits[0] && survivor != iRecipient)
						{
							vSetupHealthReward(iRecipient, tank, priority);
							iRewardCount2++;

							if (!(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_HEALTH))
							{
								g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_HEALTH;
							}
						}
						else
						{
							vSetupHealthReward(survivor, tank, priority);
							iRewardCount++;
						}
					}

					vSetupRewardDurations(survivor, iRecipient, 0, g_esCache[tank].g_iStackLimits[0], flTime, flTime2, flCurrentTime, flDuration, flDuration2);
				}

				if (iType & MT_REWARD_SPEEDBOOST)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
					{
						FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardSpeedBoost", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_SPEEDBOOST);
						vSetupSpeedBoostReward(survivor, tank, priority, flDuration);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_SPEEDBOOST;
						iRewardCount++;
					}
					else
					{
						vChooseRecipient(survivor, iRecipient, "RewardSpeedBoost", sSet[iRewardCount], sizeof sSet[], sSet2[iRewardCount2], sizeof sSet2[], (g_esPlayer[survivor].g_iRewardStack[1] >= g_esCache[tank].g_iStackLimits[1]));
						if (g_esPlayer[survivor].g_iRewardStack[1] >= g_esCache[tank].g_iStackLimits[1] && survivor != iRecipient)
						{
							vSetupRewardCounts(iRecipient, tank, priority, MT_REWARD_SPEEDBOOST);
							iRewardCount2++;

							if (!(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
							{
								vSetupSpeedBoostReward(iRecipient, tank, priority, flDuration2);
								g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_SPEEDBOOST;
							}
						}
						else
						{
							vSetupRewardCounts(survivor, tank, priority, MT_REWARD_SPEEDBOOST);
							iRewardCount++;
						}
					}

					vSetupRewardDurations(survivor, iRecipient, 1, g_esCache[tank].g_iStackLimits[1], flTime, flTime2, flCurrentTime, flDuration, flDuration2);
				}

				if (iType & MT_REWARD_DAMAGEBOOST)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
					{
						FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardDamageBoost", survivor);
						vRewardLadyKillerMessage(survivor, tank, priority, sReceived, sizeof sReceived);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_DAMAGEBOOST);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_DAMAGEBOOST;
						iRewardCount++;
					}
					else
					{
						vChooseRecipient(survivor, iRecipient, "RewardDamageBoost", sSet[iRewardCount], sizeof sSet[], sSet2[iRewardCount2], sizeof sSet2[], (g_esPlayer[survivor].g_iRewardStack[2] >= g_esCache[tank].g_iStackLimits[2]));
						if (g_esPlayer[survivor].g_iRewardStack[2] >= g_esCache[tank].g_iStackLimits[2] && survivor != iRecipient)
						{
							vRewardLadyKillerMessage(survivor, tank, priority, sReceived, sizeof sReceived);

							if (survivor != iRecipient)
							{
								vRewardLadyKillerMessage(iRecipient, tank, priority, sShared, sizeof sShared);
							}

							vSetupRewardCounts(iRecipient, tank, priority, MT_REWARD_DAMAGEBOOST);
							iRewardCount2++;

							if (!(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
							{
								g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_DAMAGEBOOST;
							}
						}
						else
						{
							vRewardLadyKillerMessage(survivor, tank, priority, sReceived, sizeof sReceived);
							vSetupRewardCounts(survivor, tank, priority, MT_REWARD_DAMAGEBOOST);

							iRewardCount++;
						}
					}

					vSetupRewardDurations(survivor, iRecipient, 2, g_esCache[tank].g_iStackLimits[2], flTime, flTime2, flCurrentTime, flDuration, flDuration2);
				}

				if (iType & MT_REWARD_ATTACKBOOST)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
					{
						FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardAttackBoost", survivor);
						SDKHook(survivor, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_ATTACKBOOST);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_ATTACKBOOST;
						iRewardCount++;
					}
					else
					{
						vChooseRecipient(survivor, iRecipient, "RewardAttackBoost", sSet[iRewardCount], sizeof sSet[], sSet2[iRewardCount2], sizeof sSet2[], (g_esPlayer[survivor].g_iRewardStack[3] >= g_esCache[tank].g_iStackLimits[3]));
						if (g_esPlayer[survivor].g_iRewardStack[3] >= g_esCache[tank].g_iStackLimits[3] && survivor != iRecipient)
						{
							vSetupRewardCounts(iRecipient, tank, priority, MT_REWARD_ATTACKBOOST);
							iRewardCount2++;

							if (!(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
							{
								SDKHook(iRecipient, SDKHook_PostThinkPost, OnSurvivorPostThinkPost);
								g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_ATTACKBOOST;
							}
						}
						else
						{
							vSetupRewardCounts(survivor, tank, priority, MT_REWARD_ATTACKBOOST);
							iRewardCount++;
						}
					}

					vSetupRewardDurations(survivor, iRecipient, 3, g_esCache[tank].g_iStackLimits[3], flTime, flTime2, flCurrentTime, flDuration, flDuration2);
				}

				if (iType & MT_REWARD_AMMO)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO))
					{
						FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardAmmo", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_AMMO);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_AMMO;
						iRewardCount++;

						vSetupAmmoReward(survivor);
					}
					else
					{
						vChooseRecipient(survivor, iRecipient, "RewardAmmo", sSet[iRewardCount], sizeof sSet[], sSet2[iRewardCount2], sizeof sSet2[], (g_esPlayer[survivor].g_iRewardStack[4] >= g_esCache[tank].g_iStackLimits[4]));
						if (g_esPlayer[survivor].g_iRewardStack[4] >= g_esCache[tank].g_iStackLimits[4] && survivor != iRecipient)
						{
							vSetupRewardCounts(iRecipient, tank, priority, MT_REWARD_AMMO);
							iRewardCount2++;

							if (!(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_AMMO))
							{
								g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_AMMO;
							}

							vSetupAmmoReward(iRecipient);
						}
						else
						{
							vSetupRewardCounts(survivor, tank, priority, MT_REWARD_AMMO);
							vSetupAmmoReward(survivor);

							iRewardCount++;
						}
					}

					vSetupRewardDurations(survivor, iRecipient, 4, g_esCache[tank].g_iStackLimits[4], flTime, flTime2, flCurrentTime, flDuration, flDuration2);
				}

				if (iType & MT_REWARD_ITEM)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ITEM))
					{
						vSetupItemReward(survivor, tank, priority, sReceived, sizeof sReceived);
						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_ITEM;
					}

					if (survivor != iRecipient && !(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_ITEM))
					{
						vSetupItemReward(iRecipient, tank, priority, sShared, sizeof sShared);
						g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_ITEM;
					}
				}

				if (sReceived[0] != '\0')
				{
					MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardReceived", sReceived);
				}

				if (survivor != iRecipient && sShared[0] != '\0')
				{
					MT_PrintToChat(iRecipient, "%s %t", MT_TAG3, "RewardShared", survivor, sShared);
				}

				if (iType & MT_REWARD_GODMODE)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_GODMODE))
					{
						FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardGod", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_GODMODE);
						vSetupGodmodeReward(survivor);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_GODMODE;
						iRewardCount++;
					}
					else
					{
						vChooseRecipient(survivor, iRecipient, "RewardGod", sSet[iRewardCount], sizeof sSet[], sSet2[iRewardCount2], sizeof sSet2[], (g_esPlayer[survivor].g_iRewardStack[5] >= g_esCache[tank].g_iStackLimits[5]));
						if (g_esPlayer[survivor].g_iRewardStack[5] >= g_esCache[tank].g_iStackLimits[5] && survivor != iRecipient)
						{
							vSetupRewardCounts(iRecipient, tank, priority, MT_REWARD_GODMODE);
							iRewardCount2++;

							if (!(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_GODMODE))
							{
								vSetupGodmodeReward(iRecipient);
								g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_GODMODE;
							}
						}
						else
						{
							vSetupRewardCounts(survivor, tank, priority, MT_REWARD_GODMODE);
							iRewardCount++;
						}
					}

					vSetupRewardDurations(survivor, iRecipient, 5, g_esCache[tank].g_iStackLimits[5], flTime, flTime2, flCurrentTime, flDuration, flDuration2);
				}

				if ((iType & MT_REWARD_REFILL))
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_REFILL))
					{
						vSetupRefillReward(survivor, sSet[iRewardCount], sizeof sSet[]);
						iRewardCount++;
					}

					if (survivor != iRecipient && !(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_REFILL))
					{
						vSetupRefillReward(iRecipient, sSet2[iRewardCount2], sizeof sSet2[]);
						iRewardCount2++;
					}
				}

				if (iType & MT_REWARD_INFAMMO)
				{
					if (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_INFAMMO))
					{
						FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardInfAmmo", survivor);
						vSetupRewardCounts(survivor, tank, priority, MT_REWARD_INFAMMO);

						g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_INFAMMO;
						iRewardCount++;
					}
					else
					{
						vChooseRecipient(survivor, iRecipient, "RewardInfAmmo", sSet[iRewardCount], sizeof sSet[], sSet2[iRewardCount2], sizeof sSet2[], (g_esPlayer[survivor].g_iRewardStack[6] >= g_esCache[tank].g_iStackLimits[6]));
						if (g_esPlayer[survivor].g_iRewardStack[6] >= g_esCache[tank].g_iStackLimits[6] && survivor != iRecipient)
						{
							vSetupRewardCounts(iRecipient, tank, priority, MT_REWARD_INFAMMO);
							iRewardCount2++;

							if (!(g_esPlayer[iRecipient].g_iRewardTypes & MT_REWARD_INFAMMO))
							{
								g_esPlayer[iRecipient].g_iRewardTypes |= MT_REWARD_INFAMMO;
							}
						}
						else
						{
							vSetupRewardCounts(survivor, tank, priority, MT_REWARD_INFAMMO);
							iRewardCount++;
						}
					}

					vSetupRewardDurations(survivor, iRecipient, 6, g_esCache[tank].g_iStackLimits[6], flTime, flTime2, flCurrentTime, flDuration, flDuration2);
				}

				char sRewards[1024];
				vListRewards(survivor, iRewardCount, sSet, sizeof sSet, sRewards, sizeof sRewards);
				if (sRewards[0] != '\0')
				{
					vRewardMessage(survivor, survivor, priority, iRewardCount, sRewards, sTankName);
					vSetupVisual(survivor, survivor, tank, priority, iRewardCount, bDeveloper, flTime, flCurrentTime, flDuration);
				}

				if (survivor != iRecipient)
				{
					char sRewards2[1024];
					vListRewards(iRecipient, iRewardCount2, sSet2, sizeof sSet2, sRewards2, sizeof sRewards2);
					if (sRewards2[0] != '\0')
					{
						vRewardMessage(iRecipient, survivor, priority, iRewardCount2, sRewards2, sTankName);
						vSetupVisual(iRecipient, survivor, tank, priority, iRewardCount2, bDeveloper2, flTime2, flCurrentTime, flDuration2);
					}

					vResetSurvivorStats2(iRecipient);
				}
			}
		}
		case false:
		{
			char sSet[8][64];
			int iRewardCount = 0;
			if ((iType & MT_REWARD_HEALTH) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardHealth", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_HEALTH;
				g_esPlayer[survivor].g_flRewardTime[0] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[0] = 0;
				g_esPlayer[survivor].g_flHealPercent = 0.0;
				g_esPlayer[survivor].g_iHealthRegen = 0;
				g_esPlayer[survivor].g_iLifeLeech = 0;
				g_esPlayer[survivor].g_iReviveHealth = 0;
				iRewardCount++;
			}

			if ((iType & MT_REWARD_SPEEDBOOST) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_SPEEDBOOST))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardSpeedBoost", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_SPEEDBOOST;
				g_esPlayer[survivor].g_flRewardTime[1] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[1] = 0;
				g_esPlayer[survivor].g_flJumpHeight = 0.0;
				g_esPlayer[survivor].g_flSpeedBoost = 0.0;
				g_esPlayer[survivor].g_iFallPasses = MT_JUMP_FALLPASSES;
				iRewardCount++;

				if (bIsSurvivor(survivor, MT_CHECK_ALIVE) && !bIsDeveloper(survivor, 5))
				{
					if (flGetAdrenalineTime(survivor) > 0.0)
					{
						vSetAdrenalineTime(survivor, 0.0);
					}

					SDKUnhook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);
					SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
				}
			}

			if ((iType & MT_REWARD_DAMAGEBOOST) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardDamageBoost", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_DAMAGEBOOST;
				g_esPlayer[survivor].g_flRewardTime[2] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[2] = 0;
				g_esPlayer[survivor].g_flDamageBoost = 0.0;
				g_esPlayer[survivor].g_flDamageResistance = 0.0;
				g_esPlayer[survivor].g_iHollowpointAmmo = 0;
				g_esPlayer[survivor].g_iMeleeRange = 0;
				g_esPlayer[survivor].g_iSledgehammerRounds = 0;
				g_esPlayer[survivor].g_iThorns = 0;
				iRewardCount++;
			}

			if ((iType & MT_REWARD_ATTACKBOOST) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_ATTACKBOOST))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardAttackBoost", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_ATTACKBOOST;
				g_esPlayer[survivor].g_flRewardTime[3] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[3] = 0;
				g_esPlayer[survivor].g_flActionDuration = 0.0;
				g_esPlayer[survivor].g_flAttackBoost = 0.0;
				g_esPlayer[survivor].g_iLadderActions = 0;
				g_esPlayer[survivor].g_flShoveDamage = 0.0;
				g_esPlayer[survivor].g_flShoveRate = 0.0;
				g_esPlayer[survivor].g_iShovePenalty = 0;
				iRewardCount++;
			}

			if ((iType & MT_REWARD_AMMO) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardAmmo", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_AMMO;
				g_esPlayer[survivor].g_flRewardTime[4] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[4] = 0;
				g_esPlayer[survivor].g_iAmmoBoost = 0;
				g_esPlayer[survivor].g_iAmmoRegen = 0;
				g_esPlayer[survivor].g_iSpecialAmmo = 0;
				iRewardCount++;

				if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
				{
					vRefillAmmo(survivor, .reset = true);
				}
			}

			if ((iType & MT_REWARD_GODMODE) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_GODMODE))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardGod", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_GODMODE;
				g_esPlayer[survivor].g_flRewardTime[5] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[5] = 0;
				g_esPlayer[survivor].g_flPunchResistance = 0.0;
				g_esPlayer[survivor].g_iCleanKills = 0;
				iRewardCount++;

				if (bIsSurvivor(survivor, MT_CHECK_ALIVE))
				{
					SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);
				}
			}

			if ((iType & MT_REWARD_INFAMMO) && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_INFAMMO))
			{
				FormatEx(sSet[iRewardCount], sizeof sSet[], "%T", "RewardInfAmmo", survivor);

				g_esPlayer[survivor].g_iRewardTypes &= ~MT_REWARD_INFAMMO;
				g_esPlayer[survivor].g_flRewardTime[6] = -1.0;
				g_esPlayer[survivor].g_iRewardStack[6] = 0;
				g_esPlayer[survivor].g_iInfiniteAmmo = 0;
				iRewardCount++;
			}

			char sRewards[1024];
			vListRewards(survivor, iRewardCount, sSet, sizeof sSet, sRewards, sizeof sRewards);
			if (bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && iRewardCount > 0 && g_esPlayer[survivor].g_iNotify >= 2)
			{
				MT_PrintToChat(survivor, "%s %t", MT_TAG2, "RewardEnd", sRewards);
			}

			if (g_esPlayer[survivor].g_iRewardTypes <= 0)
			{
				g_esPlayer[survivor].g_iNotify = 0;
				g_esPlayer[survivor].g_iPrefsAccess = 0;
			}
		}
	}
}

void vRewardItemMessage(int survivor, const char[] list, char[] buffer, int size, bool set)
{
	char sTemp[PLATFORM_MAX_PATH];

	switch (buffer[0] != '\0')
	{
		case true:
		{
			switch (set)
			{
				case true: FormatEx(sTemp, sizeof sTemp, "{default}, {yellow}%s", list);
				case false: FormatEx(sTemp, sizeof sTemp, "{default} %T{yellow} %s", "AndConjunction", survivor, list);
			}

			StrCat(buffer, size, sTemp);
		}
		case false: StrCat(buffer, size, list);
	}
}

void vRewardLadyKillerMessage(int survivor, int tank, int priority, char[] buffer, int size)
{
	if (!bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		return;
	}

	int iLimit = 999999, iReward = g_esCache[tank].g_iLadyKillerReward[priority],
		iUses = (g_esPlayer[survivor].g_iLadyKiller - g_esPlayer[survivor].g_iLadyKillerCount),
		iNewUses = (iReward + iUses),
		iFinalUses = iClamp(iNewUses, 0, iLimit),
		iReceivedUses = (iNewUses > iLimit) ? (iLimit - iUses) : iReward;
	if (g_esPlayer[survivor].g_iNotify >= 2 && iReceivedUses > 0)
	{
		char sTemp[64];
		FormatEx(sTemp, sizeof sTemp, "%T", "RewardLadyKiller", survivor, iReceivedUses);
		StrCat(buffer, size, sTemp);
	}

	g_esPlayer[survivor].g_iLadyKiller = iFinalUses;
	g_esPlayer[survivor].g_iLadyKillerCount = 0;
}

void vRewardMessage(int survivor, int recipient, int priority, int count, const char[] list, const char[] namePhrase)
{
	if (!bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || count == 0 || g_esPlayer[survivor].g_iNotify <= 1)
	{
		return;
	}

	if (survivor != recipient)
	{
		MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardShared", recipient, list);
	}
	else
	{
		switch (priority)
		{
			case 0: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList", list, namePhrase);
			case 1: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList2", list, namePhrase);
			case 2: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList3", list, namePhrase);
			case 3: MT_PrintToChat(survivor, "%s %t", MT_TAG3, "RewardList4", list, namePhrase);
		}
	}
}

void vRewardNotify(int survivor, int tank, int priority, const char[] phrase, const char[] namePhrase)
{
	if (!bIsValidClient(survivor, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iRewardNotify[priority] == 0 || g_esCache[tank].g_iRewardNotify[priority] == 2)
	{
		return;
	}

	switch (StrEqual(phrase, "RewardNone"))
	{
		case true: MT_PrintToChat(survivor, "%s %t", MT_TAG3, phrase, namePhrase);
		case false:
		{
			MT_PrintToChatAll("%s %t", MT_TAG3, phrase, survivor, namePhrase);
			vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, phrase, LANG_SERVER, survivor, namePhrase);
		}
	}
}

void vShowDamageList(int tank, const char[] namePhrase, const char[][] lists, int maxLists)
{
	for (int iPos = 0; iPos < maxLists; iPos++)
	{
		if (g_esCache[tank].g_iDeathDetails > 2 && lists[iPos][0] != '\0')
		{
			switch (iPos)
			{
				case 0:
				{
					MT_PrintToChatAll("%s %t", MT_TAG2, "TeammatesList", namePhrase, lists[iPos]);
					vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, "TeammatesList", LANG_SERVER, namePhrase, lists[iPos]);
				}
				default:
				{
					MT_PrintToChatAll("%s %s", MT_TAG3, lists[iPos]);
					vLogMessage(MT_LOG_LIFE, _, "%s %s", MT_TAG, lists[iPos]);
				}
			}
		}
	}
}

void vSetupAmmoReward(int survivor)
{
	vCheckClipSizes(survivor);
	vRefillAmmo(survivor);
	vGiveSpecialAmmo(survivor);
}

void vSetupGodmodeReward(int survivor)
{
	SetEntProp(survivor, Prop_Data, "m_takedamage", 0, 1);

	if (g_esPlayer[survivor].g_bVomited)
	{
		vUnvomitPlayer(survivor);
	}
}

void vSetupHealthReward(int survivor, int tank, int priority)
{
	vSetupRewardCounts(survivor, tank, priority, MT_REWARD_HEALTH);
	vSaveCaughtSurvivor(survivor);
	vRefillHealth(survivor);
}

void vSetupItemReward(int survivor, int tank, int priority, char[] buffer, int size)
{
	bool bListed = false;
	char sLoadout[320], sItems[5][64], sList[320];

	switch (priority)
	{
		case 0: strcopy(sLoadout, sizeof sLoadout, g_esCache[tank].g_sItemReward);
		case 1: strcopy(sLoadout, sizeof sLoadout, g_esCache[tank].g_sItemReward2);
		case 2: strcopy(sLoadout, sizeof sLoadout, g_esCache[tank].g_sItemReward3);
		case 3: strcopy(sLoadout, sizeof sLoadout, g_esCache[tank].g_sItemReward4);
	}

	if (FindCharInString(sLoadout, ';') != -1)
	{
		int iItemCount = 0;
		ExplodeString(sLoadout, ";", sItems, sizeof sItems, sizeof sItems[]);
		for (int iPos = 0; iPos < sizeof sItems; iPos++)
		{
			if (sItems[iPos][0] != '\0')
			{
				iItemCount++;

				vCheatCommand(survivor, "give", sItems[iPos]);
				ReplaceString(sItems[iPos], sizeof sItems[], "_", " ");

				switch (bListed)
				{
					case true:
					{
						switch (iPos < (sizeof sItems - 1) && sItems[iPos + 1][0] != '\0')
						{
							case true: Format(sList, sizeof sList, "%s{default}, {yellow}%s", sList, sItems[iPos]);
							case false:
							{
								switch (iItemCount == 2 && buffer[0] == '\0')
								{
									case true: Format(sList, sizeof sList, "%s{default} %T{yellow} %s", sList, "AndConjunction", survivor, sItems[iPos]);
									case false: Format(sList, sizeof sList, "%s{default}, %T{yellow} %s", sList, "AndConjunction", survivor, sItems[iPos]);
								}
							}
						}
					}
					case false:
					{
						bListed = true;

						FormatEx(sList, sizeof sList, "%s", sItems[iPos]);
					}
				}
			}
		}

		vRewardItemMessage(survivor, sList, buffer, size, true);
	}
	else
	{
		vCheatCommand(survivor, "give", sLoadout);
		ReplaceString(sLoadout, sizeof sLoadout, "_", " ");
		vRewardItemMessage(survivor, sLoadout, buffer, size, false);
	}
}

void vSetupRefillReward(int survivor, char[] buffer, int size)
{
	g_esPlayer[survivor].g_iRewardTypes |= MT_REWARD_REFILL;

	FormatEx(buffer, size, "%T", "RewardRefill", survivor);
	vSaveCaughtSurvivor(survivor);
	vCheckClipSizes(survivor);
	vRefillAmmo(survivor, .reset = !(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_AMMO));
	vRefillHealth(survivor);
}

void vSetupRewardCounts(int survivor, int tank, int priority, int type)
{
	switch (type)
	{
		case MT_REWARD_HEALTH:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flHealPercent = g_esCache[tank].g_flHealPercentReward[priority];
				g_esPlayer[survivor].g_iHealthRegen = g_esCache[tank].g_iHealthRegenReward[priority];
				g_esPlayer[survivor].g_iLifeLeech = g_esCache[tank].g_iLifeLeechReward[priority];
				g_esPlayer[survivor].g_iReviveHealth = g_esCache[tank].g_iReviveHealthReward[priority];
			}
			else if ((g_esCache[tank].g_iStackRewards[priority] & type) && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esCache[tank].g_iStackLimits[0] > 0 && g_esPlayer[survivor].g_iRewardStack[0] < g_esCache[tank].g_iStackLimits[0])
			{
				g_esPlayer[survivor].g_flHealPercent += g_esCache[tank].g_flHealPercentReward[priority] / 2.0;
				g_esPlayer[survivor].g_flHealPercent = flClamp(g_esPlayer[survivor].g_flHealPercent, 1.0, 100.0);
				g_esPlayer[survivor].g_iHealthRegen += g_esCache[tank].g_iHealthRegenReward[priority];
				g_esPlayer[survivor].g_iHealthRegen = iClamp(g_esPlayer[survivor].g_iHealthRegen, 0, MT_MAXHEALTH);
				g_esPlayer[survivor].g_iLifeLeech += g_esCache[tank].g_iLifeLeechReward[priority];
				g_esPlayer[survivor].g_iLifeLeech = iClamp(g_esPlayer[survivor].g_iLifeLeech, 0, MT_MAXHEALTH);
				g_esPlayer[survivor].g_iReviveHealth += g_esCache[tank].g_iReviveHealthReward[priority];
				g_esPlayer[survivor].g_iReviveHealth = iClamp(g_esPlayer[survivor].g_iReviveHealth, 0, MT_MAXHEALTH);
				g_esPlayer[survivor].g_iRewardStack[0]++;
			}
		}
		case MT_REWARD_SPEEDBOOST:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flJumpHeight = g_esCache[tank].g_flJumpHeightReward[priority];
				g_esPlayer[survivor].g_flSpeedBoost = g_esCache[tank].g_flSpeedBoostReward[priority];
				g_esPlayer[survivor].g_iFallPasses = 0;
			}
			else if ((g_esCache[tank].g_iStackRewards[priority] & type) && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esCache[tank].g_iStackLimits[1] > 0 && g_esPlayer[survivor].g_iRewardStack[1] < g_esCache[tank].g_iStackLimits[1])
			{
				g_esPlayer[survivor].g_flJumpHeight += g_esCache[tank].g_flJumpHeightReward[priority];
				g_esPlayer[survivor].g_flJumpHeight = flClamp(g_esPlayer[survivor].g_flJumpHeight, 0.1, 999999.0);
				g_esPlayer[survivor].g_flSpeedBoost += g_esCache[tank].g_flSpeedBoostReward[priority];
				g_esPlayer[survivor].g_flSpeedBoost = flClamp(g_esPlayer[survivor].g_flSpeedBoost, 0.1, 999999.0);
				g_esPlayer[survivor].g_iFallPasses = 0;
				g_esPlayer[survivor].g_iRewardStack[1]++;
			}
		}
		case MT_REWARD_DAMAGEBOOST:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flDamageBoost = g_esCache[tank].g_flDamageBoostReward[priority];
				g_esPlayer[survivor].g_flDamageResistance = g_esCache[tank].g_flDamageResistanceReward[priority];
				g_esPlayer[survivor].g_iHollowpointAmmo = g_esCache[tank].g_iHollowpointAmmoReward[priority];
				g_esPlayer[survivor].g_iMeleeRange = g_esCache[tank].g_iMeleeRangeReward[priority];
				g_esPlayer[survivor].g_iSledgehammerRounds = g_esCache[tank].g_iSledgehammerRoundsReward[priority];
				g_esPlayer[survivor].g_iThorns = g_esCache[tank].g_iThornsReward[priority];
			}
			else if ((g_esCache[tank].g_iStackRewards[priority] & type) && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esCache[tank].g_iStackLimits[2] > 0 && g_esPlayer[survivor].g_iRewardStack[2] < g_esCache[tank].g_iStackLimits[2])
			{
				g_esPlayer[survivor].g_flDamageBoost += g_esCache[tank].g_flDamageBoostReward[priority];
				g_esPlayer[survivor].g_flDamageBoost = flClamp(g_esPlayer[survivor].g_flDamageBoost, 0.1, 999999.0);
				g_esPlayer[survivor].g_flDamageResistance -= g_esCache[tank].g_flDamageResistanceReward[priority] / 2.0;
				g_esPlayer[survivor].g_flDamageResistance = flClamp(g_esPlayer[survivor].g_flDamageResistance, 0.1, 1.0);
				g_esPlayer[survivor].g_iHollowpointAmmo = g_esCache[tank].g_iHollowpointAmmoReward[priority];
				g_esPlayer[survivor].g_iMeleeRange += g_esCache[tank].g_iMeleeRangeReward[priority];
				g_esPlayer[survivor].g_iMeleeRange = iClamp(g_esPlayer[survivor].g_iMeleeRange, 0, 999999);
				g_esPlayer[survivor].g_iSledgehammerRounds = g_esCache[tank].g_iSledgehammerRoundsReward[priority];
				g_esPlayer[survivor].g_iThorns = g_esCache[tank].g_iThornsReward[priority];
				g_esPlayer[survivor].g_iRewardStack[2]++;
			}
		}
		case MT_REWARD_ATTACKBOOST:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flActionDuration = g_esCache[tank].g_flActionDurationReward[priority];
				g_esPlayer[survivor].g_flAttackBoost = g_esCache[tank].g_flAttackBoostReward[priority];
				g_esPlayer[survivor].g_iLadderActions = g_esCache[tank].g_iLadderActionsReward[priority];
				g_esPlayer[survivor].g_flShoveDamage = g_esCache[tank].g_flShoveDamageReward[priority];
				g_esPlayer[survivor].g_flShoveRate = g_esCache[tank].g_flShoveRateReward[priority];
				g_esPlayer[survivor].g_iShovePenalty = g_esCache[tank].g_iShovePenaltyReward[priority];
			}
			else if ((g_esCache[tank].g_iStackRewards[priority] & type) && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esCache[tank].g_iStackLimits[3] > 0 && g_esPlayer[survivor].g_iRewardStack[3] < g_esCache[tank].g_iStackLimits[3])
			{
				g_esPlayer[survivor].g_flActionDuration -= g_esCache[tank].g_flActionDurationReward[priority] / 2.0;
				g_esPlayer[survivor].g_flActionDuration = flClamp(g_esPlayer[survivor].g_flActionDuration, 0.1, 999999.0);
				g_esPlayer[survivor].g_flAttackBoost += g_esCache[tank].g_flAttackBoostReward[priority];
				g_esPlayer[survivor].g_flAttackBoost = flClamp(g_esPlayer[survivor].g_flAttackBoost, 0.1, 999999.0);
				g_esPlayer[survivor].g_iLadderActions = g_esCache[tank].g_iLadderActionsReward[priority];
				g_esPlayer[survivor].g_flShoveDamage += g_esCache[tank].g_flShoveDamageReward[priority];
				g_esPlayer[survivor].g_flShoveDamage = flClamp(g_esPlayer[survivor].g_flShoveDamage, 0.1, 999999.0);
				g_esPlayer[survivor].g_flShoveRate -= g_esCache[tank].g_flShoveRateReward[priority] / 2.0;
				g_esPlayer[survivor].g_flShoveRate = flClamp(g_esPlayer[survivor].g_flShoveRate, 0.1, 999999.0);
				g_esPlayer[survivor].g_iShovePenalty = g_esCache[tank].g_iShovePenaltyReward[priority];
				g_esPlayer[survivor].g_iRewardStack[3]++;
			}
		}
		case MT_REWARD_AMMO:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_iAmmoBoost = g_esCache[tank].g_iAmmoBoostReward[priority];
				g_esPlayer[survivor].g_iAmmoRegen = g_esCache[tank].g_iAmmoRegenReward[priority];
				g_esPlayer[survivor].g_iSpecialAmmo = g_esCache[tank].g_iSpecialAmmoReward[priority];
			}
			else if ((g_esCache[tank].g_iStackRewards[priority] & type) && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esCache[tank].g_iStackLimits[4] > 0 && g_esPlayer[survivor].g_iRewardStack[4] < g_esCache[tank].g_iStackLimits[4])
			{
				g_esPlayer[survivor].g_iAmmoBoost = g_esCache[tank].g_iAmmoBoostReward[priority];
				g_esPlayer[survivor].g_iAmmoRegen += g_esCache[tank].g_iAmmoRegenReward[priority];
				g_esPlayer[survivor].g_iAmmoRegen = iClamp(g_esPlayer[survivor].g_iAmmoRegen, 0, 999999);
				g_esPlayer[survivor].g_iSpecialAmmo |= g_esCache[tank].g_iSpecialAmmoReward[priority];
				g_esPlayer[survivor].g_iSpecialAmmo = iClamp(g_esPlayer[survivor].g_iSpecialAmmo, 0, 3);
				g_esPlayer[survivor].g_iRewardStack[4]++;
			}
		}
		case MT_REWARD_GODMODE:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_flPunchResistance = g_esCache[tank].g_flPunchResistanceReward[priority];
				g_esPlayer[survivor].g_iCleanKills = g_esCache[tank].g_iCleanKillsReward[priority];
			}
			else if ((g_esCache[tank].g_iStackRewards[priority] & type) && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esCache[tank].g_iStackLimits[5] > 0 && g_esPlayer[survivor].g_iRewardStack[5] < g_esCache[tank].g_iStackLimits[5])
			{
				g_esPlayer[survivor].g_flPunchResistance -= g_esCache[tank].g_flPunchResistanceReward[priority] / 2.0;
				g_esPlayer[survivor].g_flPunchResistance = flClamp(g_esPlayer[survivor].g_flPunchResistance, 0.1, 1.0);
				g_esPlayer[survivor].g_iCleanKills = g_esCache[tank].g_iCleanKillsReward[priority];
				g_esPlayer[survivor].g_iRewardStack[5]++;
			}
		}
		case MT_REWARD_INFAMMO:
		{
			if (!(g_esPlayer[survivor].g_iRewardTypes & type))
			{
				g_esPlayer[survivor].g_iInfiniteAmmo = g_esCache[tank].g_iInfiniteAmmoReward[priority];
			}
			else if ((g_esCache[tank].g_iStackRewards[priority] & type) && (g_esPlayer[survivor].g_iRewardTypes & type) && g_esCache[tank].g_iStackLimits[6] > 0 && g_esPlayer[survivor].g_iRewardStack[6] < g_esCache[tank].g_iStackLimits[6])
			{
				g_esPlayer[survivor].g_iInfiniteAmmo |= g_esCache[tank].g_iInfiniteAmmoReward[priority];
				g_esPlayer[survivor].g_iInfiniteAmmo = iClamp(g_esPlayer[survivor].g_iInfiniteAmmo, 0, 31);
				g_esPlayer[survivor].g_iRewardStack[6]++;
			}
		}
	}
}

void vSetupRewardDuration(int survivor, int pos, float time, float current, float duration)
{
	if (g_esPlayer[survivor].g_flRewardTime[pos] == -1.0 || (time > (g_esPlayer[survivor].g_flRewardTime[pos] - current)))
	{
		g_esPlayer[survivor].g_flRewardTime[pos] = duration;
	}
}

void vSetupRewardDurations(int survivor, int recipient, int pos, int limit, float time, float time2, float current, float duration, float duration2)
{
	vSetupRewardDuration(survivor, pos, time, current, duration);

	if (g_esPlayer[survivor].g_iRewardStack[pos] >= limit && survivor != recipient)
	{
		vSetupRewardDuration(recipient, pos, time2, current, duration2);
	}
}

void vSetupSpeedBoostReward(int survivor, int tank, int priority, float duration)
{
	SDKHook(survivor, SDKHook_PreThinkPost, OnSpeedPreThinkPost);

	if (!bIsDeveloper(survivor, 5) || flGetAdrenalineTime(survivor) > 0.0)
	{
		vSetAdrenalineTime(survivor, duration);
	}

	switch (priority)
	{
		case 0: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof esPlayer::g_sFallVoiceline, g_esCache[tank].g_sFallVoicelineReward);
		case 1: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof esPlayer::g_sFallVoiceline, g_esCache[tank].g_sFallVoicelineReward2);
		case 2: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof esPlayer::g_sFallVoiceline, g_esCache[tank].g_sFallVoicelineReward3);
		case 3: strcopy(g_esPlayer[survivor].g_sFallVoiceline, sizeof esPlayer::g_sFallVoiceline, g_esCache[tank].g_sFallVoicelineReward4);
	}
}

void vSetupVisual(int survivor, int recipient, int tank, int priority, int count, bool dev, float time, float current, float duration)
{
	if (survivor != recipient && (g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_REFILL) && count == 1)
	{
		return;
	}

	int iVisual = g_esCache[tank].g_iRewardVisual[priority];
	if (iVisual > 0)
	{
#if defined _clientprefs_included
		switch (g_esPlayer[survivor].g_iPrefsAccess)
		{
			case 0: vDefaultCookieSettings(survivor);
			case 1:
			{
				if (AreClientCookiesCached(survivor))
				{
					OnClientCookiesCached(survivor);
				}
			}
		}
#else
		vDefaultCookieSettings(survivor);
#endif
		bool bIgnore = bIsDeveloper(survivor, 0);
		if (dev || (iVisual & MT_VISUAL_SCREEN))
		{
			if (g_esPlayer[survivor].g_flVisualTime[0] == -1.0 || (time > (g_esPlayer[survivor].g_flVisualTime[0] - current)))
			{
				switch (priority)
				{
					case 0: strcopy(g_esPlayer[survivor].g_sScreenColor, sizeof esPlayer::g_sScreenColor, g_esCache[tank].g_sScreenColorVisual);
					case 1: strcopy(g_esPlayer[survivor].g_sScreenColor, sizeof esPlayer::g_sScreenColor, g_esCache[tank].g_sScreenColorVisual2);
					case 2: strcopy(g_esPlayer[survivor].g_sScreenColor, sizeof esPlayer::g_sScreenColor, g_esCache[tank].g_sScreenColorVisual3);
					case 3: strcopy(g_esPlayer[survivor].g_sScreenColor, sizeof esPlayer::g_sScreenColor, g_esCache[tank].g_sScreenColorVisual4);
				}

				char sDelimiter[2];
				sDelimiter = (FindCharInString(g_esPlayer[survivor].g_sScreenColor, ';') != -1) ? ";" : ",";
				vSetSurvivorScreen(survivor, g_esPlayer[survivor].g_sScreenColor, sDelimiter);

				if (g_esPlayer[survivor].g_flVisualTime[0] == -1.0)
				{
					CreateTimer(2.0, tTimerScreenEffect, GetClientUserId(survivor), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}

				if (time > (g_esPlayer[survivor].g_flVisualTime[0] - current))
				{
					g_esPlayer[survivor].g_flVisualTime[0] = duration;
				}
			}
		}

		if (dev || (iVisual & MT_VISUAL_PARTICLE))
		{
			if (g_esPlayer[survivor].g_flVisualTime[1] == -1.0 || (time > (g_esPlayer[survivor].g_flVisualTime[1] - current)))
			{
				int iEffect = g_esCache[tank].g_iParticleEffectVisual[priority];
				if (iEffect > 0 && g_esPlayer[survivor].g_iParticleEffect != iEffect)
				{
					g_esPlayer[survivor].g_iParticleEffect = iEffect;
				}

				if (g_esPlayer[survivor].g_flVisualTime[1] == -1.0)
				{
					CreateTimer(0.75, tTimerParticleVisual, GetClientUserId(survivor), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}

				if (time > (g_esPlayer[survivor].g_flVisualTime[1] - current))
				{
					g_esPlayer[survivor].g_flVisualTime[1] = duration;
				}
			}
		}

		if (dev || (iVisual & MT_VISUAL_VOICELINE))
		{
			if (g_esPlayer[survivor].g_flVisualTime[2] == -1.0 || (time > (g_esPlayer[survivor].g_flVisualTime[2] - current)))
			{
				switch (priority)
				{
					case 0: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof esPlayer::g_sLoopingVoiceline, g_esCache[tank].g_sLoopingVoicelineVisual);
					case 1: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof esPlayer::g_sLoopingVoiceline, g_esCache[tank].g_sLoopingVoicelineVisual2);
					case 2: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof esPlayer::g_sLoopingVoiceline, g_esCache[tank].g_sLoopingVoicelineVisual3);
					case 3: strcopy(g_esPlayer[survivor].g_sLoopingVoiceline, sizeof esPlayer::g_sLoopingVoiceline, g_esCache[tank].g_sLoopingVoicelineVisual4);
				}

				if (g_esPlayer[survivor].g_flVisualTime[2] == -1.0)
				{
					CreateTimer(3.0, tTimerLoopVoiceline, GetClientUserId(survivor), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}

				if (time > (g_esPlayer[survivor].g_flVisualTime[2] - current))
				{
					g_esPlayer[survivor].g_flVisualTime[2] = duration;
				}
			}
		}

		if (dev || (iVisual & MT_VISUAL_LIGHT))
		{
			if (g_esPlayer[survivor].g_flVisualTime[3] == -1.0 || (time > (g_esPlayer[survivor].g_flVisualTime[3] - current)))
			{
				switch (priority)
				{
					case 0: strcopy(g_esPlayer[survivor].g_sLightColor, sizeof esPlayer::g_sLightColor, g_esCache[tank].g_sLightColorVisual);
					case 1: strcopy(g_esPlayer[survivor].g_sLightColor, sizeof esPlayer::g_sLightColor, g_esCache[tank].g_sLightColorVisual2);
					case 2: strcopy(g_esPlayer[survivor].g_sLightColor, sizeof esPlayer::g_sLightColor, g_esCache[tank].g_sLightColorVisual3);
					case 3: strcopy(g_esPlayer[survivor].g_sLightColor, sizeof esPlayer::g_sLightColor, g_esCache[tank].g_sLightColorVisual4);
				}

				if (!bIgnore || g_esDeveloper[survivor].g_sDevFlashlight[0] == '\0')
				{
					char sDelimiter[2];
					sDelimiter = (FindCharInString(g_esPlayer[survivor].g_sLightColor, ';') != -1) ? ";" : ",";
					vSetSurvivorLight(survivor, g_esPlayer[survivor].g_sLightColor, g_esPlayer[survivor].g_bApplyVisuals[3], sDelimiter, true);
				}

				if (time > (g_esPlayer[survivor].g_flVisualTime[3] - current))
				{
					g_esPlayer[survivor].g_flVisualTime[3] = duration;
				}
			}
		}

		if (dev || (iVisual & MT_VISUAL_BODY))
		{
			if (g_esPlayer[survivor].g_flVisualTime[4] == -1.0 || (time > (g_esPlayer[survivor].g_flVisualTime[4] - current)))
			{
				switch (priority)
				{
					case 0: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof esPlayer::g_sBodyColor, g_esCache[tank].g_sBodyColorVisual);
					case 1: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof esPlayer::g_sBodyColor, g_esCache[tank].g_sBodyColorVisual2);
					case 2: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof esPlayer::g_sBodyColor, g_esCache[tank].g_sBodyColorVisual3);
					case 3: strcopy(g_esPlayer[survivor].g_sBodyColor, sizeof esPlayer::g_sBodyColor, g_esCache[tank].g_sBodyColorVisual4);
				}

				if (!bIgnore || g_esDeveloper[survivor].g_sDevSkinColor[0] == '\0')
				{
					char sDelimiter[2];
					sDelimiter = (FindCharInString(g_esPlayer[survivor].g_sBodyColor, ';') != -1) ? ";" : ",";
					vSetSurvivorColor(survivor, g_esPlayer[survivor].g_sBodyColor, g_esPlayer[survivor].g_bApplyVisuals[4], sDelimiter, true);
				}

				if (time > (g_esPlayer[survivor].g_flVisualTime[4] - current))
				{
					g_esPlayer[survivor].g_flVisualTime[4] = duration;
				}
			}
		}

		if (g_bSecondGame && (dev || (iVisual & MT_VISUAL_GLOW)))
		{
			if (g_esPlayer[survivor].g_flVisualTime[5] == -1.0 || (time > (g_esPlayer[survivor].g_flVisualTime[5] - current)))
			{
				switch (priority)
				{
					case 0: strcopy(g_esPlayer[survivor].g_sOutlineColor, sizeof esPlayer::g_sOutlineColor, g_esCache[tank].g_sOutlineColorVisual);
					case 1: strcopy(g_esPlayer[survivor].g_sOutlineColor, sizeof esPlayer::g_sOutlineColor, g_esCache[tank].g_sOutlineColorVisual2);
					case 2: strcopy(g_esPlayer[survivor].g_sOutlineColor, sizeof esPlayer::g_sOutlineColor, g_esCache[tank].g_sOutlineColorVisual3);
					case 3: strcopy(g_esPlayer[survivor].g_sOutlineColor, sizeof esPlayer::g_sOutlineColor, g_esCache[tank].g_sOutlineColorVisual4);
				}

				if (!bIgnore || g_esDeveloper[survivor].g_sDevGlowOutline[0] == '\0')
				{
					char sDelimiter[2];
					sDelimiter = (FindCharInString(g_esPlayer[survivor].g_sOutlineColor, ';') != -1) ? ";" : ",";
					vSetSurvivorOutline(survivor, g_esPlayer[survivor].g_sOutlineColor, g_esPlayer[survivor].g_bApplyVisuals[5], sDelimiter, true);
				}

				if (time > (g_esPlayer[survivor].g_flVisualTime[5] - current))
				{
					g_esPlayer[survivor].g_flVisualTime[5] = duration;
				}
			}
		}

		if (g_esPlayer[survivor].g_iPrefsAccess == 1)
		{
			MT_PrintToChat(survivor, "%s %t", MT_TAG2, "MTPrefsInfo");
		}
	}

	int iEffect = g_esCache[tank].g_iRewardEffect[priority];
	if (iEffect > 0)
	{
		if ((dev || (iEffect & MT_EFFECT_TROPHY)) && g_esPlayer[survivor].g_iEffect[0] == INVALID_ENT_REFERENCE)
		{
			g_esPlayer[survivor].g_iEffect[0] = EntIndexToEntRef(iCreateParticle(survivor, PARTICLE_ACHIEVED, view_as<float>({0.0, 0.0, 50.0}), NULL_VECTOR, 1.5, 1.5));
		}

		if ((dev || (iEffect & MT_EFFECT_FIREWORKS)) && g_esPlayer[survivor].g_iEffect[1] == INVALID_ENT_REFERENCE)
		{
			g_esPlayer[survivor].g_iEffect[1] = EntIndexToEntRef(iCreateParticle(survivor, PARTICLE_FIREWORK, view_as<float>({0.0, 0.0, 50.0}), NULL_VECTOR, 2.0, 1.5));
		}

		if (dev || (iEffect & MT_EFFECT_SOUND))
		{
			EmitSoundToAll(SOUND_ACHIEVEMENT, survivor, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}

		if (dev || (iEffect & MT_EFFECT_THIRDPERSON))
		{
			vExternalView(survivor, 1.5);
		}
	}
}