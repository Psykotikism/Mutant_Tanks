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
	name = "[ST++] Shield Ability",
	author = ST_AUTHOR,
	description = "The Super Tank protects itself with a shield and throws propane tanks or gas cans.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"

#define ST_MENU_SHIELD "Shield Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bShield[MAXPLAYERS + 1], g_bShield2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

ConVar g_cvSTTankThrowForce;

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flHumanDuration2[ST_MAXTYPES + 1], g_flShieldChance[ST_MAXTYPES + 1], g_flShieldChance2[ST_MAXTYPES + 1], g_flShieldDelay[ST_MAXTYPES + 1], g_flShieldDelay2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iShield[MAXPLAYERS + 1], g_iShieldAbility[ST_MAXTYPES + 1], g_iShieldAbility2[ST_MAXTYPES + 1], g_iShieldCount[MAXPLAYERS + 1], g_iShieldMessage[ST_MAXTYPES + 1], g_iShieldMessage2[ST_MAXTYPES + 1], g_iShieldType[ST_MAXTYPES + 1], g_iShieldType2[ST_MAXTYPES + 1], g_iShieldRed[ST_MAXTYPES + 1], g_iShieldRed2[ST_MAXTYPES + 1], g_iShieldGreen[ST_MAXTYPES + 1], g_iShieldGreen2[ST_MAXTYPES + 1], g_iShieldBlue[ST_MAXTYPES + 1], g_iShieldBlue2[ST_MAXTYPES + 1], g_iShieldAlpha[ST_MAXTYPES + 1], g_iShieldAlpha2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Shield Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

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
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_shield", cmdShieldInfo, "View information about the Shield ability.");

	g_cvSTTankThrowForce = FindConVar("z_tank_throw_force");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, "24"))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_SHIELD, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdShieldInfo(int client, int args)
{
	if (!ST_IsCorePluginEnabled())
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
		case false: vShieldMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vShieldMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iShieldMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shield Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iShieldMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iShieldAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iShieldCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ShieldDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHumanDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vShieldMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ShieldMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 7:
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
	menu.AddItem(ST_MENU_SHIELD, ST_MENU_SHIELD);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SHIELD, false))
	{
		vShieldMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (g_bShield[victim])
			{
				switch (iShieldType(victim))
				{
					case 0:
					{
						if (damagetype & DMG_BULLET)
						{
							vShieldAbility(victim, false);
						}
						else
						{
							return Plugin_Handled;
						}
					}
					case 1:
					{
						if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
						{
							vShieldAbility(victim, false);
						}
						else
						{
							return Plugin_Handled;
						}
					}
					case 2:
					{
						if (damagetype & DMG_BURN)
						{
							vShieldAbility(victim, false);
						}
						else
						{
							return Plugin_Handled;
						}
					}
					case 3:
					{
						if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
						{
							vShieldAbility(victim, false);
						}
						else
						{
							return Plugin_Handled;
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Shield Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Shield Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Human Duration", 5.0);
					g_flHumanDuration[iIndex] = flClamp(g_flHumanDuration[iIndex], 0.1, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Shield Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iShieldAbility[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Enabled", 0);
					g_iShieldAbility[iIndex] = iClamp(g_iShieldAbility[iIndex], 0, 1);
					g_iShieldMessage[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Message", 0);
					g_iShieldMessage[iIndex] = iClamp(g_iShieldMessage[iIndex], 0, 1);
					kvSuperTanks.GetColor("Shield Ability/Shield Color", g_iShieldRed[iIndex], g_iShieldGreen[iIndex], g_iShieldBlue[iIndex], g_iShieldAlpha[iIndex]);
					g_flShieldChance[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Chance", 33.3);
					g_flShieldChance[iIndex] = flClamp(g_flShieldChance[iIndex], 0.0, 100.0);
					g_flShieldDelay[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Delay", 5.0);
					g_flShieldDelay[iIndex] = flClamp(g_flShieldDelay[iIndex], 0.1, 9999999999.0);
					g_iShieldType[iIndex] = kvSuperTanks.GetNum("Shield Ability/Shield Types", 1);
					g_iShieldType[iIndex] = iClamp(g_iShieldType[iIndex], 0, 3);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration2[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Human Duration", g_flHumanDuration[iIndex]);
					g_flHumanDuration2[iIndex] = flClamp(g_flHumanDuration2[iIndex], 0.1, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iShieldAbility2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Enabled", g_iShieldAbility[iIndex]);
					g_iShieldAbility2[iIndex] = iClamp(g_iShieldAbility2[iIndex], 0, 1);
					g_iShieldMessage2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Message", g_iShieldMessage[iIndex]);
					g_iShieldMessage2[iIndex] = iClamp(g_iShieldMessage2[iIndex], 0, 1);
					kvSuperTanks.GetColor("Shield Ability/Shield Color", g_iShieldRed2[iIndex], g_iShieldGreen2[iIndex], g_iShieldBlue2[iIndex], g_iShieldAlpha2[iIndex]);
					g_flShieldChance2[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Chance", g_flShieldChance[iIndex]);
					g_flShieldChance2[iIndex] = flClamp(g_flShieldChance2[iIndex], 0.0, 100.0);
					g_flShieldDelay2[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Delay", g_flShieldDelay[iIndex]);
					g_flShieldDelay2[iIndex] = flClamp(g_flShieldDelay2[iIndex], 0.1, 9999999999.0);
					g_iShieldType2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Shield Types", g_iShieldType[iIndex]);
					g_iShieldType2[iIndex] = iClamp(g_iShieldType2[iIndex], 0, 3);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234") && g_bShield[iTank])
		{
			vRemoveShield(iTank);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemoveShield(iTank);

			vReset2(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iShieldAbility(tank) == 1 && !g_bShield[tank] && !g_bShield2[tank])
	{
		vShieldAbility(tank, true);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iShieldAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bShield[tank] && !g_bShield2[tank])
						{
							vShieldAbility(tank, true);
						}
						else if (g_bShield[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldHuman3");
						}
						else if (g_bShield2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldHuman4");
						}
					}
					case 1:
					{
						if (g_iShieldCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bShield[tank] && !g_bShield2[tank])
							{
								g_bShield[tank] = true;
								g_iShieldCount[tank]++;

								g_iShield[tank] = CreateEntityByName("prop_dynamic");
								if (bIsValidEntity(g_iShield[tank]))
								{
									vShield(tank);
								}

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldHuman", g_iShieldCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldAmmo");
						}
					}
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iShieldAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bShield[tank] && !g_bShield2[tank])
				{
					vRemoveShield(tank);

					g_bShield[tank] = false;

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	if (ST_IsTankSupported(tank) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		vRemoveShield(tank);

		vReset2(tank);
	}
}

public void ST_OnRockThrow(int tank, int rock)
{
	if (ST_IsTankSupported(tank) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iShieldAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flShieldChance(tank))
	{
		DataPack dpShieldThrow;
		CreateDataTimer(0.1, tTimerShieldThrow, dpShieldThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShieldThrow.WriteCell(EntIndexToEntRef(rock));
		dpShieldThrow.WriteCell(GetClientUserId(tank));
	}
}

static void vRemoveShield(int tank)
{
	if (bIsValidEntity(g_iShield[tank]))
	{
		ST_HideEntity(g_iShield[tank], false);
		RemoveEntity(g_iShield[tank]);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset2(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bShield[tank] = false;
	g_bShield2[tank] = false;
	g_iShield[tank] = 0;
	g_iShieldCount[tank] = 0;
}

static void vReset3(int tank)
{
	if (!g_bShield2[tank])
	{
		g_bShield2[tank] = true;

		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldHuman5");

		if (g_iShieldCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bShield2[tank] = false;
		}
	}
}

static void vShield(int tank)
{
	float flOrigin[3];
	GetClientAbsOrigin(tank, flOrigin);
	flOrigin[2] -= 120.0;

	SetEntityModel(g_iShield[tank], MODEL_SHIELD);

	DispatchKeyValueVector(g_iShield[tank], "origin", flOrigin);
	DispatchSpawn(g_iShield[tank]);
	vSetEntityParent(g_iShield[tank], tank);

	int iShieldRed = !g_bTankConfig[ST_GetTankType(tank)] ? g_iShieldRed[ST_GetTankType(tank)] : g_iShieldRed2[ST_GetTankType(tank)],
		iShieldGreen = !g_bTankConfig[ST_GetTankType(tank)] ? g_iShieldGreen[ST_GetTankType(tank)] : g_iShieldGreen2[ST_GetTankType(tank)],
		iShieldBlue = !g_bTankConfig[ST_GetTankType(tank)] ? g_iShieldBlue[ST_GetTankType(tank)] : g_iShieldBlue2[ST_GetTankType(tank)],
		iShieldAlpha = !g_bTankConfig[ST_GetTankType(tank)] ? g_iShieldAlpha[ST_GetTankType(tank)] : g_iShieldAlpha2[ST_GetTankType(tank)];
	SetEntityRenderMode(g_iShield[tank], RENDER_TRANSTEXTURE);
	SetEntityRenderColor(g_iShield[tank], iShieldRed, iShieldGreen, iShieldBlue, iShieldAlpha);

	SetEntProp(g_iShield[tank], Prop_Send, "m_CollisionGroup", 1);
	SetEntPropEnt(g_iShield[tank], Prop_Send, "m_hOwnerEntity", tank);

	ST_HideEntity(g_iShield[tank], true);
}

static void vShieldAbility(int tank, bool shield)
{
	switch (shield)
	{
		case true:
		{
			if (g_iShieldCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
			{
				if (GetRandomFloat(0.1, 100.0) <= flShieldChance(tank))
				{
					g_iShield[tank] = CreateEntityByName("prop_dynamic");
					if (bIsValidEntity(g_iShield[tank]))
					{
						vShield(tank);

						g_bShield[tank] = true;

						ExtinguishEntity(tank);

						if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
						{
							g_iShieldCount[tank]++;

							DataPack dpStopShield;
							CreateDataTimer(flHumanDuration(tank), tTimerStopShield, dpStopShield, TIMER_FLAG_NO_MAPCHANGE);
							dpStopShield.WriteCell(EntIndexToEntRef(g_iShield[tank]));
							dpStopShield.WriteCell(GetClientUserId(tank));

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldHuman", g_iShieldCount[tank], iHumanAmmo(tank));
						}

						if (iShieldMessage(tank) == 1)
						{
							char sTankName[33];
							ST_GetTankName(tank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Shield", sTankName);
						}
					}
				}
				else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldHuman2");
				}
			}
			else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShieldAmmo");
			}
		}
		case false:
		{
			vRemoveShield(tank);

			g_bShield[tank] = false;

			switch (ST_IsTankSupported(tank, "02345"))
			{
				case true: vReset3(tank);
				case false:
				{
					if (!g_bShield2[tank])
					{
						g_bShield2[tank] = true;

						float flShieldDelay = !g_bTankConfig[ST_GetTankType(tank)] ? g_flShieldDelay[ST_GetTankType(tank)] : g_flShieldDelay2[ST_GetTankType(tank)];
						CreateTimer(flShieldDelay, tTimerShield, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}

			if (iShieldMessage(tank) == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Shield2", sTankName);
			}
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flHumanDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanDuration[ST_GetTankType(tank)] : g_flHumanDuration2[ST_GetTankType(tank)];
}

static float flShieldChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flShieldChance[ST_GetTankType(tank)] : g_flShieldChance2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanMode[ST_GetTankType(tank)] : g_iHumanMode2[ST_GetTankType(tank)];
}

static int iShieldAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShieldAbility[ST_GetTankType(tank)] : g_iShieldAbility2[ST_GetTankType(tank)];
}

static int iShieldMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShieldMessage[ST_GetTankType(tank)] : g_iShieldMessage2[ST_GetTankType(tank)];
}

static int iShieldType(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShieldType[ST_GetTankType(tank)] : g_iShieldType2[ST_GetTankType(tank)];
}

public Action tTimerShield(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iShieldAbility(iTank) == 0 || !g_bShield2[iTank])
	{
		g_bShield2[iTank] = false;

		return Plugin_Stop;
	}

	g_bShield2[iTank] = false;

	vShieldAbility(iTank, true);

	return Plugin_Continue;
}

public Action tTimerShieldThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iShieldAbility(iTank) == 0 || !g_bShield[iTank])
	{
		return Plugin_Stop;
	}

	if (iShieldType(iTank) != 1 && iShieldType(iTank) != 2)
	{
		return Plugin_Stop;
	}

	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);

	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		int iThrowable = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iThrowable))
		{
			switch (iShieldType(iTank))
			{
				case 1: SetEntityModel(iThrowable, MODEL_PROPANETANK);
				case 2: SetEntityModel(iThrowable, MODEL_GASCAN);
			}

			float flPos[3];
			GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
			RemoveEntity(iRock);

			NormalizeVector(flVelocity, flVelocity);
			ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);

			DispatchSpawn(iThrowable);
			TeleportEntity(iThrowable, flPos, NULL_VECTOR, flVelocity);
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerStopShield(Handle timer, DataPack pack)
{
	pack.Reset();

	int iShield = EntRefToEntIndex(pack.ReadCell());
	if (iShield == INVALID_ENT_REFERENCE || !bIsValidEntity(iShield))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bShield[iTank])
	{
		vShieldAbility(iTank, false);

		return Plugin_Stop;
	}

	vShieldAbility(iTank, false);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bShield2[iTank])
	{
		g_bShield2[iTank] = false;

		return Plugin_Stop;
	}

	g_bShield2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShieldHuman6");

	return Plugin_Continue;
}