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

void vReadGameData()
{
	GameData gdMutantTanks = new GameData("mutant_tanks");

	switch (gdMutantTanks == null)
	{
		case true: SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");
		case false:
		{
			g_esGeneral.g_bLinux = gdMutantTanks.GetOffset("OS") == 1;

			if (g_bSecondGame)
			{
				StartPrepSDKCall(SDKCall_Entity);
				if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CBaseBackpackItem::GetUseAction"))
				{
					LogError("%s Failed to load offset: CBaseBackpackItem::GetUseAction", MT_TAG);
				}

				PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
				g_esGeneral.g_hSDKGetUseAction = EndPrepSDKCall();
				if (g_esGeneral.g_hSDKGetUseAction == null)
				{
					LogError("%s Your \"CBaseBackpackItem::GetUseAction\" offsets are outdated.", MT_TAG);
				}

				StartPrepSDKCall(SDKCall_Player);
				if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CBaseEntity::IsInStasis"))
				{
					LogError("%s Failed to load offset: CBaseEntity::IsInStasis", MT_TAG);
				}

				PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
				g_esGeneral.g_hSDKIsInStasis = EndPrepSDKCall();
				if (g_esGeneral.g_hSDKIsInStasis == null)
				{
					LogError("%s Your \"CBaseEntity::IsInStasis\" offsets are outdated.", MT_TAG);
				}

				StartPrepSDKCall(SDKCall_Raw);
				if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CDirector::IsFirstMapInScenario"))
				{
					LogError("%s Failed to find signature: CDirector::IsFirstMapInScenario", MT_TAG);
				}

				PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
				g_esGeneral.g_hSDKIsFirstMapInScenario = EndPrepSDKCall();
				if (g_esGeneral.g_hSDKIsFirstMapInScenario == null)
				{
					LogError("%s Your \"CDirector::IsFirstMapInScenario\" signature is outdated.", MT_TAG);
				}

				g_esGeneral.g_iMeleeOffset = iGetGameDataOffset(gdMutantTanks, "CTerrorPlayer::OnIncapacitatedAsSurvivor::HiddenMeleeWeapon");
			}

			g_esGeneral.g_adDirector = gdMutantTanks.GetAddress("CDirector");
			if (g_esGeneral.g_adDirector == Address_Null)
			{
				LogError("%s Failed to find address: CDirector", MT_TAG);
			}

			g_esGeneral.g_adDoJumpValue = adGetGameDataAddress(gdMutantTanks, "DoJumpValueBytes", "DoJumpValueRead", "GetMaxJumpHeightStart", "PlayerLocomotion::GetMaxJumpHeight::Call", "PlayerLocomotion::GetMaxJumpHeight::Add", "PlayerLocomotion::GetMaxJumpHeight::Value");

			StartPrepSDKCall(SDKCall_Raw);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CBaseEntity::GetRefEHandle"))
			{
				LogError("%s Failed to find signature: CBaseEntity::GetRefEHandle", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKGetRefEHandle = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetRefEHandle == null)
			{
				LogError("%s Your \"CBaseEntity::GetRefEHandle\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Raw);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CDirector::HasAnySurvivorLeftSafeArea"))
			{
				LogError("%s Failed to find signature: CDirector::HasAnySurvivorLeftSafeArea", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
			g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKHasAnySurvivorLeftSafeArea == null)
			{
				LogError("%s Your \"CDirector::HasAnySurvivorLeftSafeArea\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Entity);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTankRock::Detonate"))
			{
				LogError("%s Failed to find signature: CTankRock::Detonate", MT_TAG);
			}

			g_esGeneral.g_hSDKRockDetonate = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKRockDetonate == null)
			{
				LogError("%s Your \"CTankRock::Detonate\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Static);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorGameRules::GetMissionFirstMap"))
			{
				LogError("%s Failed to find signature: CTerrorGameRules::GetMissionFirstMap", MT_TAG);
			}

			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain, VDECODE_FLAG_ALLOWWORLD);
			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKGetMissionFirstMap = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetMissionFirstMap == null)
			{
				LogError("%s Your \"CTerrorGameRules::GetMissionFirstMap\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_GameRules);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorGameRules::GetMissionInfo"))
			{
				LogError("%s Failed to find signature: CTerrorGameRules::GetMissionInfo", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKGetMissionInfo = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetMissionInfo == null)
			{
				LogError("%s Your \"CTerrorGameRules::GetMissionInfo\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_GameRules);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorGameRules::IsMissionFinalMap"))
			{
				LogError("%s Failed to find signature: CTerrorGameRules::IsMissionFinalMap", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
			g_esGeneral.g_hSDKIsMissionFinalMap = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKIsMissionFinalMap == null)
			{
				LogError("%s Your \"CTerrorGameRules::IsMissionFinalMap\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::MaterializeFromGhost"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::MaterializeFromGhost", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKMaterializeGhost = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKMaterializeGhost == null)
			{
				LogError("%s Your \"CTerrorPlayer::MaterializeFromGhost\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnITExpired"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnITExpired", MT_TAG);
			}

			g_esGeneral.g_hSDKITExpired = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKITExpired == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnITExpired\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnRevived"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnRevived", MT_TAG);
			}

			g_esGeneral.g_hSDKRevive = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKRevive == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnRevived\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnShovedBySurvivor"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnShovedBySurvivor", MT_TAG);
			}

			PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			g_esGeneral.g_hSDKShovedBySurvivor = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKShovedBySurvivor == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnShovedBySurvivor\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::OnVomitedUpon"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::OnVomitedUpon", MT_TAG);
			}

			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
			if (!g_bSecondGame)
			{
				PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
			}

			g_esGeneral.g_hSDKVomitedUpon = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKVomitedUpon == null)
			{
				LogError("%s Your \"CTerrorPlayer::OnVomitedUpon\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "CTerrorPlayer::RoundRespawn"))
			{
				LogError("%s Failed to find signature: CTerrorPlayer::RoundRespawn", MT_TAG);
			}

			g_esGeneral.g_hSDKRoundRespawn = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKRoundRespawn == null)
			{
				LogError("%s Your \"CTerrorPlayer::RoundRespawn\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Raw);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "KeyValues::GetString"))
			{
				LogError("%s Failed to find signature: KeyValues::GetString", MT_TAG);
			}

			PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
			PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Pointer);
			g_esGeneral.g_hSDKKeyValuesGetString = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKKeyValuesGetString == null)
			{
				LogError("%s Your \"KeyValues::GetString\" signature is outdated.", MT_TAG);
			}

			StartPrepSDKCall(SDKCall_Player);
			if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Signature, "Tank::LeaveStasis"))
			{
				LogError("%s Failed to find signature: Tank::LeaveStasis", MT_TAG);
			}

			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
			g_esGeneral.g_hSDKLeaveStasis = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKLeaveStasis == null)
			{
				LogError("%s Your \"Tank::LeaveStasis\" signature is outdated.", MT_TAG);
			}

			g_esGeneral.g_iEventKilledAttackerOffset = iGetGameDataOffset(gdMutantTanks, "CTerrorPlayer::Event_Killed::Attacker");
			g_esGeneral.g_iIntentionOffset = iGetGameDataOffset(gdMutantTanks, "Tank::GetIntentionInterface");
			g_esGeneral.g_iBehaviorOffset = iGetGameDataOffset(gdMutantTanks, "TankIntention::FirstContainedResponder");
			g_esGeneral.g_iActionOffset = iGetGameDataOffset(gdMutantTanks, "Behavior<Tank>::FirstContainedResponder");
			g_esGeneral.g_iChildActionOffset = iGetGameDataOffset(gdMutantTanks, "Action<Tank>::FirstContainedResponder");

			int iOffset = iGetGameDataOffset(gdMutantTanks, "CBaseCombatWeapon::GetMaxClip1");
			StartPrepSDKCall(SDKCall_Entity);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_ByValue);
			g_esGeneral.g_hSDKGetMaxClip1 = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetMaxClip1 == null)
			{
				LogError("%s Your \"CBaseCombatWeapon::GetMaxClip1\" offsets are outdated.", MT_TAG);
			}

			iOffset = iGetGameDataOffset(gdMutantTanks, "TankIdle::GetName");
			StartPrepSDKCall(SDKCall_Raw);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Plain);
			g_esGeneral.g_hSDKGetName = EndPrepSDKCall();
			if (g_esGeneral.g_hSDKGetName == null)
			{
				LogError("%s Your \"TankIdle::GetName\" offsets are outdated.", MT_TAG);
			}

			delete gdMutantTanks;
		}
	}
}

Address adGetGameDataAddress(GameData dataHandle, const char[] name, const char[] backup, const char[] start, const char[] offset1, const char[] offset2, const char[] offset3)
{
	Address adResult = dataHandle.GetAddress(name);
	if (adResult == Address_Null)
	{
		LogError("%s Failed to find address from \"%s\". Retrieving from \"%s\" instead.", MT_TAG, name, backup);

		if (g_bSecondGame || !g_esGeneral.g_bLinux)
		{
			adResult = dataHandle.GetAddress(backup);
			if (adResult == Address_Null)
			{
				LogError("%s Failed to find address from \"%s\". Failed to retrieve address from both methods.", MT_TAG, backup);
			}
		}
		else
		{
			Address adValue[4] = {Address_Null, Address_Null, Address_Null, Address_Null};
			adValue[0] = dataHandle.GetAddress(start);

			int iOffset[3] = {-1, -1, -1};
			iOffset[0] = dataHandle.GetOffset(offset1);
			iOffset[1] = dataHandle.GetOffset(offset2);
			iOffset[2] = dataHandle.GetOffset(offset3);

			if (adValue[0] == Address_Null || iOffset[0] == -1 || iOffset[1] == -1 || iOffset[2] == -1)
			{
				LogError("%s Failed to find address from \"%s\". Failed to retrieve address from both methods.", MT_TAG, backup);
			}
			else
			{
				adValue[1] = adValue[0] + view_as<Address>(iOffset[0]);
				adValue[2] = LoadFromAddress((adValue[0] + view_as<Address>(iOffset[1])), NumberType_Int32);
				adValue[3] = LoadFromAddress((adValue[0] + view_as<Address>(iOffset[2])), NumberType_Int32);
				adResult = (adValue[1] + adValue[2] + adValue[3]);
			}
		}
	}

	return adResult;
}

int iGetGameDataOffset(GameData dataHandle, const char[] name)
{
	int iOffset = dataHandle.GetOffset(name);
	if (iOffset == -1)
	{
		LogError("%s Failed to load offset: %s", MT_TAG, name);
	}

	return iOffset;
}