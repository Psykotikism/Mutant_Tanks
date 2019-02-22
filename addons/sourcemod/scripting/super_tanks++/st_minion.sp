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

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Minion Ability",
	author = ST_AUTHOR,
	description = "The Super Tank spawns minions.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Minion Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_MINION "Minion Ability"

bool g_bCloneInstalled, g_bMinion[MAXPLAYERS + 1], g_bMinion2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flMinionChance[ST_MAXTYPES + 1], g_flMinionChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iMinionAbility[ST_MAXTYPES + 1], g_iMinionAbility2[ST_MAXTYPES + 1], g_iMinionAmount[ST_MAXTYPES + 1], g_iMinionAmount2[ST_MAXTYPES + 1], g_iMinionCount[MAXPLAYERS + 1], g_iMinionCount2[MAXPLAYERS + 1], g_iMinionMessage[ST_MAXTYPES + 1], g_iMinionMessage2[ST_MAXTYPES + 1], g_iMinionOwner[MAXPLAYERS + 1], g_iMinionReplace[ST_MAXTYPES + 1], g_iMinionReplace2[ST_MAXTYPES + 1], g_iMinionTypes[ST_MAXTYPES + 1], g_iMinionTypes2[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_minion", cmdMinionInfo, "View information about the Minion ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveMinion(client);

	g_bMinion[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdMinionInfo(int client, int args)
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
		case false: vMinionMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vMinionMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iMinionMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Minion Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iMinionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iMinionAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iMinionCount2[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "MinionDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vMinionMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "MinionMenu", param1);
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
	menu.AddItem(ST_MENU_MINION, ST_MENU_MINION);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_MINION, false))
	{
		vMinionMenu(client, 0);
	}
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Minion Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Minion Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Minion Ability/Human Cooldown", 60.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iMinionAbility[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Enabled", 0);
					g_iMinionAbility[iIndex] = iClamp(g_iMinionAbility[iIndex], 0, 1);
					g_iMinionMessage[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Message", 0);
					g_iMinionMessage[iIndex] = iClamp(g_iMinionMessage[iIndex], 0, 1);
					g_iMinionAmount[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Amount", 5);
					g_iMinionAmount[iIndex] = iClamp(g_iMinionAmount[iIndex], 1, 25);
					g_flMinionChance[iIndex] = kvSuperTanks.GetFloat("Minion Ability/Minion Chance", 33.3);
					g_flMinionChance[iIndex] = flClamp(g_flMinionChance[iIndex], 0.0, 100.0);
					g_iMinionReplace[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Replace", 1);
					g_iMinionReplace[iIndex] = iClamp(g_iMinionReplace[iIndex], 0, 1);
					g_iMinionTypes[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Types", 0);
					g_iMinionTypes[iIndex] = iClamp(g_iMinionTypes[iIndex], 0, 63);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Minion Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iMinionAbility2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Enabled", g_iMinionAbility[iIndex]);
					g_iMinionAbility2[iIndex] = iClamp(g_iMinionAbility2[iIndex], 0, 1);
					g_iMinionMessage2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Message", g_iMinionMessage[iIndex]);
					g_iMinionMessage2[iIndex] = iClamp(g_iMinionMessage2[iIndex], 0, 1);
					g_iMinionAmount2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Amount", g_iMinionAmount[iIndex]);
					g_iMinionAmount2[iIndex] = iClamp(g_iMinionAmount2[iIndex], 1, 25);
					g_flMinionChance2[iIndex] = kvSuperTanks.GetFloat("Minion Ability/Minion Chance", g_flMinionChance[iIndex]);
					g_flMinionChance2[iIndex] = flClamp(g_flMinionChance2[iIndex], 0.0, 100.0);
					g_iMinionReplace2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Replace", g_iMinionReplace[iIndex]);
					g_iMinionReplace2[iIndex] = iClamp(g_iMinionReplace2[iIndex], 0, 1);
					g_iMinionTypes2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Types", g_iMinionTypes[iIndex]);
					g_iMinionTypes2[iIndex] = iClamp(g_iMinionTypes2[iIndex], 0, 63);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnPluginEnd()
{
	for (int iMinion = 1; iMinion <= MaxClients; iMinion++)
	{
		if ((bIsTank(iMinion, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) || bIsSpecialInfected(iMinion, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE)) && g_bMinion[iMinion])
		{
			!bIsValidClient(iMinion, ST_CHECK_FAKECLIENT) ? KickClient(iMinion) : ForcePlayerSuicide(iMinion);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		if (ST_IsTankSupported(iInfected, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			g_bMinion2[iInfected] = false;
			g_iMinionCount[iInfected] = 0;
		}

		if (bIsSpecialInfected(iInfected) && g_bMinion[iInfected])
		{
			for (int iOwner = 1; iOwner <= MaxClients; iOwner++)
			{
				if (ST_IsTankSupported(iOwner, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && ST_IsCloneSupported(iOwner, g_bCloneInstalled) && g_iMinionOwner[iInfected] == iOwner)
				{
					g_bMinion[iInfected] = false;
					g_iMinionOwner[iInfected] = 0;

					if (iMinionAbility(iOwner) == 1)
					{
						switch (g_iMinionCount[iOwner])
						{
							case 0, 1:
							{
								g_iMinionCount[iOwner] = 0;

								if (ST_IsTankSupported(iOwner, ST_CHECK_FAKECLIENT) && iHumanAbility(iOwner) == 1)
								{
									g_bMinion2[iOwner] = true;

									ST_PrintToChat(iOwner, "%s %t", ST_TAG3, "MinionHuman5");

									CreateTimer(flHumanCooldown(iOwner), tTimerResetCooldown, GetClientUserId(iOwner), TIMER_FLAG_NO_MAPCHANGE);
								}
							}
							default:
							{
								int iMinionReplace = !g_bTankConfig[ST_GetTankType(iOwner)] ? g_iMinionReplace[ST_GetTankType(iOwner)] : g_iMinionReplace2[ST_GetTankType(iOwner)];
								if (iMinionReplace == 1)
								{
									g_iMinionCount[iOwner]--;
								}

								ST_PrintToChat(iOwner, "%s %t", ST_TAG3, "MinionHuman4");
							}
						}
					}

					break;
				}
			}
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iMinionAbility(tank) == 1)
	{
		vMinionAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (iMinionAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bMinion2[tank])
				{
					vMinionAbility(tank);
				}
				else if (g_bMinion2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "MinionHuman3");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveMinion(tank);
}

static void vMinionAbility(int tank)
{
	int iMinionAmount = !g_bTankConfig[ST_GetTankType(tank)] ? g_iMinionAmount[ST_GetTankType(tank)] : g_iMinionAmount2[ST_GetTankType(tank)];
	if (g_iMinionCount[tank] < iMinionAmount && g_iMinionCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flMinionChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flMinionChance[ST_GetTankType(tank)] : g_flMinionChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flMinionChance)
		{
			float flHitPosition[3], flPosition[3], flAngles[3], flVector[3];
			GetClientEyePosition(tank, flPosition);
			GetClientEyeAngles(tank, flAngles);
			flAngles[0] = -25.0;

			GetAngleVectors(flAngles, flAngles, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(flAngles, flAngles);
			ScaleVector(flAngles, -1.0);
			vCopyVector(flAngles, flVector);
			GetVectorAngles(flAngles, flAngles);

			Handle hTrace = TR_TraceRayFilterEx(flPosition, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
			if (TR_DidHit(hTrace))
			{
				TR_GetEndPosition(flHitPosition, hTrace);
				NormalizeVector(flVector, flVector);
				ScaleVector(flVector, -40.0);
				AddVectors(flHitPosition, flVector, flHitPosition);

				if (GetVectorDistance(flHitPosition, flPosition) < 200.0 && GetVectorDistance(flHitPosition, flPosition) > 40.0)
				{
					bool bSpecialInfected[MAXPLAYERS + 1];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						bSpecialInfected[iPlayer] = false;
						if (bIsInfected(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
						{
							bSpecialInfected[iPlayer] = true;
						}
					}

					int iTypeCount, iTypes[7], iMinionTypes = !g_bTankConfig[ST_GetTankType(tank)] ? g_iMinionTypes[ST_GetTankType(tank)] : g_iMinionTypes2[ST_GetTankType(tank)];
					for (int iBit = 0; iBit < 6; iBit++)
					{
						int iFlag = (1 << iBit);
						if (!(iMinionTypes & iFlag))
						{
							continue;
						}

						iTypes[iTypeCount] = iFlag;
						iTypeCount++;
					}

					switch (iTypes[GetRandomInt(0, iTypeCount - 1)])
					{
						case 1: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "smoker");
						case 2: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "boomer");
						case 4: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
						case 8: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "spitter" : "boomer");
						case 16: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "jockey" : "hunter");
						case 32: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "charger" : "smoker");
						default:
						{
							switch (GetRandomInt(1, 6))
							{
								case 1: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "smoker");
								case 2: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "boomer");
								case 3: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
								case 4: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "spitter" : "boomer");
								case 5: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "jockey" : "hunter");
								case 6: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "charger" : "smoker");
							}
						}
					}

					int iSelectedType;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (bIsInfected(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && !bSpecialInfected[iPlayer])
						{
							iSelectedType = iPlayer;

							break;
						}
					}

					if (iSelectedType > 0)
					{
						TeleportEntity(iSelectedType, flHitPosition, NULL_VECTOR, NULL_VECTOR);

						g_bMinion[iSelectedType] = true;
						g_iMinionCount[tank]++;
						g_iMinionOwner[iSelectedType] = tank;

						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
						{
							g_iMinionCount2[tank]++;

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "MinionHuman", g_iMinionCount2[tank], iHumanAmmo(tank));
						}

						int iMinionMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_iMinionMessage[ST_GetTankType(tank)] : g_iMinionMessage2[ST_GetTankType(tank)];
						if (iMinionMessage == 1)
						{
							char sTankName[33];
							ST_GetTankName(tank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Minion", sTankName);
						}
					}
				}
			}

			delete hTrace;
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "MinionHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "MinionAmmo");
	}
}

static void vRemoveMinion(int tank)
{
	g_bMinion2[tank] = false;
	g_iMinionCount[tank] = 0;
	g_iMinionCount2[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveMinion(iPlayer);

			g_bMinion[iPlayer] = false;
			g_iMinionOwner[iPlayer] = 0;
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iMinionAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iMinionAbility[ST_GetTankType(tank)] : g_iMinionAbility2[ST_GetTankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bMinion2[iTank])
	{
		g_bMinion2[iTank] = false;

		return Plugin_Stop;
	}

	g_bMinion2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "MinionHuman6");

	return Plugin_Continue;
}