/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
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
#include <mutant_tanks>
#undef REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Clone Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates clones of itself.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Clone Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	CreateNative("MT_IsCloneSupported", aNative_IsCloneSupported);

	RegPluginLibrary("mt_clone");

	return APLRes_Success;
}

#define MT_MENU_CLONE "Clone Ability"

bool g_bClone[MAXPLAYERS + 1], g_bClone2[MAXPLAYERS + 1];

float g_flCloneChance[MT_MAXTYPES + 1], g_flHumanCooldown[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iCloneAbility[MT_MAXTYPES + 1], g_iCloneAmount[MT_MAXTYPES + 1], g_iCloneCount[MAXPLAYERS + 1], g_iCloneCount2[MAXPLAYERS + 1], g_iCloneHealth[MT_MAXTYPES + 1], g_iCloneMessage[MT_MAXTYPES + 1], g_iCloneMode[MT_MAXTYPES + 1], g_iCloneOwner[MAXPLAYERS + 1], g_iCloneReplace[MT_MAXTYPES + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1];

public any aNative_IsCloneSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	bool bCloneInstalled = GetNativeCell(2);
	if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
	{
		if (bCloneInstalled && g_iCloneMode[MT_GetTankType(iTank)] == 0 && g_bClone[iTank])
		{
			return false;
		}
	}

	return true;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_clone", cmdCloneInfo, "View information about the Clone ability.");
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
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iCloneAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iCloneCount2[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "CloneDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_CLONE, MT_MENU_CLONE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_CLONE, false))
	{
		vCloneMenu(client, 0);
	}
}

public void MT_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 60.0;
		g_iCloneAbility[iIndex] = 0;
		g_iCloneMessage[iIndex] = 0;
		g_iCloneAmount[iIndex] = 2;
		g_flCloneChance[iIndex] = 33.3;
		g_iCloneHealth[iIndex] = 1000;
		g_iCloneMode[iIndex] = 0;
		g_iCloneReplace[iIndex] = 1;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "cloneability", false) || StrEqual(subsection, "clone ability", false) || StrEqual(subsection, "clone_ability", false) || StrEqual(subsection, "clone", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		g_iHumanAbility[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 999999.0);
		g_iCloneAbility[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iCloneAbility[type], value, 0, 1);
		g_iCloneMessage[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iCloneMessage[type], value, 0, 1);
		g_iCloneAmount[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneAmount", "Clone Amount", "Clone_Amount", "amount", g_iCloneAmount[type], value, 1, 25);
		g_flCloneChance[type] = flGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneChance", "Clone Chance", "Clone_Chance", "chance", g_flCloneChance[type], value, 0.0, 100.0);
		g_iCloneHealth[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneHealth", "Clone Health", "Clone_Health", "health", g_iCloneHealth[type], value, 1, MT_MAXHEALTH);
		g_iCloneMode[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneMode", "Clone Mode", "Clone_Mode", "mode", g_iCloneMode[type], value, 0, 1);
		g_iCloneReplace[type] = iGetValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneReplace", "Clone Replace", "Clone_Replace", "replace", g_iCloneReplace[type], value, 0, 1);

		if (StrEqual(subsection, "cloneability", false) || StrEqual(subsection, "clone ability", false) || StrEqual(subsection, "clone_ability", false) || StrEqual(subsection, "clone", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}
	}
}

public void MT_OnPluginEnd()
{
	for (int iClone = 1; iClone <= MaxClients; iClone++)
	{
		if (bIsTank(iClone, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && g_bClone[iClone])
		{
			!bIsValidClient(iClone, MT_CHECK_FAKECLIENT) ? KickClient(iClone) : ForcePlayerSuicide(iClone);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveClone(iTank, true);

			if (g_iCloneAbility[MT_GetTankType(iTank)] == 1)
			{
				switch (g_bClone[iTank])
				{
					case true:
					{
						for (int iOwner = 1; iOwner <= MaxClients; iOwner++)
						{
							if (MT_IsTankSupported(iOwner, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && g_iCloneOwner[iTank] == iOwner)
							{
								g_bClone[iTank] = false;
								g_iCloneOwner[iTank] = 0;

								switch (g_iCloneCount[iOwner])
								{
									case 0, 1:
									{
										g_iCloneCount[iOwner] = 0;

										if (MT_IsTankSupported(iOwner, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iOwner) || bHasAdminAccess(iOwner)) && g_iHumanAbility[MT_GetTankType(iOwner)] == 1)
										{
											g_bClone2[iOwner] = true;

											MT_PrintToChat(iOwner, "%s %t", MT_TAG3, "CloneHuman6");

											if (g_flHumanCooldown[MT_GetTankType(iOwner)] > 0.0)
											{
												CreateTimer(g_flHumanCooldown[MT_GetTankType(iOwner)], tTimerResetCooldown, GetClientUserId(iOwner), TIMER_FLAG_NO_MAPCHANGE);
											}
											else
											{
												g_bClone2[iOwner] = false;
											}
										}
									}
									default:
									{
										if (g_iCloneReplace[MT_GetTankType(iOwner)] == 1)
										{
											g_iCloneCount[iOwner]--;
										}

										if (MT_IsTankSupported(iOwner, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iOwner)] == 1)
										{
											MT_PrintToChat(iOwner, "%s %t", MT_TAG3, "CloneHuman5");
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
							if (MT_IsTankSupported(iTank, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && g_iCloneOwner[iClone] == iTank)
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

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && g_iCloneAbility[MT_GetTankType(tank)] == 1 && !g_bClone[tank])
	{
		vCloneAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (button & MT_SPECIAL_KEY == MT_SPECIAL_KEY)
		{
			if (g_iCloneAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bClone[tank] && !g_bClone2[tank])
				{
					vCloneAbility(tank);
				}
				else if (g_bClone[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman3");
				}
				else if (g_bClone2[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman4");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveClone(tank, revert);
}

static void vCloneAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iCloneCount[tank] < g_iCloneAmount[MT_GetTankType(tank)] && g_iCloneCount2[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flCloneChance[MT_GetTankType(tank)])
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
						if (MT_IsTankSupported(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE))
						{
							bTankBoss[iPlayer] = true;
						}
					}

					MT_SpawnTank(tank, MT_GetTankType(tank));

					int iSelectedType;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (MT_IsTankSupported(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && !bTankBoss[iPlayer])
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

						int iNewHealth = (g_iCloneHealth[MT_GetTankType(tank)] > MT_MAXHEALTH) ? MT_MAXHEALTH : g_iCloneHealth[MT_GetTankType(tank)];
						SetEntityHealth(iSelectedType, iNewHealth);
						//SetEntProp(iSelectedType, Prop_Send, "m_iHealth", iNewHealth);
						SetEntProp(iSelectedType, Prop_Send, "m_iMaxHealth", iNewHealth);

						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
						{
							g_iCloneCount2[tank]++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman", g_iCloneCount2[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
						}

						if (g_iCloneMessage[MT_GetTankType(tank)] == 1)
						{
							char sTankName[33];
							MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Clone", sTankName);
						}
					}
				}
			}

			delete hTrace;
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneAmmo");
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
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveClone(iPlayer);

			g_iCloneOwner[iPlayer] = 0;
		}
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[MT_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iAbilityFlags)) ? false : true;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iTypeFlags)) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iGlobalFlags)) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || g_bClone[iTank] || !g_bClone2[iTank])
	{
		g_bClone2[iTank] = false;

		return Plugin_Stop;
	}

	g_bClone2[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "CloneHuman7");

	return Plugin_Continue;
}