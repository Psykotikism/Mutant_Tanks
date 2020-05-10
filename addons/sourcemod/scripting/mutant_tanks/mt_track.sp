/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#tryinclude <mt_clone>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Track Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank throws heat-seeking rocks that will track down the nearest survivors.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Track Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_TRACK "Track Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bTrack;
	bool g_bTrack2;

	int g_iAccessFlags2;
	int g_iImmunityFlags2;
	int g_iTrackCount;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flTrackChance;
	float g_flTrackSpeed;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iImmunityFlags;
	int g_iTrackAbility;
	int g_iTrackMessage;
	int g_iTrackMode;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_track", cmdTrackInfo, "View information about the Track ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveTrack(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveTrack(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdTrackInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iTrackAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iTrackCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "TrackDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_TRACK, MT_MENU_TRACK);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_TRACK, false))
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

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("trackability");
	list2.PushString("track ability");
	list3.PushString("track_ability");
	list4.PushString("track");
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_esPlayer[iPlayer].g_iAccessFlags2 = 0;
				g_esPlayer[iPlayer].g_iImmunityFlags2 = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_esAbility[iIndex].g_iAccessFlags = 0;
			g_esAbility[iIndex].g_iImmunityFlags = 0;
			g_esAbility[iIndex].g_iHumanAbility = 0;
			g_esAbility[iIndex].g_iHumanAmmo = 5;
			g_esAbility[iIndex].g_flHumanCooldown = 30.0;
			g_esAbility[iIndex].g_iTrackAbility = 0;
			g_esAbility[iIndex].g_iTrackMessage = 0;
			g_esAbility[iIndex].g_flTrackChance = 33.3;
			g_esAbility[iIndex].g_iTrackMode = 1;
			g_esAbility[iIndex].g_flTrackSpeed = 500.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "trackability", false) || StrEqual(subsection, "track ability", false) || StrEqual(subsection, "track_ability", false) || StrEqual(subsection, "track", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iImmunityFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iTrackAbility = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iTrackAbility, value, 0, 1);
		g_esAbility[type].g_iTrackMessage = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iTrackMessage, value, 0, 1);
		g_esAbility[type].g_flTrackChance = flGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "TrackChance", "Track Chance", "Track_Chance", "chance", g_esAbility[type].g_flTrackChance, value, 0.0, 100.0);
		g_esAbility[type].g_iTrackMode = iGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "TrackMode", "Track Mode", "Track_Mode", "mode", g_esAbility[type].g_iTrackMode, value, 0, 1);
		g_esAbility[type].g_flTrackSpeed = flGetValue(subsection, "trackability", "track ability", "track_ability", "track", key, "TrackSpeed", "Track Speed", "Track_Speed", "speed", g_esAbility[type].g_flTrackSpeed, value, 0.1, 999999.0);

		if (StrEqual(subsection, "trackability", false) || StrEqual(subsection, "track ability", false) || StrEqual(subsection, "track_ability", false) || StrEqual(subsection, "track", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iImmunityFlags;
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveTrack(iTank);
		}
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY == MT_SPECIAL_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iTrackAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (!g_esPlayer[tank].g_bTrack && !g_esPlayer[tank].g_bTrack2)
				{
					if (g_esPlayer[tank].g_iTrackCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
					{
						g_esPlayer[tank].g_bTrack = true;
						g_esPlayer[tank].g_iTrackCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackHuman", g_esPlayer[tank].g_iTrackCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackAmmo");
					}
				}
				else if (g_esPlayer[tank].g_bTrack)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackHuman2");
				}
				else if (g_esPlayer[tank].g_bTrack2)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackHuman3");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveTrack(tank);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iTrackAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(tank)].g_flTrackChance)
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if ((!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && !g_esPlayer[tank].g_bTrack)
		{
			g_esPlayer[tank].g_bTrack = true;
		}

		DataPack dpTrack;
		CreateDataTimer(0.5, tTimerTrack, dpTrack, TIMER_FLAG_NO_MAPCHANGE);
		dpTrack.WriteCell(EntIndexToEntRef(rock));
		dpTrack.WriteCell(GetClientUserId(tank));
		dpTrack.WriteCell(MT_GetTankType(tank));

		if (g_esAbility[MT_GetTankType(tank)].g_iTrackMessage == 1)
		{
			char sTankName[33];
			MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Track", sTankName);
		}
	}
}

static void vRemoveTrack(int tank)
{
	g_esPlayer[tank].g_bTrack = false;
	g_esPlayer[tank].g_bTrack2 = false;
	g_esPlayer[tank].g_iTrackCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveTrack(iPlayer);
		}
	}
}

static void vTrack(int rock)
{
	int iTank = GetEntPropEnt(rock, Prop_Data, "m_hThrower");
	switch (g_esAbility[MT_GetTankType(iTank)].g_iTrackMode)
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

			int iTarget = iGetRockTarget(flPos, flVelocity, iTank);
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

			int iTarget = iGetRockTarget(flPos, flVelocity, iTank);
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

			ScaleVector(flVelocity3, g_esAbility[MT_GetTankType(iTank)].g_flTrackSpeed);

			SetEntityGravity(rock, 0.01);
			TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, flVelocity3);

			if (MT_IsGlowEnabled(iTank) && bIsValidGame())
			{
				int iGlowColor[4];
				MT_GetTankColors(iTank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
				SetEntProp(rock, Prop_Send, "m_iGlowType", 3);
				SetEntProp(rock, Prop_Send, "m_nGlowRange", 0);
				SetEntProp(rock, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]));
			}
		}
	}
}

static int iGetRockTarget(float pos[3], float angle[3], int tank)
{
	float flMin = 4.0, flPos[3], flAngle;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			if (MT_IsAdminImmune(iSurvivor, tank) || bIsAdminImmune(iSurvivor, tank))
			{
				continue;
			}

			GetClientEyePosition(iSurvivor, flPos);
			MakeVectorFromPoints(pos, flPos, flPos);
			flAngle = flGetAngle(angle, flPos);

			if (flAngle <= flMin)
			{
				flMin = flAngle;

				return iSurvivor;
			}
		}
	}

	return 0;
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(admin)].g_iAccessFlags;
	if (iAbilityFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iAbilityFlags)) ? false : true;
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iTypeFlags)) ? false : true;
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iGlobalFlags)) ? false : true;
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(tank)].g_iImmunityFlags;
	if (iAbilityFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iAbilityFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(tank));
	if (iTypeFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iTypeFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iGlobalFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
	{
		return (iClientTypeFlags2 != 0 && (iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
	{
		return (iClientGlobalFlags2 != 0 && (iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
	}

	int iSurvivorFlags = GetUserFlagBits(survivor), iTankFlags = GetUserFlagBits(tank);
	if (iAbilityFlags != 0 && iSurvivorFlags != 0 && (iSurvivorFlags & iAbilityFlags))
	{
		return (iTankFlags != 0 && iSurvivorFlags <= iTankFlags) ? false : true;
	}

	return false;
}

public Action tTimerTrack(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || g_esAbility[MT_GetTankType(iTank)].g_iTrackAbility == 0 || !g_esPlayer[iTank].g_bTrack)
	{
		g_esPlayer[iTank].g_bTrack = false;

		return Plugin_Stop;
	}

	SDKUnhook(iRock, SDKHook_Think, Think);
	SDKHook(iRock, SDKHook_Think, Think);

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && !g_esPlayer[iTank].g_bTrack2)
	{
		g_esPlayer[iTank].g_bTrack = false;
		g_esPlayer[iTank].g_bTrack2 = true;

		MT_PrintToChat(iTank, "%s %t", MT_TAG3, "TrackHuman4");

		if (g_esPlayer[iTank].g_iTrackCount < g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo > 0)
		{
			CreateTimer(g_esAbility[MT_GetTankType(iTank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_esPlayer[iTank].g_bTrack2 = false;
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bTrack2)
	{
		g_esPlayer[iTank].g_bTrack2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bTrack2 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "TrackHuman5");

	return Plugin_Continue;
}