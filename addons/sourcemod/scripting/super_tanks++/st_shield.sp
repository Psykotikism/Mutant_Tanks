// Super Tanks++: Shield Ability
bool g_bShield[MAXPLAYERS + 1];
char g_sShieldColor[ST_MAXTYPES + 1][12];
char g_sShieldColor2[ST_MAXTYPES + 1][12];
float g_flShieldDelay[ST_MAXTYPES + 1];
float g_flShieldDelay2[ST_MAXTYPES + 1];
int g_iShieldAbility[ST_MAXTYPES + 1];
int g_iShieldAbility2[ST_MAXTYPES + 1];

void vShieldConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iShieldAbility[index] = keyvalues.GetNum("Shield Ability/Ability Enabled", 0)) : (g_iShieldAbility2[index] = keyvalues.GetNum("Shield Ability/Ability Enabled", g_iShieldAbility[index]));
	main ? (g_iShieldAbility[index] = iSetCellLimit(g_iShieldAbility[index], 0, 1)) : (g_iShieldAbility2[index] = iSetCellLimit(g_iShieldAbility2[index], 0, 1));
	main ? (keyvalues.GetString("Shield Ability/Shield Color", g_sShieldColor[index], sizeof(g_sShieldColor[]), "255,255,255")) : (keyvalues.GetString("Shield Ability/Shield Color", g_sShieldColor2[index], sizeof(g_sShieldColor2[]), g_sShieldColor[index]));
	main ? (g_flShieldDelay[index] = keyvalues.GetFloat("Shield Ability/Shield Delay", 5.0)) : (g_flShieldDelay2[index] = keyvalues.GetFloat("Shield Ability/Shield Delay", g_flShieldDelay[index]));
	main ? (g_flShieldDelay[index] = flSetFloatLimit(g_flShieldDelay[index], 1.0, 9999999999.0)) : (g_flShieldDelay2[index] = flSetFloatLimit(g_flShieldDelay2[index], 1.0, 9999999999.0));
}

void vShield(int client, int entity)
{
	int iShieldAbility = !g_bTankConfig[g_iTankType[client]] ? g_iShieldAbility[g_iTankType[client]] : g_iShieldAbility2[g_iTankType[client]];
	if (iShieldAbility == 1)
	{
		DataPack dpDataPack;
		CreateDataTimer(0.1, tTimerShieldThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(EntIndexToEntRef(entity));
	}
}

void vShieldAbility(int client, bool shield)
{
	int iShieldAbility = !g_bTankConfig[g_iTankType[client]] ? g_iShieldAbility[g_iTankType[client]] : g_iShieldAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iShieldAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		if (shield)
		{
			char sSet[3][4];
			char sShieldColor[12];
			sShieldColor = !g_bTankConfig[g_iTankType[client]] ? g_sShieldColor[g_iTankType[client]] : g_sShieldColor2[g_iTankType[client]];
			TrimString(sShieldColor);
			ExplodeString(sShieldColor, ",", sSet, sizeof(sSet), sizeof(sSet[]));
			TrimString(sSet[0]);
			int iRed = (sSet[0][0] != '\0') ? StringToInt(sSet[0]) : 255;
			TrimString(sSet[1]);
			int iGreen = (sSet[1][0] != '\0') ? StringToInt(sSet[1]) : 255;
			TrimString(sSet[2]);
			int iBlue = (sSet[2][0] != '\0') ? StringToInt(sSet[2]) : 255;
			float flOrigin[3];
			GetClientAbsOrigin(client, flOrigin);
			flOrigin[2] -= 120.0;
			int iShield = CreateEntityByName("prop_dynamic");
			if (bIsValidEntity(iShield))
			{
				SetEntityModel(iShield, MODEL_SHIELD);
				DispatchKeyValueVector(iShield, "origin", flOrigin);
				DispatchSpawn(iShield);
				vSetEntityParent(iShield, client);
				SetEntityRenderMode(iShield, RENDER_TRANSTEXTURE);
				SetEntityRenderColor(iShield, iRed, iGreen, iBlue, 50);
				SetEntProp(iShield, Prop_Send, "m_CollisionGroup", 1);
				SetEntPropEnt(iShield, Prop_Send, "m_hOwnerEntity", client);
				SDKHook(iShield, SDKHook_SetTransmit, ModelSetTransmit);
			}
			g_bShield[client] = true;
		}
		else
		{
			int iShield = -1;
			while ((iShield = FindEntityByClassname(iShield, "prop_dynamic")) != INVALID_ENT_REFERENCE)
			{
				char sModel[128];
				GetEntPropString(iShield, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
				if (strcmp(sModel, MODEL_SHIELD, false) == 0)
				{
					int iOwner = GetEntPropEnt(iShield, Prop_Send, "m_hOwnerEntity");
					if (iOwner == client)
					{
						SDKUnhook(iShield, SDKHook_SetTransmit, ModelSetTransmit);
						AcceptEntityInput(iShield, "Kill");
					}
				}
			}
			float flShieldDelay = !g_bTankConfig[g_iTankType[client]] ? g_flShieldDelay[g_iTankType[client]] : g_flShieldDelay2[g_iTankType[client]];
			CreateTimer(flShieldDelay, tTimerShield, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			g_bShield[client] = false;
		}
	}
}

void vResetShield(int client)
{
	g_bShield[client] = false;
}

public Action tTimerShield(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iShieldAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iShieldAbility[g_iTankType[iTank]] : g_iShieldAbility2[g_iTankType[iTank]];
	if (iShieldAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))) && !g_bShield[iTank])
	{
		vShieldAbility(iTank, true);
	}
	return Plugin_Continue;
}

public Action tTimerShieldThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	int iShieldAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iShieldAbility[g_iTankType[iTank]] : g_iShieldAbility2[g_iTankType[iTank]];
	if (iShieldAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || iRock == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flVelocity[3];
		if (bIsValidEntity(iRock))
		{
			GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector > 500.0)
			{
				int iPropane = CreateEntityByName("prop_physics");
				if (bIsValidEntity(iPropane))
				{
					SetEntityModel(iPropane, MODEL_PROPANETANK);
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					AcceptEntityInput(iRock, "Kill");
					NormalizeVector(flVelocity, flVelocity);
					float flSpeed = g_cvSTFindConVar[5].FloatValue;
					ScaleVector(flVelocity, flSpeed * 1.4);
					DispatchSpawn(iPropane);
					TeleportEntity(iPropane, flPos, NULL_VECTOR, flVelocity);
				}
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}