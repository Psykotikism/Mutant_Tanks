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

#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Clone Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates clones of itself.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Clone Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	CreateNative("ST_IsCloneSupported", aNative_IsCloneSupported);

	RegPluginLibrary("st_clone");

	return APLRes_Success;
}

#define ST_MENU_CLONE "Clone Ability"

bool g_bClone[MAXPLAYERS + 1], g_bClone2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flCloneChance[ST_MAXTYPES + 1], g_flCloneChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iCloneAbility[ST_MAXTYPES + 1], g_iCloneAbility2[ST_MAXTYPES + 1], g_iCloneAmount[ST_MAXTYPES + 1], g_iCloneAmount2[ST_MAXTYPES + 1], g_iCloneCount[MAXPLAYERS + 1], g_iCloneCount2[MAXPLAYERS + 1], g_iCloneHealth[ST_MAXTYPES + 1], g_iCloneHealth2[ST_MAXTYPES + 1], g_iCloneMessage[ST_MAXTYPES + 1], g_iCloneMessage2[ST_MAXTYPES + 1], g_iCloneMode[ST_MAXTYPES + 1], g_iCloneMode2[ST_MAXTYPES + 1], g_iCloneOwner[MAXPLAYERS + 1], g_iCloneReplace[ST_MAXTYPES + 1], g_iCloneReplace2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public any aNative_IsCloneSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	bool bCloneInstalled = GetNativeCell(2);
	if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, bCloneInstalled))
	{
		return true;
	}

	return false;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_clone", cmdCloneInfo, "View information about the Clone ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveClone(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdCloneInfo(int client, int args)
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
		case false: vCloneMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vCloneMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iCloneMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Clone Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iCloneMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iCloneAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iCloneCount2[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "CloneDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vCloneMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "CloneMenu", param1);
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
	menu.AddItem(ST_MENU_CLONE, ST_MENU_CLONE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_CLONE, false))
	{
		vCloneMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Clone Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Clone Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Clone Ability/Human Cooldown", 60.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iCloneAbility[iIndex] = kvSuperTanks.GetNum("Clone Ability/Ability Enabled", 0);
					g_iCloneAbility[iIndex] = iClamp(g_iCloneAbility[iIndex], 0, 1);
					g_iCloneMessage[iIndex] = kvSuperTanks.GetNum("Clone Ability/Ability Message", 0);
					g_iCloneMessage[iIndex] = iClamp(g_iCloneMessage[iIndex], 0, 1);
					g_iCloneAmount[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Amount", 2);
					g_iCloneAmount[iIndex] = iClamp(g_iCloneAmount[iIndex], 1, 25);
					g_flCloneChance[iIndex] = kvSuperTanks.GetFloat("Clone Ability/Clone Chance", 33.3);
					g_flCloneChance[iIndex] = flClamp(g_flCloneChance[iIndex], 0.0, 100.0);
					g_iCloneHealth[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Health", 1000);
					g_iCloneHealth[iIndex] = iClamp(g_iCloneHealth[iIndex], 1, ST_MAXHEALTH);
					g_iCloneMode[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Mode", 0);
					g_iCloneMode[iIndex] = iClamp(g_iCloneMode[iIndex], 0, 1);
					g_iCloneReplace[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Replace", 1);
					g_iCloneReplace[iIndex] = iClamp(g_iCloneReplace[iIndex], 0, 1);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Clone Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iCloneAbility2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Ability Enabled", g_iCloneAbility[iIndex]);
					g_iCloneAbility2[iIndex] = iClamp(g_iCloneAbility2[iIndex], 0, 1);
					g_iCloneMessage2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Ability Message", g_iCloneMessage[iIndex]);
					g_iCloneMessage2[iIndex] = iClamp(g_iCloneMessage2[iIndex], 0, 1);
					g_iCloneAmount2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Amount", g_iCloneAmount[iIndex]);
					g_iCloneAmount2[iIndex] = iClamp(g_iCloneAmount2[iIndex], 1, 25);
					g_flCloneChance2[iIndex] = kvSuperTanks.GetFloat("Clone Ability/Clone Chance", g_flCloneChance[iIndex]);
					g_flCloneChance2[iIndex] = flClamp(g_flCloneChance2[iIndex], 0.0, 100.0);
					g_iCloneHealth2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Health", g_iCloneHealth[iIndex]);
					g_iCloneHealth2[iIndex] = iClamp(g_iCloneHealth2[iIndex], 1, ST_MAXHEALTH);
					g_iCloneMode2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Mode", g_iCloneMode[iIndex]);
					g_iCloneMode2[iIndex] = iClamp(g_iCloneMode2[iIndex], 0, 1);
					g_iCloneReplace2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Replace", g_iCloneReplace[iIndex]);
					g_iCloneReplace2[iIndex] = iClamp(g_iCloneReplace2[iIndex], 0, 1);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnPluginEnd()
{
	for (int iClone = 1; iClone <= MaxClients; iClone++)
	{
		if (bIsTank(iClone, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bClone[iClone])
		{
			!bIsValidClient(iClone, ST_CHECK_FAKECLIENT) ? KickClient(iClone) : ForcePlayerSuicide(iClone);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveClone(iTank, true);

			if (iCloneAbility(iTank) == 1)
			{
				switch (g_bClone[iTank])
				{
					case true:
					{
						for (int iOwner = 1; iOwner <= MaxClients; iOwner++)
						{
							if (ST_IsTankSupported(iOwner, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_iCloneOwner[iTank] == iOwner)
							{
								g_bClone[iTank] = false;
								g_iCloneOwner[iTank] = 0;

								switch (g_iCloneCount[iOwner])
								{
									case 0, 1:
									{
										g_iCloneCount[iOwner] = 0;

										if (ST_IsTankSupported(iOwner, ST_CHECK_FAKECLIENT) && iHumanAbility(iOwner) == 1)
										{
											g_bClone2[iOwner] = true;

											ST_PrintToChat(iOwner, "%s %t", ST_TAG3, "CloneHuman6");

											CreateTimer(flHumanCooldown(iOwner), tTimerResetCooldown, GetClientUserId(iOwner), TIMER_FLAG_NO_MAPCHANGE);
										}
									}
									default:
									{
										int iCloneReplace = !g_bTankConfig[ST_GetTankType(iOwner)] ? g_iCloneReplace[ST_GetTankType(iOwner)] : g_iCloneReplace2[ST_GetTankType(iOwner)];
										if (iCloneReplace == 1)
										{
											g_iCloneCount[iOwner]--;
										}

										if (ST_IsTankSupported(iOwner, ST_CHECK_FAKECLIENT) && iHumanAbility(iOwner) == 1)
										{
											ST_PrintToChat(iOwner, "%s %t", ST_TAG3, "CloneHuman5");
										}
									}
								}

								break;
							}
						}
					}
					case false:
					{
						for (int iClone = 1; iClone <= MaxClients; iClone++)
						{
							if (ST_IsTankSupported(iTank, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_iCloneOwner[iClone] == iTank)
							{
								g_iCloneOwner[iClone] = 0;
							}
						}
					}
				}
			}
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && iCloneAbility(tank) == 1 && !g_bClone[tank])
	{
		vCloneAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && !g_bClone[tank])
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (iCloneAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bClone[tank] && !g_bClone2[tank])
				{
					vCloneAbility(tank);
				}
				else if (g_bClone[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "CloneHuman3");
				}
				else if (g_bClone2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "CloneHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveClone(tank, revert);
}

static void vCloneAbility(int tank)
{
	int iCloneAmount = !g_bTankConfig[ST_GetTankType(tank)] ? g_iCloneAmount[ST_GetTankType(tank)] : g_iCloneAmount2[ST_GetTankType(tank)];
	if (g_iCloneCount[tank] < iCloneAmount && g_iCloneCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flCloneChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flCloneChance[ST_GetTankType(tank)] : g_flCloneChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flCloneChance)
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

				float flDistance = GetVectorDistance(flHitPosition, flPosition);
				if (flDistance < 200.0 && flDistance > 40.0)
				{
					bool bTankBoss[MAXPLAYERS + 1];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						bTankBoss[iPlayer] = false;
						if (ST_IsTankSupported(iPlayer, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
						{
							bTankBoss[iPlayer] = true;
						}
					}

					ST_SpawnTank(tank, ST_GetTankType(tank));

					int iSelectedType;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (ST_IsTankSupported(iPlayer, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !bTankBoss[iPlayer])
						{
							iSelectedType = iPlayer;

							break;
						}
					}

					if (iSelectedType > 0)
					{
						TeleportEntity(iSelectedType, flHitPosition, NULL_VECTOR, NULL_VECTOR);

						g_bClone[iSelectedType] = true;
						g_iCloneCount[tank]++;
						g_iCloneOwner[iSelectedType] = tank;

						int iCloneHealth = !g_bTankConfig[ST_GetTankType(tank)] ? g_iCloneHealth[ST_GetTankType(tank)] : g_iCloneHealth2[ST_GetTankType(tank)],
							iNewHealth = (iCloneHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCloneHealth;
						SetEntityHealth(iSelectedType, iNewHealth);

						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
						{
							g_iCloneCount2[tank]++;

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "CloneHuman", g_iCloneCount2[tank], iHumanAmmo(tank));
						}

						int iCloneMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_iCloneMessage[ST_GetTankType(tank)] : g_iCloneMessage2[ST_GetTankType(tank)];
						if (iCloneMessage == 1)
						{
							char sTankName[33];
							ST_GetTankName(tank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Clone", sTankName);
						}
					}
				}
			}

			delete hTrace;
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "CloneHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "CloneAmmo");
	}
}

static void vRemoveClone(int tank, bool revert = false)
{
	if (!revert)
	{
		g_bClone[tank] = false;
	}

	g_bClone2[tank] = false;
	g_iCloneCount[tank] = 0;
	g_iCloneCount2[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveClone(iPlayer);

			g_iCloneOwner[iPlayer] = 0;
		}
	}
}

static bool bIsCloneAllowed(int tank, bool clone)
{
	int iCloneMode = !g_bTankConfig[ST_GetTankType(tank)] ? g_iCloneMode[ST_GetTankType(tank)] : g_iCloneMode2[ST_GetTankType(tank)];
	if (clone && iCloneMode == 0 && g_bClone[tank])
	{
		return false;
	}

	return true;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iCloneAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iCloneAbility[ST_GetTankType(tank)] : g_iCloneAbility2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || g_bClone[iTank] || !g_bClone2[iTank])
	{
		g_bClone2[iTank] = false;

		return Plugin_Stop;
	}

	g_bClone2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "CloneHuman7");

	return Plugin_Continue;
}