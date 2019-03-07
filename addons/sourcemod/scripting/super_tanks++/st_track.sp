/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Track Ability",
	author = ST_AUTHOR,
	description = "The Super Tank throws heat-seeking rocks that will track down the nearest survivors.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Track Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_TRACK "Track Ability"

bool g_bCloneInstalled, g_bTrack[MAXPLAYERS + 1], g_bTrack2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flTrackChance[ST_MAXTYPES + 1], g_flTrackSpeed[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iTrackAbility[ST_MAXTYPES + 1], g_iTrackCount[MAXPLAYERS + 1], g_iTrackMessage[ST_MAXTYPES + 1], g_iTrackMode[ST_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_track", cmdTrackInfo, "View information about the Track ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveTrack(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdTrackInfo(int client, int args)
{
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
		case false: vTrackMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vTrackMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iTrackMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Track Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iTrackMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iTrackAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iTrackCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "TrackDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vTrackMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "TrackMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];
			switch (param2)
			{
				case 0:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_TRACK, ST_MENU_TRACK);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_TRACK, false))
	{
		vTrackMenu(client, 0);
	}
}

public void Think(int rock)
{
	switch (bIsValidEntity(rock))
	{
		case true: vTrack(rock);
		case false: SDKUnhook(rock, SDKHook_Think, Think);
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iTrackAbility[iIndex] = 0;
		g_iTrackMessage[iIndex] = 0;
		g_flTrackChance[iIndex] = 33.3;
		g_iTrackMode[iIndex] = 1;
		g_flTrackSpeed[iIndex] = 500.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 61, bHasAbilities(subsection, "trackability", "track ability", "track_ability", "track"));
	g_iHumanAbility[type] = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iTrackAbility[type] = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iTrackAbility[type], value, 0, 0, 1);
	g_iTrackMessage[type] = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iTrackMessage[type], value, 0, 0, 1);
	g_flTrackChance[type] = flGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "TrackChance", "Track Chance", "Track_Chance", "chance", main, g_flTrackChance[type], value, 33.3, 0.0, 100.0);
	g_iTrackMode[type] = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "TrackMode", "Track Mode", "Track_Mode", "mode", main, g_iTrackMode[type], value, 1, 0, 1);
	g_flTrackSpeed[type] = flGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "TrackSpeed", "Track Speed", "Track_Speed", "speed", main, g_flTrackSpeed[type], value, 500.0, 0.1, 9999999999.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveTrack(iTank);
		}
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (g_iTrackAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bTrack[tank] && !g_bTrack2[tank])
				{
					if (g_iTrackCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						g_bTrack[tank] = true;
						g_iTrackCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "TrackHuman", g_iTrackCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
					}
					else
					{
						ST_PrintToChat(tank, "%s %t", ST_TAG3, "TrackAmmo");
					}
				}
				else if (g_bTrack[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "TrackHuman2");
				}
				else if (g_bTrack2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "TrackHuman3");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveTrack(tank);
}

public void ST_OnRockThrow(int tank, int rock)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iTrackAbility[ST_GetTankType(tank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flTrackChance[ST_GetTankType(tank)])
	{
		if ((!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && !g_bTrack[tank])
		{
			g_bTrack[tank] = true;
		}

		DataPack dpTrack;
		CreateDataTimer(0.5, tTimerTrack, dpTrack, TIMER_FLAG_NO_MAPCHANGE);
		dpTrack.WriteCell(EntIndexToEntRef(rock));
		dpTrack.WriteCell(GetClientUserId(tank));
		dpTrack.WriteCell(ST_GetTankType(tank));

		if (g_iTrackMessage[ST_GetTankType(tank)] == 1)
		{
			char sTankName[33];
			ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Track", sTankName);
		}
	}
}

static void vRemoveTrack(int tank)
{
	g_bTrack[tank] = false;
	g_bTrack2[tank] = false;
	g_iTrackCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveTrack(iPlayer);
		}
	}
}

static void vTrack(int rock)
{
	int iTank = GetEntPropEnt(rock, Prop_Data, "m_hThrower");
	switch (g_iTrackMode[ST_GetTankType(iTank)])
	{
		case 0:
		{
			float flPos[3], flVelocity[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(rock, Prop_Data, "m_vecVelocity", flVelocity);

			float flVector = GetVectorLength(flVelocity);
			if (flVector < 100.0)
			{
				return;
			}

			NormalizeVector(flVelocity, flVelocity);

			int iTarget = iGetRandomTarget(flPos, flVelocity);
			if (iTarget > 0)
			{
				float flPos2[3], flVelocity2[3];
				GetClientEyePosition(iTarget, flPos2);
				GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);

				bool bVisible = bVisiblePosition(flPos, flPos2, rock, 2);
				float flDistance = GetVectorDistance(flPos, flPos2);

				if (!bVisible || flDistance > 500.0)
				{
					return;
				}

				SetEntityGravity(rock, 0.01);

				float flDirection[3], flVelocity3[3];
				SubtractVectors(flPos2, flPos, flDirection);
				NormalizeVector(flDirection, flDirection);

				ScaleVector(flDirection, 0.5);
				AddVectors(flVelocity, flDirection, flVelocity3);

				NormalizeVector(flVelocity3, flVelocity3);
				ScaleVector(flVelocity3, flVector);

				TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, flVelocity3);
			}
		}
		case 1:
		{
			float flPos[3], flVelocity[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(rock, Prop_Data, "m_vecVelocity", flVelocity);

			if (GetVectorLength(flVelocity) < 50.0)
			{
				return;
			}

			NormalizeVector(flVelocity, flVelocity);

			int iTarget = iGetRandomTarget(flPos, flVelocity);
			float flVelocity2[3], flVector[3], flAngles[3], flDistance = 1000.0;
			bool bVisible;

			flVector[0] = flVector[1] = flVector[2] = 0.0;

			if (iTarget > 0)
			{
				float flPos2[3];
				GetClientEyePosition(iTarget, flPos2);
				flDistance = GetVectorDistance(flPos, flPos2);
				bVisible = bVisiblePosition(flPos, flPos2, rock, 1);

				GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);
				AddVectors(flPos2, flVelocity2, flPos2);
				MakeVectorFromPoints(flPos, flPos2, flVector);
			}

			GetVectorAngles(flVelocity, flAngles);

			float flLeft[3], flRight[3], flUp[3], flDown[3], flFront[3], flVector1[3], flVector2[3], flVector3[3], flVector4[3],
				flVector5[3], flVector6[3], flVector7[3], flVector8[3], flVector9, flFactor1 = 0.2, flFactor2 = 0.5, flBase = 1500.0;

			flFront[0] = flFront[1] = flFront[2] = 0.0;

			if (bVisible)
			{
				flBase = 80.0;

				float flFront2 = flGetDistance(flPos, flAngles, 0.0, 0.0, flFront, rock, 3),
					flDown2 = flGetDistance(flPos, flAngles, 90.0, 0.0, flDown, rock, 3),
					flUp2 = flGetDistance(flPos, flAngles, -90.0, 0.0, flUp, rock, 3),
					flLeft2 = flGetDistance(flPos, flAngles, 0.0, 90.0, flLeft, rock, 3),
					flRight2 = flGetDistance(flPos, flAngles, 0.0, -90.0, flRight, rock, 3),
					flDistance2 = flGetDistance(flPos, flAngles, 30.0, 0.0, flVector1, rock, 3),
					flDistance3 = flGetDistance(flPos, flAngles, 30.0, 45.0, flVector2, rock, 3),
					flDistance4 = flGetDistance(flPos, flAngles, 0.0, 45.0, flVector3, rock, 3),
					flDistance5 = flGetDistance(flPos, flAngles, -30.0, 45.0, flVector4, rock, 3),
					flDistance6 = flGetDistance(flPos, flAngles, -30.0, 0.0, flVector5, rock, 3),
					flDistance7 = flGetDistance(flPos, flAngles, -30.0, -45.0, flVector6, rock, 3),
					flDistance8 = flGetDistance(flPos, flAngles, 0.0, -45.0, flVector7, rock, 3),
					flDistance9 = flGetDistance(flPos, flAngles, 30.0, -45.0, flVector8, rock, 3);

				NormalizeVector(flFront, flFront);
				NormalizeVector(flUp, flUp);
				NormalizeVector(flDown, flDown);
				NormalizeVector(flLeft, flLeft);
				NormalizeVector(flRight, flRight);
				NormalizeVector(flVector, flVector);
				NormalizeVector(flVector1, flVector1);
				NormalizeVector(flVector2, flVector2);
				NormalizeVector(flVector3, flVector3);
				NormalizeVector(flVector4, flVector4);
				NormalizeVector(flVector5, flVector5);
				NormalizeVector(flVector6, flVector6);
				NormalizeVector(flVector7, flVector7);
				NormalizeVector(flVector8, flVector8);

				if (flFront2 > flBase)
				{
					flFront2 = flBase;
				}

				if (flUp2 > flBase)
				{
					flUp2 = flBase;
				}

				if (flDown2 > flBase)
				{
					flDown2 = flBase;
				}

				if (flLeft2 > flBase)
				{
					flLeft2 = flBase;
				}

				if (flRight2 > flBase)
				{
					flRight2 = flBase;
				}

				if (flDistance2 > flBase)
				{
					flDistance2 = flBase;
				}

				if (flDistance3 > flBase)
				{
					flDistance3 = flBase;
				}

				if (flDistance4 > flBase)
				{
					flDistance4 = flBase;
				}

				if (flDistance5 > flBase)
				{
					flDistance5 = flBase;
				}

				if (flDistance6 > flBase)
				{
					flDistance6 = flBase;
				}

				if (flDistance7 > flBase)
				{
					flDistance7 = flBase;
				}

				if (flDistance8 > flBase)
				{
					flDistance8 = flBase;
				}

				if (flDistance9 > flBase)
				{
					flDistance9 = flBase;
				}

				flVector9 =- 1.0 * flFactor1 * (flBase - flFront2) / flBase;
				ScaleVector(flFront, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flUp2) / flBase;
				ScaleVector(flUp, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDown2) / flBase;
				ScaleVector(flDown, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flLeft2) / flBase;
				ScaleVector(flLeft, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flRight2) / flBase;
				ScaleVector(flRight, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance2) / flDistance2;
				ScaleVector(flVector1, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance3) / flDistance3;
				ScaleVector(flVector2, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance4) / flDistance4;
				ScaleVector(flVector3, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance5) / flDistance5;
				ScaleVector(flVector4, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance6) / flDistance6;
				ScaleVector(flVector5, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance7) / flDistance7;
				ScaleVector(flVector6, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance8) / flDistance8;
				ScaleVector(flVector7, flVector9);

				flVector9 =- 1.0 * flFactor1 * (flBase - flDistance9) / flDistance9;
				ScaleVector(flVector8, flVector9);

				if (flDistance >= 500.0)
				{
					flDistance = 500.0;
				}

				flVector9 = 1.0 * flFactor2 * (1000.0 - flDistance) / 500.0;
				ScaleVector(flVector, flVector9);

				AddVectors(flFront, flUp, flFront);
				AddVectors(flFront, flDown, flFront);
				AddVectors(flFront, flLeft, flFront);
				AddVectors(flFront, flRight, flFront);
				AddVectors(flFront, flVector1, flFront);
				AddVectors(flFront, flVector2, flFront);
				AddVectors(flFront, flVector3, flFront);
				AddVectors(flFront, flVector4, flFront);
				AddVectors(flFront, flVector5, flFront);
				AddVectors(flFront, flVector6, flFront);
				AddVectors(flFront, flVector7, flFront);
				AddVectors(flFront, flVector8, flFront);
				AddVectors(flFront, flVector, flFront);

				NormalizeVector(flFront, flFront);
			}

			float flAngles2 = flGetAngle(flFront, flVelocity), flVelocity3[3];
			ScaleVector(flFront, flAngles2);
			AddVectors(flVelocity, flFront, flVelocity3);
			NormalizeVector(flVelocity3, flVelocity3);

			ScaleVector(flVelocity3, g_flTrackSpeed[ST_GetTankType(iTank)]);

			SetEntityGravity(rock, 0.01);
			TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, flVelocity3);

			if (ST_IsGlowEnabled(iTank) && bIsValidGame())
			{
				int iGlowColor[4];
				ST_GetTankColors(iTank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
				SetEntProp(rock, Prop_Send, "m_iGlowType", 3);
				SetEntProp(rock, Prop_Send, "m_nGlowRange", 0);
				SetEntProp(rock, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]));
			}
		}
	}
}

public Action tTimerTrack(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || g_iTrackAbility[ST_GetTankType(iTank)] == 0 || !g_bTrack[iTank])
	{
		g_bTrack[iTank] = false;

		return Plugin_Stop;
	}

	SDKUnhook(iRock, SDKHook_Think, Think);
	SDKHook(iRock, SDKHook_Think, Think);

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && !g_bTrack2[iTank])
	{
		g_bTrack[iTank] = false;
		g_bTrack2[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "TrackHuman4");

		if (g_iTrackCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bTrack2[iTank] = false;
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bTrack2[iTank])
	{
		g_bTrack2[iTank] = false;

		return Plugin_Stop;
	}

	g_bTrack2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "TrackHuman5");

	return Plugin_Continue;
}