/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2021  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if !defined MT_ABILITIES_MAIN2
#error This plugin must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
#endif

#define MT_RESTART_SECTION "restartability"
#define MT_RESTART_SECTION2 "restart ability"
#define MT_RESTART_SECTION3 "restart_ability"
#define MT_RESTART_SECTION4 "restart"
#define MT_RESTART_SECTIONS MT_RESTART_SECTION, MT_RESTART_SECTION2, MT_RESTART_SECTION3, MT_RESTART_SECTION4

#define MT_MENU_RESTART "Restart Ability"

enum struct esRestartGeneral
{
	Handle g_hSDKGetLastKnownArea;

	int g_iFlowOffset;
}

esRestartGeneral g_esRestartGeneral;

enum struct esRestartPlayer
{
	bool g_bCheckpoint;
	bool g_bFailed;
	bool g_bNoAmmo;
	bool g_bRecorded;

	char g_sRestartLoadout[325];

	float g_flOpenAreasOnly;
	float g_flPosition[3];
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
	int g_iTankType;
}

esRestartPlayer g_esRestartPlayer[MAXPLAYERS + 1];

enum struct esRestartAbility
{
	char g_sRestartLoadout[325];

	float g_flOpenAreasOnly;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
}

esRestartAbility g_esRestartAbility[MT_MAXTYPES + 1];

enum struct esRestartCache
{
	char g_sRestartLoadout[325];

	float g_flOpenAreasOnly;
	float g_flRestartChance;
	float g_flRestartRange;
	float g_flRestartRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iRestartAbility;
	int g_iRestartEffect;
	int g_iRestartHit;
	int g_iRestartHitMode;
	int g_iRestartMessage;
	int g_iRestartMode;
}

esRestartCache g_esRestartCache[MAXPLAYERS + 1];

void vRestartPluginStart()
{
	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");
	}

	g_esRestartGeneral.g_iFlowOffset = gdMutantTanks.GetOffset("WitchLocomotion::IsAreaTraversable::m_flow");
	if (g_esRestartGeneral.g_iFlowOffset == -1)
	{
		LogError("%s Failed to load offset: WitchLocomotion::IsAreaTraversable::m_flow", MT_TAG);
	}

	StartPrepSDKCall(SDKCall_Player);
	if (!PrepSDKCall_SetFromConf(gdMutantTanks, SDKConf_Virtual, "CTerrorPlayer::GetLastKnownArea"))
	{
		delete gdMutantTanks;

		SetFailState("Failed to load offset: CTerrorPlayer::GetLastKnownArea");
	}

	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_esRestartGeneral.g_hSDKGetLastKnownArea = EndPrepSDKCall();
	if (g_esRestartGeneral.g_hSDKGetLastKnownArea == null)
	{
		LogError("%s Your \"CTerrorPlayer::GetLastKnownArea\" offsets are outdated.", MT_TAG);
	}

	delete gdMutantTanks;
}

void vRestartMapStart()
{
	vRestartReset();
}

void vRestartClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnRestartTakeDamage);
	vRemoveRestart(client);
}

void vRestartClientDisconnect_Post(int client)
{
	vRemoveRestart(client);
}

void vRestartMapEnd()
{
	vRestartReset();
}

void vRestartMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_RESTART_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iRestartMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Restart Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRestartMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esRestartCache[param1].g_iRestartAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esRestartCache[param1].g_iHumanAmmo - g_esRestartPlayer[param1].g_iAmmoCount, g_esRestartCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esRestartCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RestartDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esRestartCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vRestartMenu(param1, MT_RESTART_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pRestart = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "RestartMenu", param1);
			pRestart.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

void vRestartDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_RESTART, MT_MENU_RESTART);
}

void vRestartMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_RESTART, false))
	{
		vRestartMenu(client, MT_RESTART_SECTION4, 0);
	}
}

void vRestartMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_RESTART, false))
	{
		FormatEx(buffer, size, "%T", "RestartMenu2", client);
	}
}

public Action OnRestartTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esRestartCache[attacker].g_iRestartHitMode == 0 || g_esRestartCache[attacker].g_iRestartHitMode == 1) && bIsSurvivor(victim) && g_esRestartCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esRestartAbility[g_esRestartPlayer[attacker].g_iTankType].g_iAccessFlags, g_esRestartPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esRestartPlayer[attacker].g_iTankType, g_esRestartAbility[g_esRestartPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esRestartPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esRestartCache[attacker].g_flRestartChance, g_esRestartCache[attacker].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esRestartCache[victim].g_iRestartHitMode == 0 || g_esRestartCache[victim].g_iRestartHitMode == 2) && bIsSurvivor(attacker) && g_esRestartCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esRestartAbility[g_esRestartPlayer[victim].g_iTankType].g_iAccessFlags, g_esRestartPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esRestartPlayer[victim].g_iTankType, g_esRestartAbility[g_esRestartPlayer[victim].g_iTankType].g_iImmunityFlags, g_esRestartPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRestartHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esRestartCache[victim].g_flRestartChance, g_esRestartCache[victim].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

void vRestartPluginCheck(ArrayList &list)
{
	list.PushString(MT_MENU_RESTART);
}

void vRestartAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString(MT_RESTART_SECTION);
	list2.PushString(MT_RESTART_SECTION2);
	list3.PushString(MT_RESTART_SECTION3);
	list4.PushString(MT_RESTART_SECTION4);
}

void vRestartCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_RESTART_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_RESTART_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_RESTART_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_RESTART_SECTION4);
	if (g_esRestartCache[tank].g_iComboAbility == 1 && (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1))
	{
		static char sSubset[10][32];
		ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
		for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_RESTART_SECTION, false) || StrEqual(sSubset[iPos], MT_RESTART_SECTION2, false) || StrEqual(sSubset[iPos], MT_RESTART_SECTION3, false) || StrEqual(sSubset[iPos], MT_RESTART_SECTION4, false))
			{
				static float flDelay;
				flDelay = MT_GetCombinationSetting(tank, 3, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esRestartCache[tank].g_iRestartAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vRestartAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerRestartCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						static float flChance;
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esRestartCache[tank].g_iRestartHitMode == 0 || g_esRestartCache[tank].g_iRestartHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vRestartHit(survivor, tank, random, flChance, g_esRestartCache[tank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esRestartCache[tank].g_iRestartHitMode == 0 || g_esRestartCache[tank].g_iRestartHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vRestartHit(survivor, tank, random, flChance, g_esRestartCache[tank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerRestartCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteString(classname);
							}
						}
					}
				}

				break;
			}
		}
	}
}

void vRestartConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esRestartAbility[iIndex].g_iAccessFlags = 0;
				g_esRestartAbility[iIndex].g_iImmunityFlags = 0;
				g_esRestartAbility[iIndex].g_iComboAbility = 0;
				g_esRestartAbility[iIndex].g_iHumanAbility = 0;
				g_esRestartAbility[iIndex].g_iHumanAmmo = 5;
				g_esRestartAbility[iIndex].g_iHumanCooldown = 30;
				g_esRestartAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esRestartAbility[iIndex].g_iRequiresHumans = 0;
				g_esRestartAbility[iIndex].g_iRestartAbility = 0;
				g_esRestartAbility[iIndex].g_iRestartEffect = 0;
				g_esRestartAbility[iIndex].g_iRestartMessage = 0;
				g_esRestartAbility[iIndex].g_flRestartChance = 33.3;
				g_esRestartAbility[iIndex].g_iRestartHit = 0;
				g_esRestartAbility[iIndex].g_iRestartHitMode = 0;
				g_esRestartAbility[iIndex].g_sRestartLoadout = "smg,pistol,pain_pills";
				g_esRestartAbility[iIndex].g_iRestartMode = 1;
				g_esRestartAbility[iIndex].g_flRestartRange = 150.0;
				g_esRestartAbility[iIndex].g_flRestartRangeChance = 15.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esRestartPlayer[iPlayer].g_iAccessFlags = 0;
					g_esRestartPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esRestartPlayer[iPlayer].g_iComboAbility = 0;
					g_esRestartPlayer[iPlayer].g_iHumanAbility = 0;
					g_esRestartPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esRestartPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esRestartPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esRestartPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esRestartPlayer[iPlayer].g_iRestartAbility = 0;
					g_esRestartPlayer[iPlayer].g_iRestartEffect = 0;
					g_esRestartPlayer[iPlayer].g_iRestartMessage = 0;
					g_esRestartPlayer[iPlayer].g_flRestartChance = 0.0;
					g_esRestartPlayer[iPlayer].g_iRestartHit = 0;
					g_esRestartPlayer[iPlayer].g_iRestartHitMode = 0;
					g_esRestartPlayer[iPlayer].g_sRestartLoadout[0] = '\0';
					g_esRestartPlayer[iPlayer].g_iRestartMode = 0;
					g_esRestartPlayer[iPlayer].g_flRestartRange = 0.0;
					g_esRestartPlayer[iPlayer].g_flRestartRangeChance = 0.0;
				}
			}
		}
	}
}

void vRestartConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esRestartPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRestartPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esRestartPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRestartPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esRestartPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRestartPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esRestartPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRestartPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esRestartPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRestartPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esRestartPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRestartPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esRestartPlayer[admin].g_iRestartAbility = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRestartPlayer[admin].g_iRestartAbility, value, 0, 1);
		g_esRestartPlayer[admin].g_iRestartEffect = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRestartPlayer[admin].g_iRestartEffect, value, 0, 7);
		g_esRestartPlayer[admin].g_iRestartMessage = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRestartPlayer[admin].g_iRestartMessage, value, 0, 3);
		g_esRestartPlayer[admin].g_flRestartChance = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esRestartPlayer[admin].g_flRestartChance, value, 0.0, 100.0);
		g_esRestartPlayer[admin].g_iRestartHit = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esRestartPlayer[admin].g_iRestartHit, value, 0, 1);
		g_esRestartPlayer[admin].g_iRestartHitMode = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esRestartPlayer[admin].g_iRestartHitMode, value, 0, 2);
		g_esRestartPlayer[admin].g_iRestartMode = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esRestartPlayer[admin].g_iRestartMode, value, 0, 1);
		g_esRestartPlayer[admin].g_flRestartRange = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esRestartPlayer[admin].g_flRestartRange, value, 1.0, 999999.0);
		g_esRestartPlayer[admin].g_flRestartRangeChance = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esRestartPlayer[admin].g_flRestartRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_RESTART_SECTION, false) || StrEqual(subsection, MT_RESTART_SECTION2, false) || StrEqual(subsection, MT_RESTART_SECTION3, false) || StrEqual(subsection, MT_RESTART_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esRestartPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esRestartPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RestartLoadout", false) || StrEqual(key, "Restart Loadout", false) || StrEqual(key, "Restart_Loadout", false) || StrEqual(key, "loadout", false))
			{
				strcopy(g_esRestartPlayer[admin].g_sRestartLoadout, sizeof(esRestartAbility::g_sRestartLoadout), value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esRestartAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esRestartAbility[type].g_iComboAbility, value, 0, 1);
		g_esRestartAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRestartAbility[type].g_iHumanAbility, value, 0, 2);
		g_esRestartAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRestartAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esRestartAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRestartAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esRestartAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRestartAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esRestartAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRestartAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esRestartAbility[type].g_iRestartAbility = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRestartAbility[type].g_iRestartAbility, value, 0, 1);
		g_esRestartAbility[type].g_iRestartEffect = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esRestartAbility[type].g_iRestartEffect, value, 0, 7);
		g_esRestartAbility[type].g_iRestartMessage = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRestartAbility[type].g_iRestartMessage, value, 0, 3);
		g_esRestartAbility[type].g_flRestartChance = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartChance", "Restart Chance", "Restart_Chance", "chance", g_esRestartAbility[type].g_flRestartChance, value, 0.0, 100.0);
		g_esRestartAbility[type].g_iRestartHit = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartHit", "Restart Hit", "Restart_Hit", "hit", g_esRestartAbility[type].g_iRestartHit, value, 0, 1);
		g_esRestartAbility[type].g_iRestartHitMode = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartHitMode", "Restart Hit Mode", "Restart_Hit_Mode", "hitmode", g_esRestartAbility[type].g_iRestartHitMode, value, 0, 2);
		g_esRestartAbility[type].g_iRestartMode = iGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartMode", "Restart Mode", "Restart_Mode", "mode", g_esRestartAbility[type].g_iRestartMode, value, 0, 1);
		g_esRestartAbility[type].g_flRestartRange = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartRange", "Restart Range", "Restart_Range", "range", g_esRestartAbility[type].g_flRestartRange, value, 1.0, 999999.0);
		g_esRestartAbility[type].g_flRestartRangeChance = flGetKeyValue(subsection, MT_RESTART_SECTIONS, key, "RestartRangeChance", "Restart Range Chance", "Restart_Range_Chance", "rangechance", g_esRestartAbility[type].g_flRestartRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_RESTART_SECTION, false) || StrEqual(subsection, MT_RESTART_SECTION2, false) || StrEqual(subsection, MT_RESTART_SECTION3, false) || StrEqual(subsection, MT_RESTART_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esRestartAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esRestartAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RestartLoadout", false) || StrEqual(key, "Restart Loadout", false) || StrEqual(key, "Restart_Loadout", false) || StrEqual(key, "loadout", false))
			{
				strcopy(g_esRestartAbility[type].g_sRestartLoadout, sizeof(esRestartAbility::g_sRestartLoadout), value);
			}
		}
	}
}

void vRestartSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	vGetSettingValue(apply, bHuman, g_esRestartCache[tank].g_sRestartLoadout, sizeof(esRestartCache::g_sRestartLoadout), g_esRestartPlayer[tank].g_sRestartLoadout, g_esRestartAbility[type].g_sRestartLoadout);
	g_esRestartCache[tank].g_flRestartChance = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flRestartChance, g_esRestartAbility[type].g_flRestartChance);
	g_esRestartCache[tank].g_flRestartRange = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flRestartRange, g_esRestartAbility[type].g_flRestartRange);
	g_esRestartCache[tank].g_flRestartRangeChance = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flRestartRangeChance, g_esRestartAbility[type].g_flRestartRangeChance);
	g_esRestartCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iComboAbility, g_esRestartAbility[type].g_iComboAbility);
	g_esRestartCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iHumanAbility, g_esRestartAbility[type].g_iHumanAbility);
	g_esRestartCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iHumanAmmo, g_esRestartAbility[type].g_iHumanAmmo);
	g_esRestartCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iHumanCooldown, g_esRestartAbility[type].g_iHumanCooldown);
	g_esRestartCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_flOpenAreasOnly, g_esRestartAbility[type].g_flOpenAreasOnly);
	g_esRestartCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRequiresHumans, g_esRestartAbility[type].g_iRequiresHumans);
	g_esRestartCache[tank].g_iRestartAbility = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartAbility, g_esRestartAbility[type].g_iRestartAbility);
	g_esRestartCache[tank].g_iRestartEffect = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartEffect, g_esRestartAbility[type].g_iRestartEffect);
	g_esRestartCache[tank].g_iRestartHit = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartHit, g_esRestartAbility[type].g_iRestartHit);
	g_esRestartCache[tank].g_iRestartHitMode = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartHitMode, g_esRestartAbility[type].g_iRestartHitMode);
	g_esRestartCache[tank].g_iRestartMessage = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartMessage, g_esRestartAbility[type].g_iRestartMessage);
	g_esRestartCache[tank].g_iRestartMode = iGetSettingValue(apply, bHuman, g_esRestartPlayer[tank].g_iRestartMode, g_esRestartAbility[type].g_iRestartMode);
	g_esRestartPlayer[tank].g_iTankType = apply ? type : 0;
}

void vRestartCopyStats(int oldTank, int newTank)
{
	vRestartCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveRestart(oldTank);
	}
}

void vRestartHookEvent(bool hooked)
{
	switch (hooked)
	{
		case true:
		{
			HookEvent("player_entered_checkpoint", MT_OnEventFired);
			HookEvent("player_left_checkpoint", MT_OnEventFired);

			if (!g_bSecondGame)
			{
				HookEvent("player_entered_start_area", MT_OnEventFired);
			}
		}
		case false:
		{
			UnhookEvent("player_entered_checkpoint", MT_OnEventFired);
			UnhookEvent("player_left_checkpoint", MT_OnEventFired);

			if (!g_bSecondGame)
			{
				UnhookEvent("player_entered_start_area", MT_OnEventFired);
			}
		}
	}
}

void vRestartEventFired(Event event, const char[] name)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vRestartCopyStats2(iBot, iTank);
			vRemoveRestart(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vRestartCopyStats2(iTank, iBot);
			vRemoveRestart(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRestart(iTank);
		}
	}
	else if (StrEqual(name, "player_spawn"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRestart(iPlayer);
		}
		else if (bIsSurvivor(iPlayer) && !g_esRestartPlayer[iPlayer].g_bRecorded && bIsSurvivorInCheckpoint(iPlayer, true))
		{
			g_esRestartPlayer[iPlayer].g_bRecorded = true;

			GetClientAbsOrigin(iPlayer, g_esRestartPlayer[iPlayer].g_flPosition);
		}
	}
	else if (StrEqual(name, "player_left_checkpoint"))
	{
		g_esRestartPlayer[GetClientOfUserId(event.GetInt("userid"))].g_bCheckpoint = false;
	}
	else if (StrEqual(name, "player_entered_checkpoint") || StrEqual(name, "player_entered_start_area"))
	{
		g_esRestartPlayer[GetClientOfUserId(event.GetInt("userid"))].g_bCheckpoint = true;
	}
	else if (StrEqual(name, "mission_lost"))
	{
		vRestartReset();
	}
	else if (StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vRestartReset();

		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++ )
		{
			switch (bIsSurvivor(iPlayer, MT_CHECK_INGAME))
			{
				case true: g_esRestartPlayer[iPlayer].g_bCheckpoint = true;
				case false: g_esRestartPlayer[iPlayer].g_bCheckpoint = false;
			}
		}
	}
}

void vRestartAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankType].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)) || g_esRestartCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esRestartCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esRestartCache[tank].g_iRestartAbility == 1 && g_esRestartCache[tank].g_iComboAbility == 0)
	{
		vRestartAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

void vRestartButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esRestartCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esRestartPlayer[tank].g_iTankType) || (g_esRestartCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRestartCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankType].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esRestartCache[tank].g_iRestartAbility == 1 && g_esRestartCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esRestartPlayer[tank].g_iCooldown != -1 && g_esRestartPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman3", g_esRestartPlayer[tank].g_iCooldown - iTime);
					case false: vRestartAbility(tank, GetRandomFloat(0.1, 100.0));
				}
			}
		}
	}
}

void vRestartChangeType(int tank)
{
	vRemoveRestart(tank);
}

void vRestartCopyStats2(int oldTank, int newTank)
{
	g_esRestartPlayer[newTank].g_iAmmoCount = g_esRestartPlayer[oldTank].g_iAmmoCount;
	g_esRestartPlayer[newTank].g_iCooldown = g_esRestartPlayer[oldTank].g_iCooldown;
}

void vRemoveRestart(int tank)
{
	g_esRestartPlayer[tank].g_bFailed = false;
	g_esRestartPlayer[tank].g_bNoAmmo = false;
	g_esRestartPlayer[tank].g_bRecorded = false;
	g_esRestartPlayer[tank].g_iAmmoCount = 0;
	g_esRestartPlayer[tank].g_iCooldown = -1;
}

void vRestartReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveRestart(iPlayer);
		}
	}
}

void vRestartAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esRestartCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esRestartPlayer[tank].g_iTankType) || (g_esRestartCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRestartCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankType].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esRestartPlayer[tank].g_iAmmoCount < g_esRestartCache[tank].g_iHumanAmmo && g_esRestartCache[tank].g_iHumanAmmo > 0))
	{
		g_esRestartPlayer[tank].g_bFailed = false;
		g_esRestartPlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3], flSurvivorPos[3], flRange, flChance;
		GetClientAbsOrigin(tank, flTankPos);
		flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esRestartCache[tank].g_flRestartRange;
		flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esRestartCache[tank].g_flRestartRangeChance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esRestartPlayer[tank].g_iTankType, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankType].g_iImmunityFlags, g_esRestartPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
				{
					vRestartHit(iSurvivor, tank, random, flChance, g_esRestartCache[tank].g_iRestartAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman4");
			}
		}
	}
	else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
	}
}

void vRestartHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esRestartCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esRestartPlayer[tank].g_iTankType) || (g_esRestartCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRestartCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankType].g_iAccessFlags, g_esRestartPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esRestartPlayer[tank].g_iTankType, g_esRestartAbility[g_esRestartPlayer[tank].g_iTankType].g_iImmunityFlags, g_esRestartPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esRestartPlayer[tank].g_iAmmoCount < g_esRestartCache[tank].g_iHumanAmmo && g_esRestartCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance)
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esRestartPlayer[tank].g_iCooldown == -1 || g_esRestartPlayer[tank].g_iCooldown < iTime))
				{
					g_esRestartPlayer[tank].g_iAmmoCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman", g_esRestartPlayer[tank].g_iAmmoCount, g_esRestartCache[tank].g_iHumanAmmo);

					g_esRestartPlayer[tank].g_iCooldown = (g_esRestartPlayer[tank].g_iAmmoCount < g_esRestartCache[tank].g_iHumanAmmo && g_esRestartCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esRestartCache[tank].g_iHumanCooldown) : -1;
					if (g_esRestartPlayer[tank].g_iCooldown != -1 && g_esRestartPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman5", g_esRestartPlayer[tank].g_iCooldown - iTime);
					}
				}

				static char sItems[5][64];
				ReplaceString(g_esRestartCache[tank].g_sRestartLoadout, sizeof(esRestartAbility::g_sRestartLoadout), " ", "");
				ExplodeString(g_esRestartCache[tank].g_sRestartLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));
				MT_RespawnSurvivor(survivor);
				vRemoveWeapons(survivor);

				for (int iItem = 0; iItem < sizeof(sItems); iItem++)
				{
					if (StrContains(g_esRestartCache[tank].g_sRestartLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
					{
						vCheatCommand(survivor, "give", sItems[iItem]);
					}
				}

				static bool bTeleport;
				bTeleport = true;
				if (g_esRestartPlayer[survivor].g_bRecorded && g_esRestartCache[tank].g_iRestartMode == 0)
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esRestartPlayer[iSurvivor].g_bRecorded)
						{
							bTeleport = false;

							TeleportEntity(survivor, g_esRestartPlayer[iSurvivor].g_flPosition, NULL_VECTOR, NULL_VECTOR);

							break;
						}
					}

					if (bTeleport)
					{
						TeleportEntity(survivor, g_esRestartPlayer[survivor].g_flPosition, NULL_VECTOR, NULL_VECTOR);
					}
				}
				else
				{
					static float flOrigin[3], flAngles[3];
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsSurvivorDisabled(iSurvivor) && iSurvivor != survivor)
						{
							bTeleport = false;

							GetClientAbsOrigin(iSurvivor, flOrigin);
							GetClientEyeAngles(iSurvivor, flAngles);
							TeleportEntity(survivor, flOrigin, flAngles, NULL_VECTOR);

							break;
						}
					}

					if (bTeleport)
					{
						TeleportEntity(survivor, g_esRestartPlayer[survivor].g_flPosition, NULL_VECTOR, NULL_VECTOR);
					}
				}

				vEffect(survivor, tank, g_esRestartCache[tank].g_iRestartEffect, flags);

				if (g_esRestartCache[tank].g_iRestartMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Restart", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Restart", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esRestartPlayer[tank].g_iCooldown == -1 || g_esRestartPlayer[tank].g_iCooldown < iTime))
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1 && !g_esRestartPlayer[tank].g_bFailed)
				{
					g_esRestartPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartHuman2");
				}
			}
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esRestartCache[tank].g_iHumanAbility == 1 && !g_esRestartPlayer[tank].g_bNoAmmo)
		{
			g_esRestartPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RestartAmmo");
		}
	}
}

bool bIsSurvivorInCheckpoint(int survivor, bool start)
{
	if (g_bLeft4DHooksInstalled || g_esRestartGeneral.g_hSDKGetLastKnownArea == null)
	{
		return start ? (L4D_IsInFirstCheckpoint(survivor) || GetEntProp(survivor, Prop_Send, "m_isInMissionStartArea") == 1) : L4D_IsInLastCheckpoint(survivor);
	}

	bool bReturn = false;
	if (g_esRestartPlayer[survivor].g_bCheckpoint && g_esRestartGeneral.g_iFlowOffset != -1)
	{
		int iArea = SDKCall(g_esRestartGeneral.g_hSDKGetLastKnownArea, survivor);
		if (iArea)
		{
			float flFlow = view_as<float>(LoadFromAddress(view_as<Address>(iArea + g_esRestartGeneral.g_iFlowOffset), NumberType_Int32));
			bReturn = start ? (flFlow < 3000.0) : (flFlow > 3000.0);
		}
	}

	bool bReturn2 = start ? (GetEntProp(survivor, Prop_Send, "m_isInMissionStartArea") == 1) : false;
	return bReturn || bReturn2;
}

public Action tTimerRestartCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRestartAbility[g_esRestartPlayer[iTank].g_iTankType].g_iAccessFlags, g_esRestartPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRestartPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esRestartCache[iTank].g_iRestartAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vRestartAbility(iTank, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerRestartCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esRestartAbility[g_esRestartPlayer[iTank].g_iTankType].g_iAccessFlags, g_esRestartPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRestartPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esRestartCache[iTank].g_iRestartHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esRestartCache[iTank].g_iRestartHitMode == 0 || g_esRestartCache[iTank].g_iRestartHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vRestartHit(iSurvivor, iTank, flRandom, flChance, g_esRestartCache[iTank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esRestartCache[iTank].g_iRestartHitMode == 0 || g_esRestartCache[iTank].g_iRestartHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vRestartHit(iSurvivor, iTank, flRandom, flChance, g_esRestartCache[iTank].g_iRestartHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}