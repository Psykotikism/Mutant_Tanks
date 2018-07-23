// Super Tanks++: Ghost Ability
bool g_bGhost[MAXPLAYERS + 1];
char g_sGhostSlot[ST_MAXTYPES + 1][6];
char g_sGhostSlot2[ST_MAXTYPES + 1][6];
float g_flGhostRange[ST_MAXTYPES + 1];
float g_flGhostRange2[ST_MAXTYPES + 1];
int g_iGhostAbility[ST_MAXTYPES + 1];
int g_iGhostAbility2[ST_MAXTYPES + 1];
int g_iGhostAlpha[MAXPLAYERS + 1];
int g_iGhostChance[ST_MAXTYPES + 1];
int g_iGhostChance2[ST_MAXTYPES + 1];
int g_iGhostFade[ST_MAXTYPES + 1];
int g_iGhostFade2[ST_MAXTYPES + 1];
int g_iGhostHit[ST_MAXTYPES + 1];
int g_iGhostHit2[ST_MAXTYPES + 1];

void vGhostConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iGhostAbility[index] = keyvalues.GetNum("Ghost Ability/Ability Enabled", 0)) : (g_iGhostAbility2[index] = keyvalues.GetNum("Ghost Ability/Ability Enabled", g_iGhostAbility[index]));
	main ? (g_iGhostAbility[index] = iSetCellLimit(g_iGhostAbility[index], 0, 1)) : (g_iGhostAbility2[index] = iSetCellLimit(g_iGhostAbility2[index], 0, 1));
	main ? (g_iGhostChance[index] = keyvalues.GetNum("Ghost Ability/Ghost Chance", 4)) : (g_iGhostChance2[index] = keyvalues.GetNum("Ghost Ability/Ghost Chance", g_iGhostChance[index]));
	main ? (g_iGhostChance[index] = iSetCellLimit(g_iGhostChance[index], 1, 9999999999)) : (g_iGhostChance2[index] = iSetCellLimit(g_iGhostChance2[index], 1, 9999999999));
	main ? (g_iGhostFade[index] = keyvalues.GetNum("Ghost Ability/Ghost Fade Limit", 255)) : (g_iGhostFade2[index] = keyvalues.GetNum("Ghost Ability/Ghost Fade Limit", g_iGhostFade[index]));
	main ? (g_iGhostFade[index] = iSetCellLimit(g_iGhostFade[index], 0, 255)) : (g_iGhostFade2[index] = iSetCellLimit(g_iGhostFade2[index], 0, 255));
	main ? (g_iGhostHit[index] = keyvalues.GetNum("Ghost Ability/Ghost Hit", 0)) : (g_iGhostHit2[index] = keyvalues.GetNum("Ghost Ability/Ghost Hit", g_iGhostHit[index]));
	main ? (g_iGhostHit[index] = iSetCellLimit(g_iGhostHit[index], 0, 1)) : (g_iGhostHit2[index] = iSetCellLimit(g_iGhostHit2[index], 0, 1));
	main ? (g_flGhostRange[index] = keyvalues.GetFloat("Ghost Ability/Ghost Range", 150.0)) : (g_flGhostRange2[index] = keyvalues.GetFloat("Ghost Ability/Ghost Range", g_flGhostRange[index]));
	main ? (g_flGhostRange[index] = flSetFloatLimit(g_flGhostRange[index], 1.0, 9999999999.0)) : (g_flGhostRange2[index] = flSetFloatLimit(g_flGhostRange2[index], 1.0, 9999999999.0));
	main ? (keyvalues.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostSlot[index], sizeof(g_sGhostSlot[]), "12345")) : (keyvalues.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostSlot2[index], sizeof(g_sGhostSlot2[]), g_sGhostSlot[index]));
}

void vGhostAbility(int client)
{
	char sSet[2][16];
	char sTankColors[28];
	sTankColors = !g_bTankConfig[g_iTankType[client]] ? g_sTankColors[g_iTankType[client]] : g_sTankColors2[g_iTankType[client]];
	TrimString(sTankColors);
	ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	char sRGB[4][4];
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	char sSet2[5][16];
	char sPropsColors[80];
	sPropsColors = !g_bTankConfig[g_iTankType[client]] ? g_sPropsColors[g_iTankType[client]] : g_sPropsColors2[g_iTankType[client]];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet2, sizeof(sSet2), sizeof(sSet2[]));
	char sProps[4][4];
	ExplodeString(sSet2[0], ",", sProps, sizeof(sProps), sizeof(sProps[]));
	TrimString(sProps[0]);
	int iRed2 = (sProps[0][0] != '\0') ? StringToInt(sProps[0]) : 255;
	TrimString(sProps[1]);
	int iGreen2 = (sProps[1][0] != '\0') ? StringToInt(sProps[1]) : 255;
	TrimString(sProps[2]);
	int iBlue2 = (sProps[2][0] != '\0') ? StringToInt(sProps[2]) : 255;
	char sProps2[4][4];
	ExplodeString(sSet2[1], ",", sProps2, sizeof(sProps2), sizeof(sProps2[]));
	TrimString(sProps2[0]);
	int iRed3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[0]) : 255;
	TrimString(sProps2[1]);
	int iGreen3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[1]) : 255;
	TrimString(sProps2[2]);
	int iBlue3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[2]) : 255;
	char sProps3[4][4];
	ExplodeString(sSet2[2], ",", sProps3, sizeof(sProps3), sizeof(sProps3[]));
	TrimString(sProps3[0]);
	int iRed4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[0]) : 255;
	TrimString(sProps3[1]);
	int iGreen4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[1]) : 255;
	TrimString(sProps3[2]);
	int iBlue4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[2]) : 255;
	char sProps4[4][4];
	ExplodeString(sSet2[3], ",", sProps4, sizeof(sProps4), sizeof(sProps4[]));
	TrimString(sProps4[0]);
	int iRed5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[0]) : 255;
	TrimString(sProps4[1]);
	int iGreen5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[1]) : 255;
	TrimString(sProps4[2]);
	int iBlue5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[2]) : 255;
	char sProps5[4][4];
	ExplodeString(sSet2[4], ",", sProps5, sizeof(sProps5), sizeof(sProps5[]));
	TrimString(sProps5[0]);
	int iRed6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[0]) : 255;
	TrimString(sProps5[1]);
	int iGreen6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[1]) : 255;
	TrimString(sProps5[2]);
	int iBlue6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[2]) : 255;
	int iGhostAbility = !g_bTankConfig[g_iTankType[client]] ? g_iGhostAbility[g_iTankType[client]] : g_iGhostAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iGhostAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
		{
			if (bIsSpecialInfected(iInfected))
			{
				float flTankPos[3];
				float flInfectedPos[3];
				GetClientAbsOrigin(client, flTankPos);
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flGhostRange = !g_bTankConfig[g_iTankType[client]] ? g_flGhostRange[g_iTankType[client]] : g_flGhostRange2[g_iTankType[client]];
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance <= flGhostRange)
				{
					SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iInfected, 255, 255, 255, 50);
				}
				else
				{
					SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iInfected, 255, 255, 255, 255);
				}
			}
		}
		if (!g_bGhost[client])
		{
			g_iGhostAlpha[client] = 255;
			g_bGhost[client] = true;
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerGhost, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack.WriteCell(GetClientUserId(client));
			dpDataPack.WriteCell(iRed);
			dpDataPack.WriteCell(iGreen);
			dpDataPack.WriteCell(iBlue);
			dpDataPack.WriteCell(iRed2);
			dpDataPack.WriteCell(iGreen2);
			dpDataPack.WriteCell(iBlue2);
			dpDataPack.WriteCell(iRed3);
			dpDataPack.WriteCell(iGreen3);
			dpDataPack.WriteCell(iBlue3);
			dpDataPack.WriteCell(iRed4);
			dpDataPack.WriteCell(iGreen4);
			dpDataPack.WriteCell(iBlue4);
			dpDataPack.WriteCell(iRed5);
			dpDataPack.WriteCell(iGreen5);
			dpDataPack.WriteCell(iBlue5);
			dpDataPack.WriteCell(iRed6);
			dpDataPack.WriteCell(iGreen6);
			dpDataPack.WriteCell(iBlue6);
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		}
	}
}

void vGhostDrop(int client, char[] slots, char[] number, int slot)
{
	if (StrContains(slots, number) != -1)
	{
		vDropWeapon(client, slot);
	}
}

void vDropWeapon(int client, int slot)
{
	if (bIsSurvivor(client) && GetPlayerWeaponSlot(client, slot) > 0)
	{
		SDKHooks_DropWeapon(client, GetPlayerWeaponSlot(client, slot), NULL_VECTOR, NULL_VECTOR);
	}
}

void vGhostHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iGhostAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iGhostAbility[g_iTankType[owner]] : g_iGhostAbility2[g_iTankType[owner]];
	int iGhostChance = !g_bTankConfig[g_iTankType[owner]] ? g_iGhostChance[g_iTankType[owner]] : g_iGhostChance2[g_iTankType[owner]];
	int iGhostHit = !g_bTankConfig[g_iTankType[owner]] ? g_iGhostHit[g_iTankType[owner]] : g_iGhostHit2[g_iTankType[owner]];
	float flGhostRange = !g_bTankConfig[g_iTankType[owner]] ? g_flGhostRange[g_iTankType[owner]] : g_flGhostRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flGhostRange) || toggle == 2) && ((toggle == 1 && iGhostAbility == 1) || (toggle == 2 && iGhostHit == 1)) && GetRandomInt(1, iGhostChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		char sGhostSlot[6];
		sGhostSlot = !g_bTankConfig[g_iTankType[owner]] ? g_sGhostSlot[g_iTankType[owner]] : g_sGhostSlot2[g_iTankType[owner]];
		vGhostDrop(client, sGhostSlot, "1", 0);
		vGhostDrop(client, sGhostSlot, "2", 1);
		vGhostDrop(client, sGhostSlot, "3", 2);
		vGhostDrop(client, sGhostSlot, "4", 3);
		vGhostDrop(client, sGhostSlot, "5", 4);
		EmitSoundToClient(client, SOUND_INFECTED, owner);
	}
}

void vResetGhost(int client)
{
	g_bGhost[client] = false;
	g_iGhostAlpha[client] = 255;
}

public Action tTimerGhost(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRed = pack.ReadCell();
	int iGreen = pack.ReadCell();
	int iBlue = pack.ReadCell();
	int iRed2 = pack.ReadCell();
	int iGreen2 = pack.ReadCell();
	int iBlue2 = pack.ReadCell();
	int iRed3 = pack.ReadCell();
	int iGreen3 = pack.ReadCell();
	int iBlue3 = pack.ReadCell();
	int iRed4 = pack.ReadCell();
	int iGreen4 = pack.ReadCell();
	int iBlue4 = pack.ReadCell();
	int iRed5 = pack.ReadCell();
	int iGreen5 = pack.ReadCell();
	int iBlue5 = pack.ReadCell();
	int iRed6 = pack.ReadCell();
	int iGreen6 = pack.ReadCell();
	int iBlue6 = pack.ReadCell();
	int iGhostAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iGhostAbility[g_iTankType[iTank]] : g_iGhostAbility2[g_iTankType[iTank]];
	if (iGhostAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bGhost[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		g_iGhostAlpha[iTank] -= 2;
		int iGhostFade = !g_bTankConfig[g_iTankType[iTank]] ? g_iGhostFade[g_iTankType[iTank]] : g_iGhostFade2[g_iTankType[iTank]];
		if (g_iGhostAlpha[iTank] < iGhostFade)
		{
			g_iGhostAlpha[iTank] = iGhostFade;
		}
		int iProp = -1;
		while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			char sModel[128];
			GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
			if (strcmp(sModel, MODEL_JETPACK, false) == 0 || strcmp(sModel, MODEL_CONCRETE, false) == 0 || strcmp(sModel, MODEL_TIRES, false) == 0 || strcmp(sModel, MODEL_TANK, false) == 0)
			{
				int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
				if (iOwner == iTank)
				{
					if (strcmp(sModel, MODEL_JETPACK, false) == 0)
					{
						SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
						SetEntityRenderColor(iProp, iRed3, iGreen3, iBlue3, g_iGhostAlpha[iTank]);
					}
					if (strcmp(sModel, MODEL_CONCRETE, false) == 0)
					{
						SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
						SetEntityRenderColor(iProp, iRed5, iGreen5, iBlue5, g_iGhostAlpha[iTank]);
					}
					if (strcmp(sModel, MODEL_TIRES, false) == 0)
					{
						SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
						SetEntityRenderColor(iProp, iRed6, iGreen6, iBlue6, g_iGhostAlpha[iTank]);
					}
					if (strcmp(sModel, MODEL_TANK, false) == 0)
					{
						SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
						SetEntityRenderColor(iProp, iRed, iGreen, iBlue, g_iGhostAlpha[iTank]);
					}
				}
			}
		}
		while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iProp, iRed2, iGreen2, iBlue2, g_iGhostAlpha[iTank]);
			}
		}
		while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iProp, iRed4, iGreen4, iBlue4, g_iGhostAlpha[iTank]);
			}
		}
		SetEntityRenderMode(iTank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iTank, iRed, iGreen, iBlue, g_iGhostAlpha[iTank]);
	}
	return Plugin_Continue;
}