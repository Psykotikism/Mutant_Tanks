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

#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"

#define MT_SMITE_SECTION "smiteability"
#define MT_SMITE_SECTION2 "smite ability"
#define MT_SMITE_SECTION3 "smite_ability"
#define MT_SMITE_SECTION4 "smite"
#define MT_SMITE_SECTIONS MT_SMITE_SECTION, MT_SMITE_SECTION2, MT_SMITE_SECTION3, MT_SMITE_SECTION4

#define MT_MENU_SMITE "Smite Ability"

enum struct esSmitePlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flOpenAreasOnly;
	float g_flSmiteChance;
	float g_flSmiteRange;
	float g_flSmiteRangeChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSmiteAbility;
	int g_iSmiteBody;
	int g_iSmiteEffect;
	int g_iSmiteHit;
	int g_iSmiteHitMode;
	int g_iSmiteMessage;
	int g_iTankType;
}

esSmitePlayer g_esSmitePlayer[MAXPLAYERS + 1];

enum struct esSmiteAbility
{
	float g_flOpenAreasOnly;
	float g_flSmiteChance;
	float g_flSmiteRange;
	float g_flSmiteRangeChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iSmiteAbility;
	int g_iSmiteBody;
	int g_iSmiteEffect;
	int g_iSmiteHit;
	int g_iSmiteHitMode;
	int g_iSmiteMessage;
}

esSmiteAbility g_esSmiteAbility[MT_MAXTYPES + 1];

enum struct esSmiteCache
{
	float g_flOpenAreasOnly;
	float g_flSmiteChance;
	float g_flSmiteRange;
	float g_flSmiteRangeChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iSmiteAbility;
	int g_iSmiteBody;
	int g_iSmiteEffect;
	int g_iSmiteHit;
	int g_iSmiteHitMode;
	int g_iSmiteMessage;
}

esSmiteCache g_esSmiteCache[MAXPLAYERS + 1];

int g_iSmiteSprite = -1;

void vSmiteMapStart()
{
	g_iSmiteSprite = PrecacheModel("sprites/glow.vmt", true);

	PrecacheSound(SOUND_EXPLOSION, true);

	vSmiteReset();
}

void vSmiteClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnSmiteTakeDamage);
	vRemoveSmite(client);
}

void vSmiteClientDisconnect_Post(int client)
{
	vRemoveSmite(client);
}

void vSmiteMapEnd()
{
	vSmiteReset();
}

void vSmiteMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_SMITE_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iSmiteMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Smite Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iSmiteMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esSmiteCache[param1].g_iSmiteAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esSmiteCache[param1].g_iHumanAmmo - g_esSmitePlayer[param1].g_iAmmoCount, g_esSmiteCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esSmiteCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "SmiteDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esSmiteCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vSmiteMenu(param1, MT_SMITE_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pSmite = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "SmiteMenu", param1);
			pSmite.SetTitle(sMenuTitle);
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

void vSmiteDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_SMITE, MT_MENU_SMITE);
}

void vSmiteMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SMITE, false))
	{
		vSmiteMenu(client, MT_SMITE_SECTION4, 0);
	}
}

void vSmiteMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_SMITE, false))
	{
		FormatEx(buffer, size, "%T", "SmiteMenu2", client);
	}
}

void vSmiteEntityCreated(int entity, const char[] classname)
{
	if (bIsValidEntity(entity) && StrEqual(classname, "survivor_death_model"))
	{
		int iOwner = GetClientOfUserId(g_iDeathModelOwner);
		if (bIsValidClient(iOwner))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnSmiteModelSpawnPost);
		}

		g_iDeathModelOwner = 0;
	}
}

public void OnSmiteModelSpawnPost(int model)
{
	g_iDeathModelOwner = 0;

	SDKUnhook(model, SDKHook_SpawnPost, OnSmiteModelSpawnPost);

	if (!bIsValidEntity(model))
	{
		return;
	}

	RemoveEntity(model);
}

public Action OnSmiteTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esSmiteCache[attacker].g_iSmiteHitMode == 0 || g_esSmiteCache[attacker].g_iSmiteHitMode == 1) && bIsSurvivor(victim) && g_esSmiteCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esSmiteAbility[g_esSmitePlayer[attacker].g_iTankType].g_iAccessFlags, g_esSmitePlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esSmitePlayer[attacker].g_iTankType, g_esSmiteAbility[g_esSmitePlayer[attacker].g_iTankType].g_iImmunityFlags, g_esSmitePlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmiteHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esSmiteCache[attacker].g_flSmiteChance, g_esSmiteCache[attacker].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esSmiteCache[victim].g_iSmiteHitMode == 0 || g_esSmiteCache[victim].g_iSmiteHitMode == 2) && bIsSurvivor(attacker) && g_esSmiteCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esSmiteAbility[g_esSmitePlayer[victim].g_iTankType].g_iAccessFlags, g_esSmitePlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esSmitePlayer[victim].g_iTankType, g_esSmiteAbility[g_esSmitePlayer[victim].g_iTankType].g_iImmunityFlags, g_esSmitePlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmiteHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esSmiteCache[victim].g_flSmiteChance, g_esSmiteCache[victim].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

void vSmitePluginCheck(ArrayList &list)
{
	list.PushString(MT_MENU_SMITE);
}

void vSmiteAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString(MT_SMITE_SECTION);
	list2.PushString(MT_SMITE_SECTION2);
	list3.PushString(MT_SMITE_SECTION3);
	list4.PushString(MT_SMITE_SECTION4);
}

void vSmiteCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSmiteCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_SMITE_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_SMITE_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_SMITE_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_SMITE_SECTION4);
	if (g_esSmiteCache[tank].g_iComboAbility == 1 && (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1))
	{
		static char sSubset[10][32];
		ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
		for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_SMITE_SECTION, false) || StrEqual(sSubset[iPos], MT_SMITE_SECTION2, false) || StrEqual(sSubset[iPos], MT_SMITE_SECTION3, false) || StrEqual(sSubset[iPos], MT_SMITE_SECTION4, false))
			{
				static float flDelay;
				flDelay = MT_GetCombinationSetting(tank, 3, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esSmiteCache[tank].g_iSmiteAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vSmiteAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerSmiteCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esSmiteCache[tank].g_iSmiteHitMode == 0 || g_esSmiteCache[tank].g_iSmiteHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vSmiteHit(survivor, tank, random, flChance, g_esSmiteCache[tank].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esSmiteCache[tank].g_iSmiteHitMode == 0 || g_esSmiteCache[tank].g_iSmiteHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vSmiteHit(survivor, tank, random, flChance, g_esSmiteCache[tank].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerSmiteCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

void vSmiteConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esSmiteAbility[iIndex].g_iAccessFlags = 0;
				g_esSmiteAbility[iIndex].g_iImmunityFlags = 0;
				g_esSmiteAbility[iIndex].g_iComboAbility = 0;
				g_esSmiteAbility[iIndex].g_iHumanAbility = 0;
				g_esSmiteAbility[iIndex].g_iHumanAmmo = 5;
				g_esSmiteAbility[iIndex].g_iHumanCooldown = 30;
				g_esSmiteAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esSmiteAbility[iIndex].g_iRequiresHumans = 0;
				g_esSmiteAbility[iIndex].g_iSmiteAbility = 0;
				g_esSmiteAbility[iIndex].g_iSmiteBody = 1;
				g_esSmiteAbility[iIndex].g_iSmiteEffect = 0;
				g_esSmiteAbility[iIndex].g_iSmiteMessage = 0;
				g_esSmiteAbility[iIndex].g_flSmiteChance = 33.3;
				g_esSmiteAbility[iIndex].g_iSmiteHit = 0;
				g_esSmiteAbility[iIndex].g_iSmiteHitMode = 0;
				g_esSmiteAbility[iIndex].g_flSmiteRange = 150.0;
				g_esSmiteAbility[iIndex].g_flSmiteRangeChance = 15.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esSmitePlayer[iPlayer].g_iAccessFlags = 0;
					g_esSmitePlayer[iPlayer].g_iImmunityFlags = 0;
					g_esSmitePlayer[iPlayer].g_iComboAbility = 0;
					g_esSmitePlayer[iPlayer].g_iHumanAbility = 0;
					g_esSmitePlayer[iPlayer].g_iHumanAmmo = 0;
					g_esSmitePlayer[iPlayer].g_iHumanCooldown = 0;
					g_esSmitePlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esSmitePlayer[iPlayer].g_iRequiresHumans = 0;
					g_esSmitePlayer[iPlayer].g_iSmiteAbility = 0;
					g_esSmitePlayer[iPlayer].g_iSmiteBody = 0;
					g_esSmitePlayer[iPlayer].g_iSmiteEffect = 0;
					g_esSmitePlayer[iPlayer].g_iSmiteMessage = 0;
					g_esSmitePlayer[iPlayer].g_flSmiteChance = 0.0;
					g_esSmitePlayer[iPlayer].g_iSmiteHit = 0;
					g_esSmitePlayer[iPlayer].g_iSmiteHitMode = 0;
					g_esSmitePlayer[iPlayer].g_flSmiteRange = 0.0;
					g_esSmitePlayer[iPlayer].g_flSmiteRangeChance = 0.0;
				}
			}
		}
	}
}

void vSmiteConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esSmitePlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSmitePlayer[admin].g_iComboAbility, value, 0, 1);
		g_esSmitePlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSmitePlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esSmitePlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSmitePlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esSmitePlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSmitePlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esSmitePlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSmitePlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esSmitePlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSmitePlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esSmitePlayer[admin].g_iSmiteAbility = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSmitePlayer[admin].g_iSmiteAbility, value, 0, 1);
		g_esSmitePlayer[admin].g_iSmiteEffect = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esSmitePlayer[admin].g_iSmiteEffect, value, 0, 7);
		g_esSmitePlayer[admin].g_iSmiteMessage = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSmitePlayer[admin].g_iSmiteMessage, value, 0, 3);
		g_esSmitePlayer[admin].g_iSmiteBody = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteBody", "Smite Body", "Smite_Body", "body", g_esSmitePlayer[admin].g_iSmiteBody, value, 0, 1);
		g_esSmitePlayer[admin].g_flSmiteChance = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteChance", "Smite Chance", "Smite_Chance", "chance", g_esSmitePlayer[admin].g_flSmiteChance, value, 0.0, 100.0);
		g_esSmitePlayer[admin].g_iSmiteHit = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteHit", "Smite Hit", "Smite_Hit", "hit", g_esSmitePlayer[admin].g_iSmiteHit, value, 0, 1);
		g_esSmitePlayer[admin].g_iSmiteHitMode = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteHitMode", "Smite Hit Mode", "Smite_Hit_Mode", "hitmode", g_esSmitePlayer[admin].g_iSmiteHitMode, value, 0, 2);
		g_esSmitePlayer[admin].g_flSmiteRange = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteRange", "Smite Range", "Smite_Range", "range", g_esSmitePlayer[admin].g_flSmiteRange, value, 1.0, 999999.0);
		g_esSmitePlayer[admin].g_flSmiteRangeChance = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteRangeChance", "Smite Range Chance", "Smite_Range_Chance", "rangechance", g_esSmitePlayer[admin].g_flSmiteRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_SMITE_SECTION, false) || StrEqual(subsection, MT_SMITE_SECTION2, false) || StrEqual(subsection, MT_SMITE_SECTION3, false) || StrEqual(subsection, MT_SMITE_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esSmitePlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esSmitePlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esSmiteAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esSmiteAbility[type].g_iComboAbility, value, 0, 1);
		g_esSmiteAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esSmiteAbility[type].g_iHumanAbility, value, 0, 2);
		g_esSmiteAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esSmiteAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esSmiteAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esSmiteAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esSmiteAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esSmiteAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esSmiteAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esSmiteAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esSmiteAbility[type].g_iSmiteAbility = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esSmiteAbility[type].g_iSmiteAbility, value, 0, 1);
		g_esSmiteAbility[type].g_iSmiteEffect = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esSmiteAbility[type].g_iSmiteEffect, value, 0, 7);
		g_esSmiteAbility[type].g_iSmiteMessage = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esSmiteAbility[type].g_iSmiteMessage, value, 0, 3);
		g_esSmiteAbility[type].g_iSmiteBody = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteBody", "Smite Body", "Smite_Body", "body", g_esSmiteAbility[type].g_iSmiteBody, value, 0, 1);
		g_esSmiteAbility[type].g_flSmiteChance = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteChance", "Smite Chance", "Smite_Chance", "chance", g_esSmiteAbility[type].g_flSmiteChance, value, 0.0, 100.0);
		g_esSmiteAbility[type].g_iSmiteHit = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteHit", "Smite Hit", "Smite_Hit", "hit", g_esSmiteAbility[type].g_iSmiteHit, value, 0, 1);
		g_esSmiteAbility[type].g_iSmiteHitMode = iGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteHitMode", "Smite Hit Mode", "Smite_Hit_Mode", "hitmode", g_esSmiteAbility[type].g_iSmiteHitMode, value, 0, 2);
		g_esSmiteAbility[type].g_flSmiteRange = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteRange", "Smite Range", "Smite_Range", "range", g_esSmiteAbility[type].g_flSmiteRange, value, 1.0, 999999.0);
		g_esSmiteAbility[type].g_flSmiteRangeChance = flGetKeyValue(subsection, MT_SMITE_SECTIONS, key, "SmiteRangeChance", "Smite Range Chance", "Smite_Range_Chance", "rangechance", g_esSmiteAbility[type].g_flSmiteRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_SMITE_SECTION, false) || StrEqual(subsection, MT_SMITE_SECTION2, false) || StrEqual(subsection, MT_SMITE_SECTION3, false) || StrEqual(subsection, MT_SMITE_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esSmiteAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esSmiteAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}
}

void vSmiteSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	g_esSmiteCache[tank].g_flSmiteChance = flGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_flSmiteChance, g_esSmiteAbility[type].g_flSmiteChance);
	g_esSmiteCache[tank].g_flSmiteRange = flGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_flSmiteRange, g_esSmiteAbility[type].g_flSmiteRange);
	g_esSmiteCache[tank].g_flSmiteRangeChance = flGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_flSmiteRangeChance, g_esSmiteAbility[type].g_flSmiteRangeChance);
	g_esSmiteCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iComboAbility, g_esSmiteAbility[type].g_iComboAbility);
	g_esSmiteCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iHumanAbility, g_esSmiteAbility[type].g_iHumanAbility);
	g_esSmiteCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iHumanAmmo, g_esSmiteAbility[type].g_iHumanAmmo);
	g_esSmiteCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iHumanCooldown, g_esSmiteAbility[type].g_iHumanCooldown);
	g_esSmiteCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_flOpenAreasOnly, g_esSmiteAbility[type].g_flOpenAreasOnly);
	g_esSmiteCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iRequiresHumans, g_esSmiteAbility[type].g_iRequiresHumans);
	g_esSmiteCache[tank].g_iSmiteAbility = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iSmiteAbility, g_esSmiteAbility[type].g_iSmiteAbility);
	g_esSmiteCache[tank].g_iSmiteBody = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iSmiteBody, g_esSmiteAbility[type].g_iSmiteBody);
	g_esSmiteCache[tank].g_iSmiteEffect = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iSmiteEffect, g_esSmiteAbility[type].g_iSmiteEffect);
	g_esSmiteCache[tank].g_iSmiteHit = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iSmiteHit, g_esSmiteAbility[type].g_iSmiteHit);
	g_esSmiteCache[tank].g_iSmiteHitMode = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iSmiteHitMode, g_esSmiteAbility[type].g_iSmiteHitMode);
	g_esSmiteCache[tank].g_iSmiteMessage = iGetSettingValue(apply, bHuman, g_esSmitePlayer[tank].g_iSmiteMessage, g_esSmiteAbility[type].g_iSmiteMessage);
	g_esSmitePlayer[tank].g_iTankType = apply ? type : 0;
}

void vSmiteCopyStats(int oldTank, int newTank)
{
	vSmiteCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveSmite(oldTank);
	}
}

void vSmiteEventFired(Event event, const char[] name)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vSmiteCopyStats2(iBot, iTank);
			vRemoveSmite(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vSmiteCopyStats2(iTank, iBot);
			vRemoveSmite(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveSmite(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vSmiteReset();
	}
}

void vSmiteAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmiteAbility[g_esSmitePlayer[tank].g_iTankType].g_iAccessFlags, g_esSmitePlayer[tank].g_iAccessFlags)) || g_esSmiteCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esSmiteCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esSmiteCache[tank].g_iSmiteAbility == 1 && g_esSmiteCache[tank].g_iComboAbility == 0)
	{
		vSmiteAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

void vSmiteButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esSmiteCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSmitePlayer[tank].g_iTankType) || (g_esSmiteCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmiteCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmiteAbility[g_esSmitePlayer[tank].g_iTankType].g_iAccessFlags, g_esSmitePlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esSmiteCache[tank].g_iSmiteAbility == 1 && g_esSmiteCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esSmitePlayer[tank].g_iCooldown != -1 && g_esSmitePlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman3", g_esSmitePlayer[tank].g_iCooldown - iTime);
					case false: vSmiteAbility(tank, GetRandomFloat(0.1, 100.0));
				}
			}
		}
	}
}

void vSmiteChangeType(int tank)
{
	vRemoveSmite(tank);
}

void vSmiteCopyStats2(int oldTank, int newTank)
{
	g_esSmitePlayer[newTank].g_iAmmoCount = g_esSmitePlayer[oldTank].g_iAmmoCount;
	g_esSmitePlayer[newTank].g_iCooldown = g_esSmitePlayer[oldTank].g_iCooldown;
}

void vRemoveSmite(int tank)
{
	g_esSmitePlayer[tank].g_bFailed = false;
	g_esSmitePlayer[tank].g_bNoAmmo = false;
	g_esSmitePlayer[tank].g_iAmmoCount = 0;
	g_esSmitePlayer[tank].g_iCooldown = -1;
}

void vSmiteReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveSmite(iPlayer);
		}
	}
}

void vSmite(int survivor)
{
	static float flPosition[3], flStartPosition[3];
	static int iColor[4] = {255, 255, 255, 255};

	GetClientAbsOrigin(survivor, flPosition);
	flPosition[2] -= 26.0;
	flStartPosition[0] = flPosition[0] + GetRandomFloat(-500.0, 500.0);
	flStartPosition[1] = flPosition[1] + GetRandomFloat(-500.0, 500.0);
	flStartPosition[2] = flPosition[2] + 800.0;

	TE_SetupBeamPoints(flStartPosition, flPosition, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
	TE_SendToAll();

	TE_SetupSparks(flPosition, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
	TE_SendToAll();

	TE_SetupEnergySplash(flPosition, view_as<float>({0.0, 0.0, 0.0}), false);
	TE_SendToAll();

	EmitAmbientSound(SOUND_EXPLOSION, flStartPosition, survivor, SNDLEVEL_RAIDSIREN);
}

void vSmiteAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esSmiteCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSmitePlayer[tank].g_iTankType) || (g_esSmiteCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmiteCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmiteAbility[g_esSmitePlayer[tank].g_iTankType].g_iAccessFlags, g_esSmitePlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esSmitePlayer[tank].g_iAmmoCount < g_esSmiteCache[tank].g_iHumanAmmo && g_esSmiteCache[tank].g_iHumanAmmo > 0))
	{
		g_esSmitePlayer[tank].g_bFailed = false;
		g_esSmitePlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3], flSurvivorPos[3], flRange, flChance;
		GetClientAbsOrigin(tank, flTankPos);
		flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esSmiteCache[tank].g_flSmiteRange;
		flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esSmiteCache[tank].g_flSmiteRangeChance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esSmitePlayer[tank].g_iTankType, g_esSmiteAbility[g_esSmitePlayer[tank].g_iTankType].g_iImmunityFlags, g_esSmitePlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
				{
					vSmiteHit(iSurvivor, tank, random, flChance, g_esSmiteCache[tank].g_iSmiteAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSmiteCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman4");
			}
		}
	}
	else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSmiteCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteAmmo");
	}
}

void vSmiteHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esSmiteCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esSmitePlayer[tank].g_iTankType) || (g_esSmiteCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esSmiteCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esSmiteAbility[g_esSmitePlayer[tank].g_iTankType].g_iAccessFlags, g_esSmitePlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esSmitePlayer[tank].g_iTankType, g_esSmiteAbility[g_esSmitePlayer[tank].g_iTankType].g_iImmunityFlags, g_esSmitePlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_GODMODE))
	{
		if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esSmitePlayer[tank].g_iAmmoCount < g_esSmiteCache[tank].g_iHumanAmmo && g_esSmiteCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance)
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSmiteCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esSmitePlayer[tank].g_iCooldown == -1 || g_esSmitePlayer[tank].g_iCooldown < iTime))
				{
					g_esSmitePlayer[tank].g_iAmmoCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman", g_esSmitePlayer[tank].g_iAmmoCount, g_esSmiteCache[tank].g_iHumanAmmo);

					g_esSmitePlayer[tank].g_iCooldown = (g_esSmitePlayer[tank].g_iAmmoCount < g_esSmiteCache[tank].g_iHumanAmmo && g_esSmiteCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esSmiteCache[tank].g_iHumanCooldown) : -1;
					if (g_esSmitePlayer[tank].g_iCooldown != -1 && g_esSmitePlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman5", g_esSmitePlayer[tank].g_iCooldown - iTime);
					}
				}

				if (g_esSmiteCache[tank].g_iSmiteBody == 1)
				{
					g_iDeathModelOwner = GetClientUserId(survivor);
				}

				vSmite(survivor);
				ForcePlayerSuicide(survivor);
				vEffect(survivor, tank, g_esSmiteCache[tank].g_iSmiteEffect, flags);

				if (g_esSmiteCache[tank].g_iSmiteMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Smite", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Smite", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esSmitePlayer[tank].g_iCooldown == -1 || g_esSmitePlayer[tank].g_iCooldown < iTime))
			{
				if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSmiteCache[tank].g_iHumanAbility == 1 && !g_esSmitePlayer[tank].g_bFailed)
				{
					g_esSmitePlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteHuman2");
				}
			}
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esSmiteCache[tank].g_iHumanAbility == 1 && !g_esSmitePlayer[tank].g_bNoAmmo)
		{
			g_esSmitePlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "SmiteAmmo");
		}
	}
}

public Action tTimerSmiteCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSmiteAbility[g_esSmitePlayer[iTank].g_iTankType].g_iAccessFlags, g_esSmitePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSmitePlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esSmiteCache[iTank].g_iSmiteAbility == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vSmiteAbility(iTank, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerSmiteCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esSmiteAbility[g_esSmitePlayer[iTank].g_iTankType].g_iAccessFlags, g_esSmitePlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esSmitePlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esSmiteCache[iTank].g_iSmiteHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esSmiteCache[iTank].g_iSmiteHitMode == 0 || g_esSmiteCache[iTank].g_iSmiteHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vSmiteHit(iSurvivor, iTank, flRandom, flChance, g_esSmiteCache[iTank].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esSmiteCache[iTank].g_iSmiteHitMode == 0 || g_esSmiteCache[iTank].g_iSmiteHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vSmiteHit(iSurvivor, iTank, flRandom, flChance, g_esSmiteCache[iTank].g_iSmiteHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}