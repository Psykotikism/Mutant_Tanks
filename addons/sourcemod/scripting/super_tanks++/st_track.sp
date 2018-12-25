/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
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

#define ST_MENU_TRACK "Track Ability"

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1], g_bTrack[MAXPLAYERS + 1], g_bTrack2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flTrackChance[ST_MAXTYPES + 1], g_flTrackChance2[ST_MAXTYPES + 1], g_flTrackSpeed[ST_MAXTYPES + 1], g_flTrackSpeed2[ST_MAXTYPES + 1];

int g_iGlowEnabled[ST_MAXTYPES + 1], g_iGlowEnabled2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iTrackAbility[ST_MAXTYPES + 1], g_iTrackAbility2[ST_MAXTYPES + 1], g_iTrackCount[MAXPLAYERS + 1], g_iTrackMessage[ST_MAXTYPES + 1], g_iTrackMessage2[ST_MAXTYPES + 1], g_iTrackMode[ST_MAXTYPES + 1], g_iTrackMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Track Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

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
	if (!ST_PluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, "0245"))
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iTrackAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iTrackCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "TrackDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (bIsValidEntity(rock))
	{
		vTrack(rock);
	}
	else
	{
		SDKUnhook(rock, SDKHook_Think, Think);
	}
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			switch (main)
			{
				case true:
				{
					g_bTankConfig[iIndex] = false;

					g_iGlowEnabled[iIndex] = kvSuperTanks.GetNum("General/Glow Enabled", 1);
					g_iGlowEnabled[iIndex] = iClamp(g_iGlowEnabled[iIndex], 0, 1);

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Track Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Track Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Track Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iTrackAbility[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Enabled", 0);
					g_iTrackAbility[iIndex] = iClamp(g_iTrackAbility[iIndex], 0, 1);
					g_iTrackMessage[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Message", 0);
					g_iTrackMessage[iIndex] = iClamp(g_iTrackMessage[iIndex], 0, 1);
					g_flTrackChance[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Chance", 33.3);
					g_flTrackChance[iIndex] = flClamp(g_flTrackChance[iIndex], 0.0, 100.0);
					g_iTrackMode[iIndex] = kvSuperTanks.GetNum("Track Ability/Track Mode", 1);
					g_iTrackMode[iIndex] = iClamp(g_iTrackMode[iIndex], 0, 1);
					g_flTrackSpeed[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Speed", 500.0);
					g_flTrackSpeed[iIndex] = flClamp(g_flTrackSpeed[iIndex], 0.1, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iGlowEnabled2[iIndex] = kvSuperTanks.GetNum("General/Glow Enabled", g_iGlowEnabled[iIndex]);
					g_iGlowEnabled2[iIndex] = iClamp(g_iGlowEnabled2[iIndex], 0, 1);

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Track Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Track Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Track Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iTrackAbility2[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Enabled", g_iTrackAbility[iIndex]);
					g_iTrackAbility2[iIndex] = iClamp(g_iTrackAbility2[iIndex], 0, 1);
					g_iTrackMessage2[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Message", g_iTrackMessage[iIndex]);
					g_iTrackMessage2[iIndex] = iClamp(g_iTrackMessage2[iIndex], 0, 1);
					g_flTrackChance2[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Chance", g_flTrackChance[iIndex]);
					g_flTrackChance2[iIndex] = flClamp(g_flTrackChance2[iIndex], 0.0, 100.0);
					g_iTrackMode2[iIndex] = kvSuperTanks.GetNum("Track Ability/Track Mode", g_iTrackMode[iIndex]);
					g_iTrackMode2[iIndex] = iClamp(g_iTrackMode2[iIndex], 0, 1);
					g_flTrackSpeed2[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Speed", g_flTrackSpeed[iIndex]);
					g_flTrackSpeed2[iIndex] = flClamp(g_flTrackSpeed2[iIndex], 100.0, 500.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "0245") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveTrack(iTank);
		}
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (iTrackAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bTrack[tank] && !g_bTrack2[tank])
				{
					if (g_iTrackCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						g_bTrack[tank] = true;
						g_iTrackCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "TrackHuman", g_iTrackCount[tank], iHumanAmmo(tank));
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

public void ST_OnChangeType(int tank)
{
	vRemoveTrack(tank);
}

public void ST_OnRockThrow(int tank, int rock)
{
	float flTrackChance = !g_bTankConfig[ST_TankType(tank)] ? g_flTrackChance[ST_TankType(tank)] : g_flTrackChance2[ST_TankType(tank)];
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && iTrackAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flTrackChance)
	{
		if ((!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && !g_bTrack[tank])
		{
			g_bTrack[tank] = true;
		}

		DataPack dpTrack;
		CreateDataTimer(0.5, tTimerTrack, dpTrack, TIMER_FLAG_NO_MAPCHANGE);
		dpTrack.WriteCell(EntIndexToEntRef(rock));
		dpTrack.WriteCell(GetClientUserId(tank));

		int iTrackMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iTrackMessage[ST_TankType(tank)] : g_iTrackMessage2[ST_TankType(tank)];
		if (iTrackMessage == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveTrack(iPlayer);
		}
	}
}

static void vTrack(int rock)
{
	int iTank = GetEntPropEnt(rock, Prop_Data, "m_hThrower"),
		iTrackMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iTrackMode[ST_TankType(iTank)] : g_iTrackMode2[ST_TankType(iTank)];
	switch (iTrackMode)
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

			float flTrackSpeed = !g_bTankConfig[ST_TankType(iTank)] ? g_flTrackSpeed[ST_TankType(iTank)] : g_flTrackSpeed2[ST_TankType(iTank)];
			ScaleVector(flVelocity3, flTrackSpeed);

			SetEntityGravity(rock, 0.01);
			TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, flVelocity3);

			int iGlowEnabled = !g_bTankConfig[ST_TankType(iTank)] ? g_iGlowEnabled[ST_TankType(iTank)] : g_iGlowEnabled2[ST_TankType(iTank)];
			if (iGlowEnabled == 1 && bIsValidGame())
			{
				int iGlowRed, iGlowGreen, iGlowBlue, iGlowAlpha;
				ST_TankColors(iTank, 2, iGlowRed, iGlowGreen, iGlowBlue, iGlowAlpha);
				SetEntProp(rock, Prop_Send, "m_iGlowType", 3);
				SetEntProp(rock, Prop_Send, "m_nGlowRange", 0);
				SetEntProp(rock, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowRed, iGlowGreen, iGlowBlue));
			}
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iTrackAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iTrackAbility[ST_TankType(tank)] : g_iTrackAbility2[ST_TankType(tank)];
}

public Action tTimerTrack(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!ST_PluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iTrackAbility(iTank) == 0 || !g_bTrack[iTank])
	{
		g_bTrack[iTank] = false;

		return Plugin_Stop;
	}

	SDKUnhook(iRock, SDKHook_Think, Think);
	SDKHook(iRock, SDKHook_Think, Think);

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && !g_bTrack2[iTank])
	{
		g_bTrack[iTank] = false;
		g_bTrack2[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "TrackHuman4");

		if (g_iTrackCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bTrack2[iTank])
	{
		g_bTrack2[iTank] = false;

		return Plugin_Stop;
	}

	g_bTrack2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "TrackHuman5");

	return Plugin_Continue;
}