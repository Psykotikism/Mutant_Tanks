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

void vAnnounce(int tank, const char[] oldname, const char[] name, int mode)
{
	if (bIsTankSupported(tank))
	{
		if (!g_esGeneral.g_bFinaleEnded)
		{
			switch (mode)
			{
				case 0: vAnnounceArrival(tank, name);
				case 1:
				{
					if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_BOSS)
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Evolved", oldname, name, (g_esPlayer[tank].g_iBossStageCount + 1));
						vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Evolved", LANG_SERVER, oldname, name, (g_esPlayer[tank].g_iBossStageCount + 1));
					}
				}
				case 2:
				{
					if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_RANDOM)
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Randomized", oldname, name);
						vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Randomized", LANG_SERVER, oldname, name);
					}
				}
				case 3:
				{
					if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_TRANSFORM)
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Transformed", oldname, name);
						vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Transformed", LANG_SERVER, oldname, name);
					}
				}
				case 4:
				{
					if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_REVERT)
					{
						MT_PrintToChatAll("%s %t", MT_TAG2, "Untransformed", oldname, name);
						vLogMessage(MT_LOG_CHANGE, _, "%s %T", MT_TAG, "Untransformed", LANG_SERVER, oldname, name);
					}
				}
				case 5:
				{
					vAnnounceArrival(tank, name);
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ChangeType");
				}
			}

			if (mode >= 0 && g_esCache[tank].g_iTankNote == 1 && bIsCustomTankSupported(tank))
			{
				char sPhrase[32], sSteamIDFinal[32], sTankNote[32];
				FormatEx(sSteamIDFinal, sizeof sSteamIDFinal, "%s", (TranslationPhraseExists(g_esPlayer[tank].g_sSteamID32) ? g_esPlayer[tank].g_sSteamID32 : g_esPlayer[tank].g_sSteam3ID));
				FormatEx(sPhrase, sizeof sPhrase, "Tank #%i", g_esPlayer[tank].g_iTankType);
				FormatEx(sTankNote, sizeof sTankNote, "%s", ((bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iTankNote == 1 && sSteamIDFinal[0] != '\0') ? sSteamIDFinal : sPhrase));

				bool bExists = TranslationPhraseExists(sTankNote);
				MT_PrintToChatAll("%s %t", MT_TAG3, (bExists ? sTankNote : "NoNote"));
				vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, (bExists ? sTankNote : "NoNote"), LANG_SERVER);
			}
		}

		switch (StrEqual(g_esCache[tank].g_sGlowColor, "rainbow", false))
		{
			case true:
			{
				if (!g_esPlayer[tank].g_bRainbowColor)
				{
					g_esPlayer[tank].g_bRainbowColor = SDKHookEx(tank, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
				}
			}
			case false: vSetTankGlow(tank);
		}
	}
}

void vAnnounceArrival(int tank, const char[] name)
{
	if (!bIsCustomTank(tank) && !g_esGeneral.g_bFinaleEnded)
	{
		if (g_esCache[tank].g_iAnnounceArrival & MT_ARRIVAL_SPAWN)
		{
			int iOption = iGetMessageType(g_esCache[tank].g_iArrivalMessage);
			if (iOption > 0)
			{
				char sPhrase[32];
				FormatEx(sPhrase, sizeof sPhrase, "Arrival%i", iOption);
				MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, name);
				vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, name);
			}
		}

		if (g_esCache[tank].g_iVocalizeArrival == 1 || g_esCache[tank].g_iArrivalSound == 1)
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (g_esCache[tank].g_iVocalizeArrival == 1 && bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
				{
					switch (GetRandomInt(1, 3))
					{
						case 1: vVocalize(iPlayer, "PlayerYellRun");
						case 2: vVocalize(iPlayer, (g_bSecondGame ? "PlayerWarnTank" : "PlayerAlsoWarnTank"));
						case 3: vVocalize(iPlayer, "PlayerBackUp");
					}
				}

				if (g_esCache[tank].g_iArrivalSound == 1 && bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
				{
					EmitSoundToClient(iPlayer, SOUND_SPAWN, iPlayer, SNDCHAN_WEAPON, SNDLEVEL_SCREAMING);
				}
			}
		}
	}
}

void vAnnounceDeath(int tank, int killer, float percentage, int assistant, float assistPercentage, bool override = true)
{
	bool bAnnounce = false;

	switch (g_esCache[tank].g_iAnnounceDeath)
	{
		case 1: bAnnounce = override;
		case 2:
		{
			int iOption = iGetMessageType(g_esCache[tank].g_iDeathMessage);
			if (iOption > 0)
			{
				char sDetails[128], sPhrase[32], sTankName[33], sTeammates[5][768];
				vGetTranslatedName(sTankName, sizeof sTankName, tank);
				if (bIsSurvivor(killer, MT_CHECK_INDEX|MT_CHECK_INGAME))
				{
					char sKiller[128];
					vRecordKiller(tank, killer, percentage, assistant, sKiller, sizeof sKiller);
					FormatEx(sPhrase, sizeof sPhrase, "Killer%i", iOption);
					vRecordDamage(tank, killer, assistant, assistPercentage, sDetails, sizeof sDetails, sTeammates, sizeof sTeammates, sizeof sTeammates[]);
					MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sKiller, sTankName, sDetails);
					vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sKiller, sTankName, sDetails);
					vShowDamageList(tank, sTankName, sTeammates, sizeof sTeammates);
					vVocalizeDeath(killer, assistant, tank);
				}
				else if (assistPercentage >= 1.0)
				{
					FormatEx(sPhrase, sizeof sPhrase, "Assist%i", iOption);
					vRecordDamage(tank, killer, assistant, assistPercentage, sDetails, sizeof sDetails, sTeammates, sizeof sTeammates, sizeof sTeammates[]);
					MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName, sDetails);
					vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName, sDetails);
					vShowDamageList(tank, sTankName, sTeammates, sizeof sTeammates);
					vVocalizeDeath(killer, assistant, tank);
				}
				else
				{
					bAnnounce = override;
				}
			}
		}
	}

	if (!bIsCustomTank(tank))
	{
		if (bAnnounce)
		{
			int iOption = iGetMessageType(g_esCache[tank].g_iDeathMessage);
			if (iOption > 0)
			{
				char sPhrase[32], sTankName[33];
				FormatEx(sPhrase, sizeof sPhrase, "Death%i", iOption);
				vGetTranslatedName(sTankName, sizeof sTankName, tank);
				MT_PrintToChatAll("%s %t", MT_TAG2, sPhrase, sTankName);
				vLogMessage(MT_LOG_LIFE, _, "%s %T", MT_TAG, sPhrase, LANG_SERVER, sTankName);
			}
		}

		if (g_esCache[tank].g_iVocalizeDeath == 1 || g_esCache[tank].g_iDeathSound == 1)
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bAnnounce && g_esCache[tank].g_iVocalizeDeath == 1 && bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE))
				{
					switch (GetRandomInt(1, 3))
					{
						case 1: vVocalize(iPlayer, "PlayerHurrah");
						case 2: vVocalize(iPlayer, "PlayerTaunt");
						case 3: vVocalize(iPlayer, "PlayerNiceJob");
					}
				}

				if (g_esCache[tank].g_iDeathSound == 1 && bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
				{
					EmitSoundToClient(iPlayer, SOUND_DEATH, iPlayer, SNDCHAN_WEAPON, SNDLEVEL_SCREAMING);
				}
			}
		}
	}
}

void vAttackInterval(int tank)
{
	if (bIsTank(tank) && g_esCache[tank].g_flAttackInterval > 0.0)
	{
		int iWeapon = GetPlayerWeaponSlot(tank, 0);
		if (iWeapon > MaxClients)
		{
			g_esPlayer[tank].g_flAttackDelay = (GetGameTime() + g_esCache[tank].g_flAttackInterval);
			SetEntPropFloat(iWeapon, Prop_Send, "m_attackTimer", g_esCache[tank].g_flAttackInterval, 0);
			SetEntPropFloat(iWeapon, Prop_Send, "m_attackTimer", g_esPlayer[tank].g_flAttackDelay, 1);
		}
	}
}

void vBoss(int tank, int limit, int stages, int type, int stage)
{
	if (stages >= stage)
	{
		int iHealth = GetEntProp(tank, Prop_Data, "m_iHealth");
		if (iHealth <= limit)
		{
			g_esPlayer[tank].g_iBossStageCount = stage;

			vResetTankSpeed(tank);
			vSurvivorReactions(tank);
			vSetTankColor(tank, type, false);
			vTankSpawn(tank, 1);

			int iNewHealth = (GetEntProp(tank, Prop_Data, "m_iMaxHealth") + limit),
				iLeftover = (iNewHealth - iHealth),
				iLeftover2 = (iLeftover > MT_MAXHEALTH) ? (iLeftover - MT_MAXHEALTH) : iLeftover,
				iFinalHealth = (iNewHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iNewHealth;
			g_esPlayer[tank].g_iTankHealth += (iLeftover > MT_MAXHEALTH) ? iLeftover2 : iLeftover;
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth);
		}
	}
}

void vChangeTank(int admin, int amount, int mode)
{
	int iTarget = GetClientAimTarget(admin);

	switch (bIsTank(iTarget))
	{
		case true:
		{
			vSetTankColor(iTarget, g_esGeneral.g_iChosenType);
			vTankSpawn(iTarget, 5);
			vExternalView(iTarget, 1.5);

			g_esGeneral.g_iChosenType = 0;
		}
		case false: vSpawnTank(admin, .amount = amount, .mode = mode);
	}
}

void vColorLight(int light, int red, int green, int blue, int alpha)
{
	char sColor[12];
	IntToString(alpha, sColor, sizeof sColor);
	DispatchKeyValue(light, "renderamt", sColor);

	FormatEx(sColor, sizeof sColor, "%i %i %i", red, green, blue);
	DispatchKeyValue(light, "rendercolor", sColor);
}

void vCopyTankStats(int tank, int newtank)
{
	SetEntProp(newtank, Prop_Data, "m_iMaxHealth", GetEntProp(tank, Prop_Data, "m_iMaxHealth"));

	g_esPlayer[newtank].g_bArtificial = g_esPlayer[tank].g_bArtificial;
	g_esPlayer[newtank].g_bBlood = g_esPlayer[tank].g_bBlood;
	g_esPlayer[newtank].g_bBlur = g_esPlayer[tank].g_bBlur;
	g_esPlayer[newtank].g_bBoss = g_esPlayer[tank].g_bBoss;
	g_esPlayer[newtank].g_bCombo = g_esPlayer[tank].g_bCombo;
	g_esPlayer[newtank].g_bElectric = g_esPlayer[tank].g_bElectric;
	g_esPlayer[newtank].g_bFire = g_esPlayer[tank].g_bFire;
	g_esPlayer[newtank].g_bFirstSpawn = g_esPlayer[tank].g_bFirstSpawn;
	g_esPlayer[newtank].g_bIce = g_esPlayer[tank].g_bIce;
	g_esPlayer[newtank].g_bKeepCurrentType = g_esPlayer[tank].g_bKeepCurrentType;
	g_esPlayer[newtank].g_bMeteor = g_esPlayer[tank].g_bMeteor;
	g_esPlayer[newtank].g_bNeedHealth = g_esPlayer[tank].g_bNeedHealth;
	g_esPlayer[newtank].g_bRandomized = g_esPlayer[tank].g_bRandomized;
	g_esPlayer[newtank].g_bSmoke = g_esPlayer[tank].g_bSmoke;
	g_esPlayer[newtank].g_bSpit = g_esPlayer[tank].g_bSpit;
	g_esPlayer[newtank].g_bTransformed = g_esPlayer[tank].g_bTransformed;
	g_esPlayer[newtank].g_bTriggered = g_esPlayer[tank].g_bTriggered;
	g_esPlayer[newtank].g_iBossStageCount = g_esPlayer[tank].g_iBossStageCount;
	g_esPlayer[newtank].g_iCooldown = g_esPlayer[tank].g_iCooldown;
	g_esPlayer[newtank].g_iOldTankType = g_esPlayer[tank].g_iOldTankType;
	g_esPlayer[newtank].g_iTankHealth = g_esPlayer[tank].g_iTankHealth;
	g_esPlayer[newtank].g_iTankType = g_esPlayer[tank].g_iTankType;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		g_esPlayer[iSurvivor].g_iTankDamage[newtank] = g_esPlayer[iSurvivor].g_iTankDamage[tank];
	}

	if (bIsValidClient(newtank, MT_CHECK_FAKECLIENT) && g_esGeneral.g_iSpawnMode == 0)
	{
		vTankMenu(newtank);
	}

	Call_StartForward(g_esGeneral.g_gfCopyStatsForward);
	Call_PushCell(tank);
	Call_PushCell(newtank);
	Call_Finish();
}

void vFlashlightProp(int player, float origin[3], float angles[3], int colors[4])
{
	g_esPlayer[player].g_iFlashlight = CreateEntityByName("light_dynamic");
	if (bIsValidEntity(g_esPlayer[player].g_iFlashlight))
	{
		char sColor[16];
		FormatEx(sColor, sizeof sColor, "%i %i %i %i", iGetRandomColor(colors[0]), iGetRandomColor(colors[1]), iGetRandomColor(colors[2]), iGetRandomColor(colors[3]));
		DispatchKeyValue(g_esPlayer[player].g_iFlashlight, "_light", sColor);

		DispatchKeyValue(g_esPlayer[player].g_iFlashlight, "inner_cone", "0");
		DispatchKeyValue(g_esPlayer[player].g_iFlashlight, "cone", "80");
		DispatchKeyValue(g_esPlayer[player].g_iFlashlight, "brightness", "1");
		DispatchKeyValueFloat(g_esPlayer[player].g_iFlashlight, "spotlight_radius", 240.0);
		DispatchKeyValueFloat(g_esPlayer[player].g_iFlashlight, "distance", 255.0);
		DispatchKeyValue(g_esPlayer[player].g_iFlashlight, "pitch", "-90");
		DispatchKeyValue(g_esPlayer[player].g_iFlashlight, "style", "5");

		float flOrigin[3], flAngles[3], flForward[3];
		GetClientEyePosition(player, origin);
		GetClientEyeAngles(player, angles);
		GetClientEyeAngles(player, flAngles);

		flAngles[0] = 0.0;
		flAngles[2] = 0.0;
		GetAngleVectors(flAngles, flForward, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(flForward, -50.0);

		flForward[2] = 0.0;
		AddVectors(origin, flForward, flOrigin);

		angles[0] += 90.0;
		flOrigin[2] -= 120.0;
		AcceptEntityInput(g_esPlayer[player].g_iFlashlight, "TurnOn");
		TeleportEntity(g_esPlayer[player].g_iFlashlight, flOrigin, angles, NULL_VECTOR);
		DispatchSpawn(g_esPlayer[player].g_iFlashlight);
		vSetEntityParent(g_esPlayer[player].g_iFlashlight, player, true);

		if (bIsTank(player))
		{
			SDKHook(g_esPlayer[player].g_iFlashlight, SDKHook_SetTransmit, OnPropSetTransmit);
		}

		g_esPlayer[player].g_iFlashlight = EntIndexToEntRef(g_esPlayer[player].g_iFlashlight);
	}
}

void vKnockbackTank(int tank, int survivor, int damagetype)
{
	float flResult = (damagetype & DMG_BULLET) ? 1.0 : 10.0;
	if ((bIsDeveloper(survivor, 9) || ((g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_DAMAGEBOOST) && g_esPlayer[survivor].g_iSledgehammerRounds == 1)) && !bIsPlayerIncapacitated(tank) && GetRandomFloat(0.0, 100.0) <= flResult)
	{
		vPerformKnockback(tank, survivor);
	}
}

void vLifeLeech(int survivor, int damagetype = 0, int tank = 0, int type = 5)
{
	if (!bIsSurvivor(survivor) || bIsSurvivorDisabled(survivor) || (bIsTank(tank) && (bIsPlayerIncapacitated(tank) || bIsCustomTank(tank))) || (damagetype != 0 && !(damagetype & DMG_CLUB) && !(damagetype & DMG_SLASH)))
	{
		return;
	}

	bool bDeveloper = bIsDeveloper(survivor, type);
	int iLeech;

	switch (type)
	{
		case 5: iLeech = (bDeveloper && g_esDeveloper[survivor].g_iDevLifeLeech > g_esPlayer[survivor].g_iLifeLeech) ? g_esDeveloper[survivor].g_iDevLifeLeech : g_esPlayer[survivor].g_iLifeLeech;
		case 7: iLeech = (bDeveloper && g_esDeveloper[survivor].g_iDevHealthRegen > g_esPlayer[survivor].g_iHealthRegen) ? g_esDeveloper[survivor].g_iDevHealthRegen : g_esPlayer[survivor].g_iHealthRegen;
		default: return;
	}

	if ((!bDeveloper && (!(g_esPlayer[survivor].g_iRewardTypes & MT_REWARD_HEALTH) || g_esPlayer[survivor].g_flRewardTime[0] == -1.0)) || iLeech == 0)
	{
		return;
	}

	float flTempHealth = flGetTempHealth(survivor, g_esGeneral.g_cvMTPainPillsDecayRate.FloatValue);
	int iHealth = GetEntProp(survivor, Prop_Data, "m_iHealth"), iMaxHealth = GetEntProp(survivor, Prop_Data, "m_iMaxHealth");
	if (g_esPlayer[survivor].g_iReviveCount > 0 || g_esPlayer[survivor].g_bLastLife)
	{
		switch ((flTempHealth + iLeech) > iMaxHealth)
		{
			case true: vSetTempHealth(survivor, float(iMaxHealth));
			case false: vSetTempHealth(survivor, (flTempHealth + iLeech));
		}
	}
	else
	{
		switch ((iHealth + iLeech) > iMaxHealth)
		{
			case true: SetEntProp(survivor, Prop_Data, "m_iHealth", iMaxHealth);
			case false: SetEntProp(survivor, Prop_Data, "m_iHealth", (iHealth + iLeech));
		}

		float flHealth = (flTempHealth - iLeech);
		vSetTempHealth(survivor, ((flHealth < 0.0) ? 0.0 : flHealth));
	}

	if ((iHealth + flGetTempHealth(survivor, g_esGeneral.g_cvMTPainPillsDecayRate.FloatValue)) > iMaxHealth)
	{
		vSetTempHealth(survivor, float(iMaxHealth - iHealth));
	}
}

void vLightProp(int tank, int light, float origin[3], float angles[3])
{
	g_esPlayer[tank].g_iLight[light] = CreateEntityByName("beam_spotlight");
	if (bIsValidEntity(g_esPlayer[tank].g_iLight[light]))
	{
		if (light < 3)
		{
			char sTargetName[64];
			FormatEx(sTargetName, sizeof sTargetName, "mutant_tank_light_%i_%i_%i", tank, g_esPlayer[tank].g_iTankType, light);
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "targetname", sTargetName);

			DispatchKeyValueVector(g_esPlayer[tank].g_iLight[light], "origin", origin);
			DispatchKeyValueVector(g_esPlayer[tank].g_iLight[light], "angles", angles);
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "fadescale", "1");
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "fademindist", "-1");

			vColorLight(g_esPlayer[tank].g_iLight[light], iGetRandomColor(g_esCache[tank].g_iLightColor[0]), iGetRandomColor(g_esCache[tank].g_iLightColor[1]), iGetRandomColor(g_esCache[tank].g_iLightColor[2]), iGetRandomColor(g_esCache[tank].g_iLightColor[3]));
		}
		else
		{
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "haloscale", "100");
			vColorLight(g_esPlayer[tank].g_iLight[light], iGetRandomColor(g_esCache[tank].g_iCrownColor[0]), iGetRandomColor(g_esCache[tank].g_iCrownColor[1]), iGetRandomColor(g_esCache[tank].g_iCrownColor[2]), iGetRandomColor(g_esCache[tank].g_iCrownColor[3]));
		}

		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "spotlightwidth", "10");
		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "spotlightlength", "50");
		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "spawnflags", "3");
		DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "maxspeed", "100");
		DispatchKeyValueFloat(g_esPlayer[tank].g_iLight[light], "HDRColorScale", 0.7);

		float flOrigin[3] = {0.0, 0.0, 70.0}, flAngles[3] = {-45.0, 0.0, 0.0};
		if (light < 3)
		{
			char sParentName[64], sTargetName[64];
			FormatEx(sTargetName, sizeof sTargetName, "mutant_tank_%i_%i_%i", tank, g_esPlayer[tank].g_iTankType, light);
			DispatchKeyValue(tank, "targetname", sTargetName);
			GetEntPropString(tank, Prop_Data, "m_iName", sParentName, sizeof sParentName);
			DispatchKeyValue(g_esPlayer[tank].g_iLight[light], "parentname", sParentName);

			SetVariantString(sParentName);
			AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "SetParent", g_esPlayer[tank].g_iLight[light], g_esPlayer[tank].g_iLight[light]);
			SetEntPropEnt(g_esPlayer[tank].g_iLight[light], Prop_Send, "m_hOwnerEntity", tank);

			switch (light)
			{
				case 0:
				{
					SetVariantString("mouth");
					vSetVector(angles, -90.0, 0.0, 0.0);
				}
				case 1:
				{
					SetVariantString("rhand");
					vSetVector(angles, 90.0, 0.0, 0.0);
				}
				case 2:
				{
					SetVariantString("lhand");
					vSetVector(angles, -90.0, 0.0, 0.0);
				}
			}

			AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "SetParentAttachment");
		}
		else
		{
			vSetEntityParent(g_esPlayer[tank].g_iLight[light], tank, true);

			switch (light)
			{
				case 3: flAngles[1] = 60.0;
				case 4: flAngles[1] = 120.0;
				case 5: flAngles[1] = 180.0;
				case 6: flAngles[1] = 240.0;
				case 7: flAngles[1] = 300.0;
				case 8: flAngles[1] = 360.0;
			}
		}

		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "Enable");
		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "DisableCollision");
		AcceptEntityInput(g_esPlayer[tank].g_iLight[light], "TurnOn");

		switch (light)
		{
			case 0, 1, 2: TeleportEntity(g_esPlayer[tank].g_iLight[light], NULL_VECTOR, angles, NULL_VECTOR);
			case 3, 4, 5, 6, 7, 8: TeleportEntity(g_esPlayer[tank].g_iLight[light], flOrigin, flAngles, NULL_VECTOR);
		}

		DispatchSpawn(g_esPlayer[tank].g_iLight[light]);
		SDKHook(g_esPlayer[tank].g_iLight[light], SDKHook_SetTransmit, OnPropSetTransmit);
		g_esPlayer[tank].g_iLight[light] = EntIndexToEntRef(g_esPlayer[tank].g_iLight[light]);
	}
}

void vMutateTank(int tank, int type)
{
	if (bCanTypeSpawn())
	{
		bool bVersus = bIsVersusModeRound(2);
		int iType = 0;
		if (type == 0 && g_esPlayer[tank].g_iTankType <= 0)
		{
			if (bVersus)
			{
				iType = g_esGeneral.g_alCompTypes.Get(0);
				g_esGeneral.g_alCompTypes.Erase(0);

				vSetTankColor(tank, iType, false);
			}
			else
			{
				switch (g_esGeneral.g_bFinalMap && g_esGeneral.g_iTankWave > 0)
				{
					case true: iType = iChooseTank(tank, 1, g_esGeneral.g_iFinaleMinTypes[g_esGeneral.g_iTankWave - 1], g_esGeneral.g_iFinaleMaxTypes[g_esGeneral.g_iTankWave - 1]);
					case false: iType = (g_esGeneral.g_bNormalMap && g_esGeneral.g_iRegularMode == 1 && g_esGeneral.g_iRegularWave == 1) ? iChooseTank(tank, 1, g_esGeneral.g_iRegularMinType, g_esGeneral.g_iRegularMaxType) : iChooseTank(tank, 1);
				}
			}

			if (!g_esGeneral.g_bForceSpawned)
			{
				DataPack dpCountCheck;
				CreateDataTimer(g_esGeneral.g_flExtrasDelay, tTimerTankCountCheck, dpCountCheck, TIMER_FLAG_NO_MAPCHANGE);
				dpCountCheck.WriteCell(GetClientUserId(tank));

				switch (g_esGeneral.g_bFinalMap)
				{
					case true:
					{
						switch (g_esGeneral.g_iTankWave)
						{
							case 0: dpCountCheck.WriteCell(0);
							default:
							{
								switch (g_esGeneral.g_iFinaleAmount)
								{
									case 0: dpCountCheck.WriteCell(g_esGeneral.g_iFinaleWave[g_esGeneral.g_iTankWave - 1]);
									default: dpCountCheck.WriteCell(g_esGeneral.g_iFinaleAmount);
								}
							}
						}
					}
					case false: dpCountCheck.WriteCell(g_esGeneral.g_iRegularAmount);
				}
			}
		}
		else if (type != -1)
		{
			switch (bVersus)
			{
				case true:
				{
					iType = g_esGeneral.g_alCompTypes.Get(0);
					g_esGeneral.g_alCompTypes.Erase(0);

					vSetTankColor(tank, iType, false);
				}
				case false:
				{
					iType = (type > 0) ? type : g_esPlayer[tank].g_iTankType;
					vSetTankColor(tank, iType, false, .store = true);
				}
			}
		}

		if (g_esPlayer[tank].g_iTankType > 0)
		{
			vTankSpawn(tank);
			CreateTimer(0.1, tTimerCheckTankView, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			CreateTimer(1.0, tTimerTankUpdate, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esPlayer[tank].g_iFavoriteType > 0 && iType != g_esPlayer[tank].g_iFavoriteType)
			{
				vFavoriteMenu(tank);
			}
		}
		else
		{
			vCacheSettings(tank);
			vSetTankModel(tank);
			vSetTankHealth(tank);
			vResetTankSpeed(tank, false);
			vThrowInterval(tank);

			SDKHook(tank, SDKHook_PostThinkPost, OnTankPostThinkPost);

			switch (bIsTankIdle(tank))
			{
				case true: CreateTimer(0.1, tTimerAnnounce2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				case false: vAnnounceArrival(tank, "NoName");
			}

			g_esPlayer[tank].g_iTankHealth = GetEntProp(tank, Prop_Data, "m_iMaxHealth");
			g_esGeneral.g_iTankCount++;
		}
	}

	g_esGeneral.g_bForceSpawned = false;
	g_esGeneral.g_iChosenType = 0;
}

void vParticleEffects(int tank)
{
	if (bIsTankSupported(tank) && g_esCache[tank].g_iBodyEffects > 0)
	{
		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_BLOOD) && !g_esPlayer[tank].g_bBlood)
		{
			g_esPlayer[tank].g_bBlood = true;

			CreateTimer(0.75, tTimerBloodEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_ELECTRICITY) && !g_esPlayer[tank].g_bElectric)
		{
			g_esPlayer[tank].g_bElectric = true;

			CreateTimer(0.75, tTimerElectricEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_FIRE) && !g_esPlayer[tank].g_bFire)
		{
			g_esPlayer[tank].g_bFire = true;

			CreateTimer(0.75, tTimerFireEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_ICE) && !g_esPlayer[tank].g_bIce)
		{
			g_esPlayer[tank].g_bIce = true;

			CreateTimer(2.0, tTimerIceEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_METEOR) && !g_esPlayer[tank].g_bMeteor)
		{
			g_esPlayer[tank].g_bMeteor = true;

			CreateTimer(6.0, tTimerMeteorEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if ((g_esCache[tank].g_iBodyEffects & MT_PARTICLE_SMOKE) && !g_esPlayer[tank].g_bSmoke)
		{
			g_esPlayer[tank].g_bSmoke = true;

			CreateTimer(1.5, tTimerSmokeEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}

		if (g_bSecondGame && (g_esCache[tank].g_iBodyEffects & MT_PARTICLE_SPIT) && !g_esPlayer[tank].g_bSpit)
		{
			g_esPlayer[tank].g_bSpit = true;

			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

void vPerformKnockback(int special, int survivor)
{
	if (g_esGeneral.g_hSDKShovedBySurvivor != null)
	{
		float flTankOrigin[3], flSurvivorOrigin[3], flDirection[3];
		GetClientAbsOrigin(survivor, flSurvivorOrigin);
		GetClientAbsOrigin(special, flTankOrigin);
		MakeVectorFromPoints(flSurvivorOrigin, flTankOrigin, flDirection);
		NormalizeVector(flDirection, flDirection);
		SDKCall(g_esGeneral.g_hSDKShovedBySurvivor, special, survivor, flDirection);
	}

	SetEntPropFloat(special, Prop_Send, "m_flVelocityModifier", 0.4);
}

void vQueueTank(int admin, int type, bool mode = true, bool log = true)
{
	char sType[5];
	IntToString(type, sType, sizeof sType);
	vTank(admin, sType, mode, log);
}

void vRemoveTankProps(int tank, int mode = 1)
{
	if (bIsValidEntRef(g_esPlayer[tank].g_iBlur))
	{
		g_esPlayer[tank].g_iBlur = EntRefToEntIndex(g_esPlayer[tank].g_iBlur);
		if (bIsValidEntity(g_esPlayer[tank].g_iBlur))
		{
			SDKUnhook(g_esPlayer[tank].g_iBlur, SDKHook_SetTransmit, OnPropSetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iBlur);
		}
	}

	g_esPlayer[tank].g_iBlur = INVALID_ENT_REFERENCE;

	for (int iLight = 0; iLight < sizeof esPlayer::g_iLight; iLight++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iLight[iLight]))
		{
			g_esPlayer[tank].g_iLight[iLight] = EntRefToEntIndex(g_esPlayer[tank].g_iLight[iLight]);
			if (bIsValidEntity(g_esPlayer[tank].g_iLight[iLight]))
			{
				SDKUnhook(g_esPlayer[tank].g_iLight[iLight], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iLight[iLight]);
			}
		}

		g_esPlayer[tank].g_iLight[iLight] = INVALID_ENT_REFERENCE;
	}

	for (int iOzTank = 0; iOzTank < sizeof esPlayer::g_iFlame; iOzTank++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iFlame[iOzTank]))
		{
			g_esPlayer[tank].g_iFlame[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iFlame[iOzTank]);
			if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
			{
				SDKUnhook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iFlame[iOzTank]);
			}
		}

		g_esPlayer[tank].g_iFlame[iOzTank] = INVALID_ENT_REFERENCE;

		if (bIsValidEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]))
		{
			g_esPlayer[tank].g_iOzTank[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iOzTank[iOzTank]);
			if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
			{
				SDKUnhook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iOzTank[iOzTank]);
			}
		}

		g_esPlayer[tank].g_iOzTank[iOzTank] = INVALID_ENT_REFERENCE;
	}

	for (int iRock = 0; iRock < sizeof esPlayer::g_iRock; iRock++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iRock[iRock]))
		{
			g_esPlayer[tank].g_iRock[iRock] = EntRefToEntIndex(g_esPlayer[tank].g_iRock[iRock]);
			if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]))
			{
				SDKUnhook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iRock[iRock]);
			}
		}

		g_esPlayer[tank].g_iRock[iRock] = INVALID_ENT_REFERENCE;
	}

	for (int iTire = 0; iTire < sizeof esPlayer::g_iTire; iTire++)
	{
		if (bIsValidEntRef(g_esPlayer[tank].g_iTire[iTire]))
		{
			g_esPlayer[tank].g_iTire[iTire] = EntRefToEntIndex(g_esPlayer[tank].g_iTire[iTire]);
			if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]))
			{
				SDKUnhook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iTire[iTire]);
			}
		}

		g_esPlayer[tank].g_iTire[iTire] = INVALID_ENT_REFERENCE;
	}

	if (bIsValidEntRef(g_esPlayer[tank].g_iPropaneTank))
	{
		g_esPlayer[tank].g_iPropaneTank = EntRefToEntIndex(g_esPlayer[tank].g_iPropaneTank);
		if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank))
		{
			SDKUnhook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, OnPropSetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iPropaneTank);
		}
	}

	g_esPlayer[tank].g_iPropaneTank = INVALID_ENT_REFERENCE;

	if (bIsValidEntRef(g_esPlayer[tank].g_iFlashlight))
	{
		g_esPlayer[tank].g_iFlashlight = EntRefToEntIndex(g_esPlayer[tank].g_iFlashlight);
		if (bIsValidEntity(g_esPlayer[tank].g_iFlashlight))
		{
			SDKUnhook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, OnPropSetTransmit);
			RemoveEntity(g_esPlayer[tank].g_iFlashlight);
		}
	}

	g_esPlayer[tank].g_iFlashlight = INVALID_ENT_REFERENCE;

	vRemoveGlow(tank);

	if (mode == 1)
	{
		SetEntityRenderMode(tank, RENDER_NORMAL);
		SetEntityRenderColor(tank, 255, 255, 255, 255);
	}
}

void vResetTank(int tank, int mode = 1)
{
	vRemoveTankProps(tank, mode);
	vResetTankSpeed(tank);
	vSpawnModes(tank, false);
}

void vResetTank2(int tank, bool full = true)
{
	g_esPlayer[tank].g_bArtificial = false;
	g_esPlayer[tank].g_bAttackedAgain = false;
	g_esPlayer[tank].g_bBlood = false;
	g_esPlayer[tank].g_bBlur = false;
	g_esPlayer[tank].g_bElectric = false;
	g_esPlayer[tank].g_bFire = false;
	g_esPlayer[tank].g_bFirstSpawn = false;
	g_esPlayer[tank].g_bIce = false;
	g_esPlayer[tank].g_bKeepCurrentType = false;
	g_esPlayer[tank].g_bMeteor = false;
	g_esPlayer[tank].g_bNeedHealth = false;
	g_esPlayer[tank].g_bReplaceSelf = false;
	g_esPlayer[tank].g_bSmoke = false;
	g_esPlayer[tank].g_bSpit = false;
	g_esPlayer[tank].g_bTriggered = false;
	g_esPlayer[tank].g_flAttackDelay = -1.0;
	g_esPlayer[tank].g_iBossStageCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iOldTankType = 0;
	g_esPlayer[tank].g_iTankType = 0;

	for (int iPos = 0; iPos < sizeof esPlayer::g_iThrownRock; iPos++)
	{
		g_esPlayer[tank].g_iThrownRock[iPos] = INVALID_ENT_REFERENCE;
	}

	if (full)
	{
		vResetSurvivorStats(tank, true);
	}
}

void vResetTank3(int tank)
{
	ExtinguishEntity(tank);
	EmitSoundToAll(SOUND_ELECTRICITY, tank);
	vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
	vResetTankSpeed(tank);
	vRemoveGlow(tank);
}

void vResetTankSpeed(int tank, bool mode = true)
{
	if (bIsValidClient(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE))
	{
		switch (mode || g_esCache[tank].g_flRunSpeed <= 0.0)
		{
			case true: SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", 1.0);
			case false: SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", g_esCache[tank].g_flRunSpeed);
		}
	}
}

void vSetProps(int tank)
{
	if (bIsTankSupported(tank))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[0] && (g_esCache[tank].g_iPropsAttached & MT_PROP_BLUR) && !g_esPlayer[tank].g_bBlur)
		{
			float flTankPos[3], flTankAng[3];
			GetClientAbsOrigin(tank, flTankPos);
			GetClientAbsAngles(tank, flTankAng);

			g_esPlayer[tank].g_iBlur = CreateEntityByName("prop_dynamic");
			if (bIsValidEntity(g_esPlayer[tank].g_iBlur))
			{
				g_esPlayer[tank].g_bBlur = true;

				char sModel[32];
				GetEntPropString(tank, Prop_Data, "m_ModelName", sModel, sizeof sModel);

				switch (sModel[21])
				{
					case 'm': SetEntityModel(g_esPlayer[tank].g_iBlur, MODEL_TANK_MAIN);
					case 'd': SetEntityModel(g_esPlayer[tank].g_iBlur, MODEL_TANK_DLC);
					case 'l': SetEntityModel(g_esPlayer[tank].g_iBlur, MODEL_TANK_L4D1);
				}

				switch (StrEqual(g_esCache[tank].g_sSkinColor, "rainbow", false))
				{
					case true:
					{
						if (!g_esPlayer[tank].g_bRainbowColor)
						{
							g_esPlayer[tank].g_bRainbowColor = SDKHookEx(tank, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
						}
					}
					case false:
					{
						int iColor[4];
						GetEntityRenderColor(tank, iColor[0], iColor[1], iColor[2], iColor[3]);
						SetEntityRenderColor(g_esPlayer[tank].g_iBlur, iColor[0], iColor[1], iColor[2], iColor[3]);
					}
				}

				SetEntPropEnt(g_esPlayer[tank].g_iBlur, Prop_Send, "m_hOwnerEntity", tank);

				TeleportEntity(g_esPlayer[tank].g_iBlur, flTankPos, flTankAng, NULL_VECTOR);
				DispatchSpawn(g_esPlayer[tank].g_iBlur);

				AcceptEntityInput(g_esPlayer[tank].g_iBlur, "DisableCollision");
				SetEntProp(g_esPlayer[tank].g_iBlur, Prop_Send, "m_nSequence", GetEntProp(tank, Prop_Send, "m_nSequence"));
				SetEntPropFloat(g_esPlayer[tank].g_iBlur, Prop_Send, "m_flPlaybackRate", 5.0);

				SDKHook(g_esPlayer[tank].g_iBlur, SDKHook_SetTransmit, OnPropSetTransmit);
				g_esPlayer[tank].g_iBlur = EntIndexToEntRef(g_esPlayer[tank].g_iBlur);

				CreateTimer(0.1, tTimerBlurEffect, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}
		}

		float flOrigin[3], flAngles[3];
		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		float flChance = GetRandomFloat(0.1, 100.0);
		for (int iLight = 0; iLight < sizeof esPlayer::g_iLight; iLight++)
		{
			float flValue = (iLight < 3) ? GetRandomFloat(0.1, 100.0) : flChance;
			int iFlag = (iLight < 3) ? MT_PROP_LIGHT : MT_PROP_CROWN, iType = (iLight < 3) ? 1 : 8;
			if ((g_esPlayer[tank].g_iLight[iLight] == 0 || g_esPlayer[tank].g_iLight[iLight] == INVALID_ENT_REFERENCE) && flValue <= g_esCache[tank].g_flPropsChance[iType] && (g_esCache[tank].g_iPropsAttached & iFlag))
			{
				vLightProp(tank, iLight, flOrigin, flAngles);
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iLight[iLight]))
			{
				g_esPlayer[tank].g_iLight[iLight] = EntRefToEntIndex(g_esPlayer[tank].g_iLight[iLight]);
				if (bIsValidEntity(g_esPlayer[tank].g_iLight[iLight]))
				{
					SDKUnhook(g_esPlayer[tank].g_iLight[iLight], SDKHook_SetTransmit, OnPropSetTransmit);
					RemoveEntity(g_esPlayer[tank].g_iLight[iLight]);
				}

				g_esPlayer[tank].g_iLight[iLight] = INVALID_ENT_REFERENCE;
				if (g_esCache[tank].g_iPropsAttached & iFlag)
				{
					vLightProp(tank, iLight, flOrigin, flAngles);
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		for (int iOzTank = 0; iOzTank < sizeof esPlayer::g_iOzTank; iOzTank++)
		{
			if ((g_esPlayer[tank].g_iOzTank[iOzTank] == 0 || g_esPlayer[tank].g_iOzTank[iOzTank] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[2] && (g_esCache[tank].g_iPropsAttached & MT_PROP_OXYGENTANK))
			{
				g_esPlayer[tank].g_iOzTank[iOzTank] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
				{
					SetEntityModel(g_esPlayer[tank].g_iOzTank[iOzTank], MODEL_OXYGENTANK);
					SetEntityRenderColor(g_esPlayer[tank].g_iOzTank[iOzTank], iGetRandomColor(g_esCache[tank].g_iOzTankColor[0]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[1]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[2]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[3]));

					DispatchKeyValueVector(g_esPlayer[tank].g_iOzTank[iOzTank], "origin", flOrigin);
					DispatchKeyValueVector(g_esPlayer[tank].g_iOzTank[iOzTank], "angles", flAngles);
					vSetEntityParent(g_esPlayer[tank].g_iOzTank[iOzTank], tank, true);

					float flOrigin2[3], flAngles2[3] = {0.0, 0.0, 90.0};

					switch (iOzTank)
					{
						case 0:
						{
							SetVariantString("rfoot");
							vSetVector(flOrigin2, 0.0, 30.0, 8.0);
						}
						case 1:
						{
							SetVariantString("lfoot");
							vSetVector(flOrigin2, 0.0, 30.0, -8.0);
						}
					}

					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "SetParentAttachment");
					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "Enable");
					AcceptEntityInput(g_esPlayer[tank].g_iOzTank[iOzTank], "DisableCollision");
					TeleportEntity(g_esPlayer[tank].g_iOzTank[iOzTank], flOrigin2, flAngles2, NULL_VECTOR);
					DispatchSpawn(g_esPlayer[tank].g_iOzTank[iOzTank]);

					SDKHook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
					g_esPlayer[tank].g_iOzTank[iOzTank] = EntIndexToEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]);

					if ((g_esPlayer[tank].g_iFlame[iOzTank] == 0 || g_esPlayer[tank].g_iFlame[iOzTank] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[3] && (g_esCache[tank].g_iPropsAttached & MT_PROP_FLAME))
					{
						g_esPlayer[tank].g_iFlame[iOzTank] = CreateEntityByName("env_steam");
						if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
						{
							SetEntityRenderColor(g_esPlayer[tank].g_iFlame[iOzTank], iGetRandomColor(g_esCache[tank].g_iFlameColor[0]), iGetRandomColor(g_esCache[tank].g_iFlameColor[1]), iGetRandomColor(g_esCache[tank].g_iFlameColor[2]), iGetRandomColor(g_esCache[tank].g_iFlameColor[3]));

							DispatchKeyValueVector(g_esPlayer[tank].g_iFlame[iOzTank], "origin", flOrigin);
							vSetEntityParent(g_esPlayer[tank].g_iFlame[iOzTank], g_esPlayer[tank].g_iOzTank[iOzTank], true);

							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "spawnflags", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Type", "0");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "InitialState", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Spreadspeed", "1");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Speed", "250");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Startsize", "6");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "EndSize", "8");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "Rate", "555");
							DispatchKeyValue(g_esPlayer[tank].g_iFlame[iOzTank], "JetLength", "40");

							float flOrigin3[3] = {-2.0, 0.0, 28.0}, flAngles3[3] = {-90.0, 0.0, -90.0};
							AcceptEntityInput(g_esPlayer[tank].g_iFlame[iOzTank], "TurnOn");
							TeleportEntity(g_esPlayer[tank].g_iFlame[iOzTank], flOrigin3, flAngles3, NULL_VECTOR);
							DispatchSpawn(g_esPlayer[tank].g_iFlame[iOzTank]);

							SDKHook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
							g_esPlayer[tank].g_iFlame[iOzTank] = EntIndexToEntRef(g_esPlayer[tank].g_iFlame[iOzTank]);
						}
					}
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iOzTank[iOzTank]))
			{
				g_esPlayer[tank].g_iOzTank[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iOzTank[iOzTank]);
				if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_OXYGENTANK))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iOzTank[iOzTank], iGetRandomColor(g_esCache[tank].g_iOzTankColor[0]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[1]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[2]), iGetRandomColor(g_esCache[tank].g_iOzTankColor[3]));
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iOzTank[iOzTank]))
					{
						SDKUnhook(g_esPlayer[tank].g_iOzTank[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
						RemoveEntity(g_esPlayer[tank].g_iOzTank[iOzTank]);
					}

					g_esPlayer[tank].g_iOzTank[iOzTank] = INVALID_ENT_REFERENCE;
				}

				if (bIsValidEntRef(g_esPlayer[tank].g_iFlame[iOzTank]))
				{
					g_esPlayer[tank].g_iFlame[iOzTank] = EntRefToEntIndex(g_esPlayer[tank].g_iFlame[iOzTank]);
					if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_FLAME))
					{
						SetEntityRenderColor(g_esPlayer[tank].g_iFlame[iOzTank], iGetRandomColor(g_esCache[tank].g_iFlameColor[0]), iGetRandomColor(g_esCache[tank].g_iFlameColor[1]), iGetRandomColor(g_esCache[tank].g_iFlameColor[2]), iGetRandomColor(g_esCache[tank].g_iFlameColor[3]));
					}
					else
					{
						if (bIsValidEntity(g_esPlayer[tank].g_iFlame[iOzTank]))
						{
							SDKUnhook(g_esPlayer[tank].g_iFlame[iOzTank], SDKHook_SetTransmit, OnPropSetTransmit);
							RemoveEntity(g_esPlayer[tank].g_iFlame[iOzTank]);
						}

						g_esPlayer[tank].g_iFlame[iOzTank] = INVALID_ENT_REFERENCE;
					}
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		for (int iRock = 0; iRock < sizeof esPlayer::g_iRock; iRock++)
		{
			if ((g_esPlayer[tank].g_iRock[iRock] == 0 || g_esPlayer[tank].g_iRock[iRock] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[4] && (g_esCache[tank].g_iPropsAttached & MT_PROP_ROCK))
			{
				g_esPlayer[tank].g_iRock[iRock] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iRock[iRock], iGetRandomColor(g_esCache[tank].g_iRockColor[0]), iGetRandomColor(g_esCache[tank].g_iRockColor[1]), iGetRandomColor(g_esCache[tank].g_iRockColor[2]), iGetRandomColor(g_esCache[tank].g_iRockColor[3]));
					vSetRockModel(tank, g_esPlayer[tank].g_iRock[iRock]);

					DispatchKeyValueVector(g_esPlayer[tank].g_iRock[iRock], "origin", flOrigin);
					DispatchKeyValueVector(g_esPlayer[tank].g_iRock[iRock], "angles", flAngles);
					vSetEntityParent(g_esPlayer[tank].g_iRock[iRock], tank, true);

					switch (iRock)
					{
						case 0, 4, 8, 12, 16: SetVariantString("rshoulder");
						case 1, 5, 9, 13, 17: SetVariantString("lshoulder");
						case 2, 6, 10, 14, 18: SetVariantString("relbow");
						case 3, 7, 11, 15, 19: SetVariantString("lelbow");
					}

					AcceptEntityInput(g_esPlayer[tank].g_iRock[iRock], "SetParentAttachment");
					AcceptEntityInput(g_esPlayer[tank].g_iRock[iRock], "Enable");
					AcceptEntityInput(g_esPlayer[tank].g_iRock[iRock], "DisableCollision");

					if (g_bSecondGame)
					{
						switch (iRock)
						{
							case 0, 1, 4, 5, 8, 9, 12, 13, 16, 17: SetEntPropFloat(g_esPlayer[tank].g_iRock[iRock], Prop_Data, "m_flModelScale", 0.4);
							case 2, 3, 6, 7, 10, 11, 14, 15, 18, 19: SetEntPropFloat(g_esPlayer[tank].g_iRock[iRock], Prop_Data, "m_flModelScale", 0.5);
						}
					}

					flAngles[0] += GetRandomFloat(-90.0, 90.0);
					flAngles[1] += GetRandomFloat(-90.0, 90.0);
					flAngles[2] += GetRandomFloat(-90.0, 90.0);

					TeleportEntity(g_esPlayer[tank].g_iRock[iRock], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(g_esPlayer[tank].g_iRock[iRock]);

					SDKHook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, OnPropSetTransmit);
					g_esPlayer[tank].g_iRock[iRock] = EntIndexToEntRef(g_esPlayer[tank].g_iRock[iRock]);
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iRock[iRock]))
			{
				g_esPlayer[tank].g_iRock[iRock] = EntRefToEntIndex(g_esPlayer[tank].g_iRock[iRock]);
				if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_ROCK))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iRock[iRock], iGetRandomColor(g_esCache[tank].g_iRockColor[0]), iGetRandomColor(g_esCache[tank].g_iRockColor[1]), iGetRandomColor(g_esCache[tank].g_iRockColor[2]), iGetRandomColor(g_esCache[tank].g_iRockColor[3]));
					vSetRockModel(tank, g_esPlayer[tank].g_iRock[iRock]);
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iRock[iRock]))
					{
						SDKUnhook(g_esPlayer[tank].g_iRock[iRock], SDKHook_SetTransmit, OnPropSetTransmit);
						RemoveEntity(g_esPlayer[tank].g_iRock[iRock]);
					}

					g_esPlayer[tank].g_iRock[iRock] = INVALID_ENT_REFERENCE;
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
		flAngles[0] += 90.0;

		for (int iTire = 0; iTire < sizeof esPlayer::g_iTire; iTire++)
		{
			if ((g_esPlayer[tank].g_iTire[iTire] == 0 || g_esPlayer[tank].g_iTire[iTire] == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[5] && (g_esCache[tank].g_iPropsAttached & MT_PROP_TIRE))
			{
				g_esPlayer[tank].g_iTire[iTire] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]))
				{
					SetEntityModel(g_esPlayer[tank].g_iTire[iTire], MODEL_TIRES);
					SetEntityRenderColor(g_esPlayer[tank].g_iTire[iTire], iGetRandomColor(g_esCache[tank].g_iTireColor[0]), iGetRandomColor(g_esCache[tank].g_iTireColor[1]), iGetRandomColor(g_esCache[tank].g_iTireColor[2]), iGetRandomColor(g_esCache[tank].g_iTireColor[3]));

					DispatchKeyValueVector(g_esPlayer[tank].g_iTire[iTire], "origin", flOrigin);
					DispatchKeyValueVector(g_esPlayer[tank].g_iTire[iTire], "angles", flAngles);
					vSetEntityParent(g_esPlayer[tank].g_iTire[iTire], tank, true);

					switch (iTire)
					{
						case 0: SetVariantString("rfoot");
						case 1: SetVariantString("lfoot");
					}

					AcceptEntityInput(g_esPlayer[tank].g_iTire[iTire], "SetParentAttachment");
					AcceptEntityInput(g_esPlayer[tank].g_iTire[iTire], "Enable");
					AcceptEntityInput(g_esPlayer[tank].g_iTire[iTire], "DisableCollision");

					if (g_bSecondGame)
					{
						SetEntPropFloat(g_esPlayer[tank].g_iTire[iTire], Prop_Data, "m_flModelScale", 1.5);
					}

					TeleportEntity(g_esPlayer[tank].g_iTire[iTire], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(g_esPlayer[tank].g_iTire[iTire]);

					SDKHook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, OnPropSetTransmit);
					g_esPlayer[tank].g_iTire[iTire] = EntIndexToEntRef(g_esPlayer[tank].g_iTire[iTire]);
				}
			}
			else if (bIsValidEntRef(g_esPlayer[tank].g_iTire[iTire]))
			{
				g_esPlayer[tank].g_iTire[iTire] = EntRefToEntIndex(g_esPlayer[tank].g_iTire[iTire]);
				if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]) && (g_esCache[tank].g_iPropsAttached & MT_PROP_TIRE))
				{
					SetEntityRenderColor(g_esPlayer[tank].g_iTire[iTire], iGetRandomColor(g_esCache[tank].g_iTireColor[0]), iGetRandomColor(g_esCache[tank].g_iTireColor[1]), iGetRandomColor(g_esCache[tank].g_iTireColor[2]), iGetRandomColor(g_esCache[tank].g_iTireColor[3]));
				}
				else
				{
					if (bIsValidEntity(g_esPlayer[tank].g_iTire[iTire]))
					{
						SDKUnhook(g_esPlayer[tank].g_iTire[iTire], SDKHook_SetTransmit, OnPropSetTransmit);
						RemoveEntity(g_esPlayer[tank].g_iTire[iTire]);
					}

					g_esPlayer[tank].g_iTire[iTire] = INVALID_ENT_REFERENCE;
				}
			}
		}

		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);

		if ((g_esPlayer[tank].g_iPropaneTank == 0 || g_esPlayer[tank].g_iPropaneTank == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[6] && (g_esCache[tank].g_iPropsAttached & MT_PROP_PROPANETANK))
		{
			g_esPlayer[tank].g_iPropaneTank = CreateEntityByName("prop_dynamic_override");
			if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank))
			{
				SetEntityModel(g_esPlayer[tank].g_iPropaneTank, MODEL_PROPANETANK);
				SetEntityRenderColor(g_esPlayer[tank].g_iPropaneTank, iGetRandomColor(g_esCache[tank].g_iPropTankColor[0]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[1]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[2]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[3]));

				DispatchKeyValueVector(g_esPlayer[tank].g_iPropaneTank, "origin", flOrigin);
				DispatchKeyValueVector(g_esPlayer[tank].g_iPropaneTank, "angles", flAngles);
				vSetEntityParent(g_esPlayer[tank].g_iPropaneTank, tank, true);

				SetVariantString("mouth");
				vSetVector(flOrigin, 10.0, 5.0, 0.0);
				vSetVector(flAngles, 60.0, 0.0, -90.0);
				AcceptEntityInput(g_esPlayer[tank].g_iPropaneTank, "SetParentAttachment");
				AcceptEntityInput(g_esPlayer[tank].g_iPropaneTank, "Enable");
				AcceptEntityInput(g_esPlayer[tank].g_iPropaneTank, "DisableCollision");

				if (g_bSecondGame)
				{
					SetEntPropFloat(g_esPlayer[tank].g_iPropaneTank, Prop_Data, "m_flModelScale", 1.1);
				}

				TeleportEntity(g_esPlayer[tank].g_iPropaneTank, flOrigin, flAngles, NULL_VECTOR);
				DispatchSpawn(g_esPlayer[tank].g_iPropaneTank);

				SDKHook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, OnPropSetTransmit);
				g_esPlayer[tank].g_iPropaneTank = EntIndexToEntRef(g_esPlayer[tank].g_iPropaneTank);
			}
		}
		else if (bIsValidEntRef(g_esPlayer[tank].g_iPropaneTank))
		{
			g_esPlayer[tank].g_iPropaneTank = EntRefToEntIndex(g_esPlayer[tank].g_iPropaneTank);
			if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank) && (g_esCache[tank].g_iPropsAttached & MT_PROP_PROPANETANK))
			{
				SetEntityRenderColor(g_esPlayer[tank].g_iPropaneTank, iGetRandomColor(g_esCache[tank].g_iPropTankColor[0]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[1]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[2]), iGetRandomColor(g_esCache[tank].g_iPropTankColor[3]));
			}
			else
			{
				if (bIsValidEntity(g_esPlayer[tank].g_iPropaneTank))
				{
					SDKUnhook(g_esPlayer[tank].g_iPropaneTank, SDKHook_SetTransmit, OnPropSetTransmit);
					RemoveEntity(g_esPlayer[tank].g_iPropaneTank);
				}

				g_esPlayer[tank].g_iPropaneTank = INVALID_ENT_REFERENCE;
			}
		}

		if ((g_esPlayer[tank].g_iFlashlight == 0 || g_esPlayer[tank].g_iFlashlight == INVALID_ENT_REFERENCE) && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPropsChance[7] && (g_esCache[tank].g_iPropsAttached & MT_PROP_FLASHLIGHT))
		{
			vFlashlightProp(tank, flOrigin, flAngles, g_esCache[tank].g_iFlashlightColor);
		}
		else if (bIsValidEntRef(g_esPlayer[tank].g_iFlashlight))
		{
			g_esPlayer[tank].g_iFlashlight = EntRefToEntIndex(g_esPlayer[tank].g_iFlashlight);
			if (bIsValidEntity(g_esPlayer[tank].g_iFlashlight))
			{
				SDKUnhook(g_esPlayer[tank].g_iFlashlight, SDKHook_SetTransmit, OnPropSetTransmit);
				RemoveEntity(g_esPlayer[tank].g_iFlashlight);
			}

			g_esPlayer[tank].g_iFlashlight = INVALID_ENT_REFERENCE;
			if (g_esCache[tank].g_iPropsAttached & MT_PROP_FLASHLIGHT)
			{
				vFlashlightProp(tank, flOrigin, flAngles, g_esCache[tank].g_iFlashlightColor);
			}
		}

		if (!g_esPlayer[tank].g_bRainbowColor)
		{
			g_esPlayer[tank].g_bRainbowColor = SDKHookEx(tank, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
		}
	}
}

void vSetRockColor(int rock)
{
	if (bIsValidEntity(rock) && bIsValidEntRef(g_esGeneral.g_iLauncher))
	{
		g_esGeneral.g_iLauncher = EntRefToEntIndex(g_esGeneral.g_iLauncher);
		if (bIsValidEntity(g_esGeneral.g_iLauncher))
		{
			int iTank = HasEntProp(g_esGeneral.g_iLauncher, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(g_esGeneral.g_iLauncher, Prop_Send, "m_hOwnerEntity") : 0;
			if (bIsTankSupported(iTank))
			{
				SetEntPropEnt(rock, Prop_Data, "m_hThrower", iTank);
				SetEntPropEnt(rock, Prop_Send, "m_hOwnerEntity", g_esGeneral.g_iLauncher);
				vSetRockModel(iTank, rock);

				switch (StrEqual(g_esCache[iTank].g_sRockColor, "rainbow", false))
				{
					case true:
					{
						g_esPlayer[iTank].g_iThrownRock[rock] = EntIndexToEntRef(rock);

						if (!g_esPlayer[iTank].g_bRainbowColor)
						{
							g_esPlayer[iTank].g_bRainbowColor = SDKHookEx(iTank, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
						}
					}
					case false: SetEntityRenderColor(rock, iGetRandomColor(g_esCache[iTank].g_iRockColor[0]), iGetRandomColor(g_esCache[iTank].g_iRockColor[1]), iGetRandomColor(g_esCache[iTank].g_iRockColor[2]), iGetRandomColor(g_esCache[iTank].g_iRockColor[3]));
				}
			}
		}
	}
}

void vSetRockModel(int tank, int rock)
{
	switch (g_esCache[tank].g_iRockModel)
	{
		case 0: SetEntityModel(rock, MODEL_CONCRETE_CHUNK);
		case 1: SetEntityModel(rock, MODEL_TREE_TRUNK);
		case 2: SetEntityModel(rock, ((GetRandomInt(0, 1) == 0) ? MODEL_CONCRETE_CHUNK : MODEL_TREE_TRUNK));
	}
}

void vSetTankColor(int tank, int type = 0, bool change = true, bool revert = false, bool store = false)
{
	if (type == -1)
	{
		return;
	}

	if (g_esPlayer[tank].g_iTankType > 0)
	{
		if (change)
		{
			vResetTank3(tank);
		}

		if (type == 0)
		{
			vRemoveTankProps(tank);
			vChangeTypeForward(tank, g_esPlayer[tank].g_iTankType, type, revert);

			g_esPlayer[tank].g_iTankType = 0;

			return;
		}
		else if (g_esPlayer[tank].g_iTankType == type && !g_esPlayer[tank].g_bReplaceSelf && !g_esPlayer[tank].g_bKeepCurrentType)
		{
			g_esPlayer[tank].g_iTankType = 0;

			vRemoveTankProps(tank);
			vChangeTypeForward(tank, type, g_esPlayer[tank].g_iTankType, revert);

			return;
		}
		else if (type > 0)
		{
			g_esPlayer[tank].g_iOldTankType = g_esPlayer[tank].g_iTankType;
		}
	}

	if (store && bIsVersusModeRound(1))
	{
		g_esGeneral.g_alCompTypes.Push(type);
	}

	g_esPlayer[tank].g_iTankType = type;
	g_esPlayer[tank].g_bReplaceSelf = false;

	vChangeTypeForward(tank, g_esPlayer[tank].g_iOldTankType, g_esPlayer[tank].g_iTankType, revert);
	vCacheSettings(tank);
	vSetTankModel(tank);
	vRemoveGlow(tank);
	vSetTankRainbowColor(tank);
}

void vSetTankGlow(int tank)
{
	if (!g_bSecondGame || g_esCache[tank].g_iGlowEnabled == 0)
	{
		return;
	}

	SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGetRandomColor(g_esCache[tank].g_iGlowColor[0]), iGetRandomColor(g_esCache[tank].g_iGlowColor[1]), iGetRandomColor(g_esCache[tank].g_iGlowColor[2])));
	SetEntProp(tank, Prop_Send, "m_bFlashing", g_esCache[tank].g_iGlowFlashing);
	SetEntProp(tank, Prop_Send, "m_nGlowRangeMin", g_esCache[tank].g_iGlowMinRange);
	SetEntProp(tank, Prop_Send, "m_nGlowRange", g_esCache[tank].g_iGlowMaxRange);
	SetEntProp(tank, Prop_Send, "m_iGlowType", ((bIsTankIdle(tank) || g_esCache[tank].g_iGlowType == 0) ? 2 : 3));
}

void vSetTankHealth(int tank)
{
	int iHumanCount = iGetHumanCount(),
		iSpawnHealth = (g_esCache[tank].g_iBaseHealth > 0) ? g_esCache[tank].g_iBaseHealth : GetEntProp(tank, Prop_Data, "m_iHealth"),
		iExtraHealthNormal = (iSpawnHealth + g_esCache[tank].g_iExtraHealth),
		iExtraHealthBoost = (iHumanCount >= g_esCache[tank].g_iMinimumHumans) ? ((iSpawnHealth * iHumanCount) + g_esCache[tank].g_iExtraHealth) : iExtraHealthNormal,
		iExtraHealthBoost2 = (iHumanCount >= g_esCache[tank].g_iMinimumHumans) ? (iSpawnHealth + (iHumanCount * g_esCache[tank].g_iExtraHealth)) : iExtraHealthNormal,
		iExtraHealthBoost3 = (iHumanCount >= g_esCache[tank].g_iMinimumHumans) ? (iHumanCount * (iSpawnHealth + g_esCache[tank].g_iExtraHealth)) : iExtraHealthNormal,
		iNoBoost = (iExtraHealthNormal > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthNormal,
		iBoost = (iExtraHealthBoost > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost,
		iBoost2 = (iExtraHealthBoost2 > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost2,
		iBoost3 = (iExtraHealthBoost3 > MT_MAXHEALTH) ? MT_MAXHEALTH : iExtraHealthBoost3,
		iNegaNoBoost = (iExtraHealthNormal < iSpawnHealth) ? 1 : iExtraHealthNormal,
		iNegaBoost = (iExtraHealthBoost < iSpawnHealth) ? 1 : iExtraHealthBoost,
		iNegaBoost2 = (iExtraHealthBoost2 < iSpawnHealth) ? 1 : iExtraHealthBoost2,
		iNegaBoost3 = (iExtraHealthBoost3 < iSpawnHealth) ? 1 : iExtraHealthBoost3,
		iFinalNoHealth = (iExtraHealthNormal >= 0) ? iNoBoost : iNegaNoBoost,
		iFinalHealth = (iExtraHealthNormal >= 0) ? iBoost : iNegaBoost,
		iFinalHealth2 = (iExtraHealthNormal >= 0) ? iBoost2 : iNegaBoost2,
		iFinalHealth3 = (iExtraHealthNormal >= 0) ? iBoost3 : iNegaBoost3;
	SetEntProp(tank, Prop_Data, "m_iHealth", iFinalNoHealth);
	SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalNoHealth);

	switch (g_esCache[tank].g_iMultiplyHealth)
	{
		case 1:
		{
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth);
		}
		case 2:
		{
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth2);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth2);
		}
		case 3:
		{
			SetEntProp(tank, Prop_Data, "m_iHealth", iFinalHealth3);
			SetEntProp(tank, Prop_Data, "m_iMaxHealth", iFinalHealth3);
		}
	}
}

void vSetTankModel(int tank)
{
	if (g_esCache[tank].g_iTankModel > 0)
	{
		int iModelCount = 0, iModels[3], iFlag = 0;
		for (int iBit = 0; iBit < sizeof iModels; iBit++)
		{
			iFlag = (1 << iBit);
			if (!(g_esCache[tank].g_iTankModel & iFlag))
			{
				continue;
			}

			iModels[iModelCount] = iFlag;
			iModelCount++;
		}

		if (iModelCount > 0)
		{
			switch (iModels[GetRandomInt(0, (iModelCount - 1))])
			{
				case 1: SetEntityModel(tank, MODEL_TANK_MAIN);
				case 2: SetEntityModel(tank, MODEL_TANK_DLC);
				case 4: SetEntityModel(tank, (g_bSecondGame ? MODEL_TANK_L4D1 : MODEL_TANK_MAIN));
				default:
				{
					switch (GetRandomInt(1, sizeof iModels))
					{
						case 1: SetEntityModel(tank, MODEL_TANK_MAIN);
						case 2: SetEntityModel(tank, MODEL_TANK_DLC);
						case 3: SetEntityModel(tank, (g_bSecondGame ? MODEL_TANK_L4D1 : MODEL_TANK_MAIN));
					}
				}
			}
		}
	}

	if (g_esCache[tank].g_flBurntSkin >= 0.01)
	{
		SetEntPropFloat(tank, Prop_Send, "m_burnPercent", g_esCache[tank].g_flBurntSkin);
	}
	else if (g_esCache[tank].g_flBurntSkin == 0.0)
	{
		SetEntPropFloat(tank, Prop_Send, "m_burnPercent", GetRandomFloat(0.01, 1.0));
	}
}

void vSetTankName(int tank, const char[] oldname, const char[] name, int mode)
{
	if (bIsTankSupported(tank))
	{
		if (!bIsTank(tank, MT_CHECK_FAKECLIENT))
		{
			if (g_esCache[tank].g_sTankName[0] == '\0')
			{
				g_esCache[tank].g_sTankName = "Tank";
			}

			g_esGeneral.g_bHideNameChange = true;
			SetClientName(tank, g_esCache[tank].g_sTankName);
			g_esGeneral.g_bHideNameChange = false;
		}

		switch (bIsTankIdle(tank) && (mode == 0 || mode == 5))
		{
			case true:
			{
				DataPack dpAnnounce;
				CreateDataTimer(0.1, tTimerAnnounce, dpAnnounce, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpAnnounce.WriteCell(GetClientUserId(tank));
				dpAnnounce.WriteString(oldname);
				dpAnnounce.WriteString(name);
				dpAnnounce.WriteCell(mode);
			}
			case false: vAnnounce(tank, oldname, name, mode);
		}
	}
}

void vSetTankRainbowColor(int tank)
{
	switch (StrEqual(g_esCache[tank].g_sSkinColor, "rainbow", false))
	{
		case true:
		{
			if (!g_esPlayer[tank].g_bRainbowColor)
			{
				g_esPlayer[tank].g_bRainbowColor = SDKHookEx(tank, SDKHook_PreThinkPost, OnRainbowPreThinkPost);
			}
		}
		case false:
		{
			SetEntityRenderMode(tank, RENDER_NORMAL);
			SetEntityRenderColor(tank, iGetRandomColor(g_esCache[tank].g_iSkinColor[0]), iGetRandomColor(g_esCache[tank].g_iSkinColor[1]), iGetRandomColor(g_esCache[tank].g_iSkinColor[2]), iGetRandomColor(g_esCache[tank].g_iSkinColor[3]));
		}
	}
}

void vSpawnMessages(int tank)
{
	if (bIsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esTank[g_esPlayer[tank].g_iTankType].g_iHumanSupport == 1 && bHasCoreAdminAccess(tank))
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpawnMessage");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons2");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons3");
		MT_PrintToChat(tank, "%s %t", MT_TAG2, "AbilityButtons4");
	}
}

void vSpawnModes(int tank, bool status)
{
	g_esPlayer[tank].g_bBoss = status;
	g_esPlayer[tank].g_bCombo = status;
	g_esPlayer[tank].g_bRandomized = status;
	g_esPlayer[tank].g_bTransformed = status;
}

void vSpawnTank(int admin, bool log = true, int amount, int mode)
{
	char sCommand[32], sParameter[32];
	sCommand = g_bSecondGame ? "z_spawn_old" : "z_spawn";
	sParameter = (mode == 0) ? "tank" : "tank auto";
	int iType = g_esGeneral.g_iChosenType;
	g_esGeneral.g_bForceSpawned = true;

	switch (amount)
	{
		case 1: vCheatCommand(admin, sCommand, sParameter);
		default:
		{
			for (int iAmount = 0; iAmount <= amount; iAmount++)
			{
				if (iAmount < amount)
				{
					if (bIsValidClient(admin))
					{
						vCheatCommand(admin, sCommand, sParameter);

						g_esGeneral.g_bForceSpawned = true;
						g_esGeneral.g_iChosenType = iType;
					}
				}
				else if (iAmount == amount)
				{
					g_esGeneral.g_iChosenType = 0;
				}
			}
		}
	}

	if (log)
	{
		char sTankName[33];

		switch (iType)
		{
			case -1: FormatEx(sTankName, sizeof sTankName, "Tank");
			default: strcopy(sTankName, sizeof sTankName, g_esTank[iType].g_sTankName);
		}

		vLogCommand(admin, MT_CMD_SPAWN, "%s %N:{default} Spawned{mint} %i{olive} %s%s{default}.", MT_TAG4, admin, amount, sTankName, ((amount > 1) ? "s" : ""));
		vLogMessage(MT_LOG_SERVER, _, "%s %N: Spawned %i %s%s.", MT_TAG, admin, amount, sTankName, ((amount > 1) ? "s" : ""));
	}
}

void vTank(int admin, char[] type, bool spawn = false, bool log = true, int amount = 1, int mode = 0)
{
	int iType = StringToInt(type);

	switch (iType)
	{
		case -1: g_esGeneral.g_iChosenType = iType;
		case 0:
		{
			if (bIsValidClient(admin) && bIsDeveloper(admin, .real = true) && StrEqual(type, "mt_dev_access", false))
			{
				g_esDeveloper[admin].g_iDevAccess = amount;

				vSetupDeveloper(admin);
				MT_PrintToChat(admin, "%s %s{mint}, your current access level for testing has been set to{yellow} %i{mint}.", MT_TAG4, MT_AUTHOR, amount);

				return;
			}
			else
			{
				char sPhrase[32], sTankName[33];
				int iTypeCount = 0, iTankTypes[MT_MAXTYPES + 1];
				for (int iIndex = g_esGeneral.g_iMinType; iIndex <= g_esGeneral.g_iMaxType; iIndex++)
				{
					if (iIndex <= 0)
					{
						continue;
					}

					vGetTranslatedName(sPhrase, sizeof sPhrase, .type = iIndex);
					SetGlobalTransTarget(admin);
					FormatEx(sTankName, sizeof sTankName, "%T", sPhrase, admin);
					if (!bIsTankEnabled(iIndex) || !bHasCoreAdminAccess(admin, iIndex) || g_esTank[iIndex].g_iMenuEnabled == 0 || !bIsTypeAvailable(iIndex, admin) || bAreHumansRequired(iIndex) || !bCanTypeSpawn(iIndex) || !bIsRightGame(iIndex) || bIsAreaNarrow(admin, g_esTank[iIndex].g_flOpenAreasOnly) || (!StrEqual(type, "random", false) && StrContains(sTankName, type, false) == -1))
					{
						continue;
					}

					g_esGeneral.g_iChosenType = iIndex;
					iTankTypes[iTypeCount + 1] = iIndex;
					iTypeCount++;
				}

				switch (iTypeCount)
				{
					case 0:
					{
						MT_PrintToChat(admin, "%s %t", MT_TAG3, "RequestFailed");

						return;
					}
					case 1: MT_PrintToChat(admin, "%s %t", MT_TAG3, "RequestSucceeded", g_esGeneral.g_iChosenType);
					default:
					{
						g_esGeneral.g_iChosenType = iTankTypes[GetRandomInt(1, iTypeCount)];

						MT_PrintToChat(admin, "%s %t", MT_TAG3, "MultipleMatches", g_esGeneral.g_iChosenType);
					}
				}
			}
		}
		default: g_esGeneral.g_iChosenType = iClamp(iType, 1, MT_MAXTYPES);
	}

	switch (bIsTank(admin))
	{
		case true:
		{
			switch (bIsTank(admin, MT_CHECK_FAKECLIENT))
			{
				case true:
				{
					switch (spawn)
					{
						case true: vSpawnTank(admin, log, amount, mode);
						case false:
						{
							if ((GetClientButtons(admin) & IN_SPEED) && (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT, true) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT, true) || bIsDeveloper(admin, .real = true)))
							{
								vChangeTank(admin, amount, mode);
							}
							else
							{
								int iTime = GetTime();

								switch (g_esPlayer[admin].g_iCooldown > iTime)
								{
									case true: MT_PrintToChat(admin, "%s %t", MT_TAG3, "HumanCooldown", (g_esPlayer[admin].g_iCooldown - iTime));
									case false:
									{
										g_esPlayer[admin].g_iCooldown = -1;

										vSetTankColor(admin, g_esGeneral.g_iChosenType);

										switch (g_esPlayer[admin].g_bNeedHealth)
										{
											case true:
											{
												g_esPlayer[admin].g_bNeedHealth = false;

												vTankSpawn(admin);
											}
											case false: vTankSpawn(admin, 5);
										}

										vExternalView(admin, 1.5);

										if (g_esGeneral.g_iMasterControl == 0 && (!CheckCommandAccess(admin, "mt_adminversus", ADMFLAG_ROOT) && !bIsDeveloper(admin, 0)))
										{
											g_esPlayer[admin].g_iCooldown = (iTime + g_esGeneral.g_iHumanCooldown);
										}
									}
								}

								g_esGeneral.g_iChosenType = 0;
							}
						}
					}
				}
				case false: vSpawnTank(admin, false, amount, mode);
			}
		}
		case false:
		{
			switch (CheckCommandAccess(admin, "sm_tank", ADMFLAG_ROOT, true) || CheckCommandAccess(admin, "sm_mt_tank", ADMFLAG_ROOT, true) || bIsDeveloper(admin, .real = true))
			{
				case true: vChangeTank(admin, amount, mode);
				case false: MT_PrintToChat(admin, "%s %t", MT_TAG2, "NoCommandAccess");
			}
		}
	}
}

void vTankSpawn(int tank, int mode = 0)
{
	DataPack dpTankSpawn = new DataPack();
	RequestFrame(vTankSpawnFrame, dpTankSpawn);
	dpTankSpawn.WriteCell(GetClientUserId(tank));
	dpTankSpawn.WriteCell(mode);
}

void vThrowInterval(int tank)
{
	if (bIsTank(tank) && g_esCache[tank].g_flThrowInterval > 0.0)
	{
		int iAbility = GetEntPropEnt(tank, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", g_esCache[tank].g_flThrowInterval);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", (GetGameTime() + g_esCache[tank].g_flThrowInterval));
		}
	}
}

void vTriggerTank(int tank)
{
	if (bIsTankIdle(tank, 1) && g_esGeneral.g_iCurrentMode == 1 && g_esGeneral.g_iAggressiveTanks == 1 && !g_esPlayer[tank].g_bTriggered)
	{
		g_esPlayer[tank].g_bTriggered = true;

		int iHealth = GetEntProp(tank, Prop_Data, "m_iHealth");
		vDamagePlayer(tank, iGetRandomSurvivor(tank), 1.0);
		SetEntProp(tank, Prop_Data, "m_iHealth", iHealth);
	}
}