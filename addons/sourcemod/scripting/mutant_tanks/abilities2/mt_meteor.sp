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

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

#define MT_METEOR_SECTION "meteorability"
#define MT_METEOR_SECTION2 "meteor ability"
#define MT_METEOR_SECTION3 "meteor_ability"
#define MT_METEOR_SECTION4 "meteor"
#define MT_METEOR_SECTIONS MT_METEOR_SECTION, MT_METEOR_SECTION2, MT_METEOR_SECTION3, MT_METEOR_SECTION4

#define MT_MENU_METEOR "Meteor Ability"

enum struct esMeteorPlayer
{
	bool g_bActivated;

	float g_flMeteorChance;
	float g_flMeteorDamage;
	float g_flMeteorInterval;
	float g_flMeteorLifetime;
	float g_flMeteorRadius[2];
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iMeteorAbility;
	int g_iMeteorDuration;
	int g_iMeteorMessage;
	int g_iMeteorMode;
	int g_iRequiresHumans;
	int g_iTankType;
}

esMeteorPlayer g_esMeteorPlayer[MAXPLAYERS + 1];

enum struct esMeteorAbility
{
	float g_flMeteorChance;
	float g_flMeteorDamage;
	float g_flMeteorInterval;
	float g_flMeteorLifetime;
	float g_flMeteorRadius[2];
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iMeteorAbility;
	int g_iMeteorDuration;
	int g_iMeteorMessage;
	int g_iMeteorMode;
	int g_iRequiresHumans;
}

esMeteorAbility g_esMeteorAbility[MT_MAXTYPES + 1];

enum struct esMeteorCache
{
	float g_flMeteorChance;
	float g_flMeteorDamage;
	float g_flMeteorInterval;
	float g_flMeteorLifetime;
	float g_flMeteorRadius[2];
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iMeteorAbility;
	int g_iMeteorDuration;
	int g_iMeteorMessage;
	int g_iMeteorMode;
	int g_iRequiresHumans;
}

esMeteorCache g_esMeteorCache[MAXPLAYERS + 1];

int g_iUserID[2048];

void vMeteorMapStart()
{
	vMeteorReset();
}

void vMeteorClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnMeteorTakeDamage);
	vRemoveMeteor(client);
}

void vMeteorClientDisconnect_Post(int client)
{
	vRemoveMeteor(client);
}

void vMeteorMapEnd()
{
	vMeteorReset();
}

void vMeteorMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_METEOR_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iMeteorMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Meteor Ability Information");
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

public int iMeteorMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esMeteorCache[param1].g_iMeteorAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esMeteorCache[param1].g_iHumanAmmo - g_esMeteorPlayer[param1].g_iAmmoCount, g_esMeteorCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esMeteorCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esMeteorCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "MeteorDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esMeteorCache[param1].g_iMeteorDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esMeteorCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vMeteorMenu(param1, MT_METEOR_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pMeteor = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MeteorMenu", param1);
			pMeteor.SetTitle(sMenuTitle);
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
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 6: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					case 7: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

void vMeteorDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_METEOR, MT_MENU_METEOR);
}

void vMeteorMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_METEOR, false))
	{
		vMeteorMenu(client, MT_METEOR_SECTION4, 0);
	}
}

void vMeteorMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_METEOR, false))
	{
		FormatEx(buffer, size, "%T", "MeteorMenu2", client);
	}
}

void vMeteorEntityCreated(int entity, const char[] classname)
{
	if (bIsValidEntity(entity))
	{
		g_iUserID[entity] = 0;

		if (StrEqual(classname, "pipe_bomb_projectile"))
		{
			SDKHook(entity, SDKHook_SpawnPost, OnPropSpawn);
		}
	}
}

void OnPropSpawn(int prop)
{
	int iTank = GetEntPropEnt(prop, Prop_Send, "m_hOwnerEntity");
	if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_iUserID[prop] = GetClientUserId(iTank);
	}
}

public Action OnMeteorTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && bIsValidEntity(inflictor) && damage > 0.0)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		static int iTank;
		iTank = GetClientOfUserId(g_iUserID[inflictor]);
		if (MT_IsTankSupported(iTank) && g_esMeteorCache[iTank].g_iMeteorAbility == 1 && g_esMeteorCache[iTank].g_iMeteorMode == 1 && StrEqual(sClassname, "pipe_bomb_projectile") && damagetype == 134217792)
		{
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

void vMeteorPluginCheck(ArrayList &list)
{
	list.PushString(MT_MENU_METEOR);
}

void vMeteorAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString(MT_METEOR_SECTION);
	list2.PushString(MT_METEOR_SECTION2);
	list3.PushString(MT_METEOR_SECTION3);
	list4.PushString(MT_METEOR_SECTION4);
}

void vMeteorCombineAbilities(int tank, int type, const float random, const char[] combo)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esMeteorCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_METEOR_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_METEOR_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_METEOR_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_METEOR_SECTION4);
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_MAINRANGE && g_esMeteorCache[tank].g_iMeteorAbility == 1 && g_esMeteorCache[tank].g_iComboAbility == 1 && !g_esMeteorPlayer[tank].g_bActivated)
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_METEOR_SECTION, false) || StrEqual(sSubset[iPos], MT_METEOR_SECTION2, false) || StrEqual(sSubset[iPos], MT_METEOR_SECTION3, false) || StrEqual(sSubset[iPos], MT_METEOR_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						static float flDelay;
						flDelay = MT_GetCombinationSetting(tank, 3, iPos);

						switch (flDelay)
						{
							case 0.0: vMeteor(tank, iPos);
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerMeteorCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteCell(iPos);
							}
						}

						break;
					}
				}
			}
		}
	}
}

void vMeteorConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esMeteorAbility[iIndex].g_iAccessFlags = 0;
				g_esMeteorAbility[iIndex].g_iImmunityFlags = 0;
				g_esMeteorAbility[iIndex].g_iComboAbility = 0;
				g_esMeteorAbility[iIndex].g_iHumanAbility = 0;
				g_esMeteorAbility[iIndex].g_iHumanAmmo = 5;
				g_esMeteorAbility[iIndex].g_iHumanCooldown = 30;
				g_esMeteorAbility[iIndex].g_iHumanMode = 1;
				g_esMeteorAbility[iIndex].g_flOpenAreasOnly = 500.0;
				g_esMeteorAbility[iIndex].g_iRequiresHumans = 0;
				g_esMeteorAbility[iIndex].g_iMeteorAbility = 0;
				g_esMeteorAbility[iIndex].g_iMeteorMessage = 0;
				g_esMeteorAbility[iIndex].g_flMeteorChance = 33.3;
				g_esMeteorAbility[iIndex].g_flMeteorDamage = 5.0;
				g_esMeteorAbility[iIndex].g_iMeteorDuration = 5;
				g_esMeteorAbility[iIndex].g_flMeteorInterval = 0.6;
				g_esMeteorAbility[iIndex].g_flMeteorLifetime = 15.0;
				g_esMeteorAbility[iIndex].g_iMeteorMode = 0;
				g_esMeteorAbility[iIndex].g_flMeteorRadius[0] = -180.0;
				g_esMeteorAbility[iIndex].g_flMeteorRadius[1] = 180.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esMeteorPlayer[iPlayer].g_iAccessFlags = 0;
					g_esMeteorPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esMeteorPlayer[iPlayer].g_iComboAbility = 0;
					g_esMeteorPlayer[iPlayer].g_iHumanAbility = 0;
					g_esMeteorPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esMeteorPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esMeteorPlayer[iPlayer].g_iHumanMode = 0;
					g_esMeteorPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esMeteorPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esMeteorPlayer[iPlayer].g_iMeteorAbility = 0;
					g_esMeteorPlayer[iPlayer].g_iMeteorMessage = 0;
					g_esMeteorPlayer[iPlayer].g_flMeteorChance = 0.0;
					g_esMeteorPlayer[iPlayer].g_flMeteorDamage = 0.0;
					g_esMeteorPlayer[iPlayer].g_iMeteorDuration = 0;
					g_esMeteorPlayer[iPlayer].g_flMeteorInterval = 0.0;
					g_esMeteorPlayer[iPlayer].g_flMeteorLifetime = 0.0;
					g_esMeteorPlayer[iPlayer].g_iMeteorMode = 0;
					g_esMeteorPlayer[iPlayer].g_flMeteorRadius[0] = 0.0;
					g_esMeteorPlayer[iPlayer].g_flMeteorRadius[1] = 0.0;
				}
			}
		}
	}
}

void vMeteorConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esMeteorPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esMeteorPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esMeteorPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esMeteorPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esMeteorPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esMeteorPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esMeteorPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esMeteorPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esMeteorPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esMeteorPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esMeteorPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esMeteorPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esMeteorPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esMeteorPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esMeteorPlayer[admin].g_iMeteorAbility = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esMeteorPlayer[admin].g_iMeteorAbility, value, 0, 1);
		g_esMeteorPlayer[admin].g_iMeteorMessage = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esMeteorPlayer[admin].g_iMeteorMessage, value, 0, 1);
		g_esMeteorPlayer[admin].g_flMeteorChance = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorChance", "Meteor Chance", "Meteor_Chance", "chance", g_esMeteorPlayer[admin].g_flMeteorChance, value, 0.0, 100.0);
		g_esMeteorPlayer[admin].g_flMeteorDamage = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorDamage", "Meteor Damage", "Meteor_Damage", "damage", g_esMeteorPlayer[admin].g_flMeteorDamage, value, 1.0, 999999.0);
		g_esMeteorPlayer[admin].g_iMeteorDuration = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorDuration", "Meteor Duration", "Meteor_Duration", "duration", g_esMeteorPlayer[admin].g_iMeteorDuration, value, 1, 999999);
		g_esMeteorPlayer[admin].g_flMeteorInterval = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorInterval", "Meteor Interval", "Meteor_Interval", "interval", g_esMeteorPlayer[admin].g_flMeteorInterval, value, 0.1, 1.0);
		g_esMeteorPlayer[admin].g_flMeteorLifetime = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorLifetime", "Meteor Lifetime", "Meteor_Lifetime", "lifetime", g_esMeteorPlayer[admin].g_flMeteorLifetime, value, 0.1, 999999.0);
		g_esMeteorPlayer[admin].g_iMeteorMode = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorMode", "Meteor Mode", "Meteor_Mode", "mode", g_esMeteorPlayer[admin].g_iMeteorMode, value, 0, 1);

		if (StrEqual(subsection, MT_METEOR_SECTION, false) || StrEqual(subsection, MT_METEOR_SECTION2, false) || StrEqual(subsection, MT_METEOR_SECTION3, false) || StrEqual(subsection, MT_METEOR_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esMeteorPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esMeteorPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "MeteorRadius", false) || StrEqual(key, "Meteor Radius", false) || StrEqual(key, "Meteor_Radius", false) || StrEqual(key, "radius", false))
			{
				static char sSet[2][7], sValue[14];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

				g_esMeteorPlayer[admin].g_flMeteorRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 0.0) : g_esMeteorPlayer[admin].g_flMeteorRadius[0];
				g_esMeteorPlayer[admin].g_flMeteorRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 200.0) : g_esMeteorPlayer[admin].g_flMeteorRadius[1];
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esMeteorAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esMeteorAbility[type].g_iComboAbility, value, 0, 1);
		g_esMeteorAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esMeteorAbility[type].g_iHumanAbility, value, 0, 2);
		g_esMeteorAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esMeteorAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esMeteorAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esMeteorAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esMeteorAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esMeteorAbility[type].g_iHumanMode, value, 0, 1);
		g_esMeteorAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esMeteorAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esMeteorAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esMeteorAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esMeteorAbility[type].g_iMeteorAbility = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esMeteorAbility[type].g_iMeteorAbility, value, 0, 1);
		g_esMeteorAbility[type].g_iMeteorMessage = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esMeteorAbility[type].g_iMeteorMessage, value, 0, 1);
		g_esMeteorAbility[type].g_flMeteorChance = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorChance", "Meteor Chance", "Meteor_Chance", "chance", g_esMeteorAbility[type].g_flMeteorChance, value, 0.0, 100.0);
		g_esMeteorAbility[type].g_flMeteorDamage = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorDamage", "Meteor Damage", "Meteor_Damage", "damage", g_esMeteorAbility[type].g_flMeteorDamage, value, 1.0, 999999.0);
		g_esMeteorAbility[type].g_iMeteorDuration = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorDuration", "Meteor Duration", "Meteor_Duration", "duration", g_esMeteorAbility[type].g_iMeteorDuration, value, 1, 999999);
		g_esMeteorAbility[type].g_flMeteorInterval = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorInterval", "Meteor Interval", "Meteor_Interval", "interval", g_esMeteorAbility[type].g_flMeteorInterval, value, 0.1, 1.0);
		g_esMeteorAbility[type].g_flMeteorLifetime = flGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorLifetime", "Meteor Lifetime", "Meteor_Lifetime", "lifetime", g_esMeteorAbility[type].g_flMeteorLifetime, value, 0.1, 999999.0);
		g_esMeteorAbility[type].g_iMeteorMode = iGetKeyValue(subsection, MT_METEOR_SECTIONS, key, "MeteorMode", "Meteor Mode", "Meteor_Mode", "mode", g_esMeteorAbility[type].g_iMeteorMode, value, 0, 1);

		if (StrEqual(subsection, MT_METEOR_SECTION, false) || StrEqual(subsection, MT_METEOR_SECTION2, false) || StrEqual(subsection, MT_METEOR_SECTION3, false) || StrEqual(subsection, MT_METEOR_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esMeteorAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esMeteorAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "MeteorRadius", false) || StrEqual(key, "Meteor Radius", false) || StrEqual(key, "Meteor_Radius", false) || StrEqual(key, "radius", false))
			{
				static char sSet[2][7], sValue[14];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

				g_esMeteorAbility[type].g_flMeteorRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 0.0) : g_esMeteorAbility[type].g_flMeteorRadius[0];
				g_esMeteorAbility[type].g_flMeteorRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 200.0) : g_esMeteorAbility[type].g_flMeteorRadius[1];
			}
		}
	}
}

void vMeteorSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = bIsTank(tank, MT_CHECK_FAKECLIENT);
	g_esMeteorCache[tank].g_flMeteorChance = flGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_flMeteorChance, g_esMeteorAbility[type].g_flMeteorChance);
	g_esMeteorCache[tank].g_flMeteorDamage = flGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_flMeteorDamage, g_esMeteorAbility[type].g_flMeteorDamage);
	g_esMeteorCache[tank].g_flMeteorInterval = flGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_flMeteorInterval, g_esMeteorAbility[type].g_flMeteorInterval);
	g_esMeteorCache[tank].g_flMeteorLifetime = flGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_flMeteorLifetime, g_esMeteorAbility[type].g_flMeteorLifetime);
	g_esMeteorCache[tank].g_flMeteorRadius[0] = flGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_flMeteorRadius[0], g_esMeteorAbility[type].g_flMeteorRadius[0]);
	g_esMeteorCache[tank].g_flMeteorRadius[1] = flGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_flMeteorRadius[1], g_esMeteorAbility[type].g_flMeteorRadius[1]);
	g_esMeteorCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iComboAbility, g_esMeteorAbility[type].g_iComboAbility);
	g_esMeteorCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iHumanAbility, g_esMeteorAbility[type].g_iHumanAbility);
	g_esMeteorCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iHumanAmmo, g_esMeteorAbility[type].g_iHumanAmmo);
	g_esMeteorCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iHumanCooldown, g_esMeteorAbility[type].g_iHumanCooldown);
	g_esMeteorCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iHumanMode, g_esMeteorAbility[type].g_iHumanMode);
	g_esMeteorCache[tank].g_iMeteorAbility = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iMeteorAbility, g_esMeteorAbility[type].g_iMeteorAbility);
	g_esMeteorCache[tank].g_iMeteorDuration = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iMeteorDuration, g_esMeteorAbility[type].g_iMeteorDuration);
	g_esMeteorCache[tank].g_iMeteorMessage = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iMeteorMessage, g_esMeteorAbility[type].g_iMeteorMessage);
	g_esMeteorCache[tank].g_iMeteorMode = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iMeteorMode, g_esMeteorAbility[type].g_iMeteorMode);
	g_esMeteorCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_flOpenAreasOnly, g_esMeteorAbility[type].g_flOpenAreasOnly);
	g_esMeteorCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esMeteorPlayer[tank].g_iRequiresHumans, g_esMeteorAbility[type].g_iRequiresHumans);
	g_esMeteorPlayer[tank].g_iTankType = apply ? type : 0;
}

void vMeteorCopyStats(int oldTank, int newTank)
{
	vMeteorCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveMeteor(oldTank);
	}
}

void vMeteorEventFired(Event event, const char[] name)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vMeteorCopyStats2(iBot, iTank);
			vRemoveMeteor(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vMeteorCopyStats2(iTank, iBot);
			vRemoveMeteor(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveMeteor(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vMeteorReset();
	}
}

void vMeteorAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMeteorAbility[g_esMeteorPlayer[tank].g_iTankType].g_iAccessFlags, g_esMeteorPlayer[tank].g_iAccessFlags)) || g_esMeteorCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsTank(tank, MT_CHECK_FAKECLIENT) || g_esMeteorCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esMeteorCache[tank].g_iMeteorAbility == 1 && g_esMeteorCache[tank].g_iComboAbility == 0 && !g_esMeteorPlayer[tank].g_bActivated)
	{
		vMeteorAbility(tank);
	}
}

void vMeteorButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esMeteorCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esMeteorPlayer[tank].g_iTankType) || (g_esMeteorCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMeteorCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMeteorAbility[g_esMeteorPlayer[tank].g_iTankType].g_iAccessFlags, g_esMeteorPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esMeteorCache[tank].g_iMeteorAbility == 1 && g_esMeteorCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esMeteorPlayer[tank].g_iCooldown != -1 && g_esMeteorPlayer[tank].g_iCooldown > iTime;

				switch (g_esMeteorCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esMeteorPlayer[tank].g_bActivated && !bRecharging)
						{
							vMeteorAbility(tank);
						}
						else if (g_esMeteorPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman4", g_esMeteorPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esMeteorPlayer[tank].g_iAmmoCount < g_esMeteorCache[tank].g_iHumanAmmo && g_esMeteorCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esMeteorPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esMeteorPlayer[tank].g_bActivated = true;
								g_esMeteorPlayer[tank].g_iAmmoCount++;

								vMeteor2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman", g_esMeteorPlayer[tank].g_iAmmoCount, g_esMeteorCache[tank].g_iHumanAmmo);
							}
							else if (g_esMeteorPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman4", g_esMeteorPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorAmmo");
						}
					}
				}
			}
		}
	}
}

void vMeteorButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esMeteorCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esMeteorCache[tank].g_iHumanMode == 1 && g_esMeteorPlayer[tank].g_bActivated && (g_esMeteorPlayer[tank].g_iCooldown == -1 || g_esMeteorPlayer[tank].g_iCooldown < GetTime()))
			{
				vMeteorReset2(tank);
				vMeteorReset3(tank);
			}
		}
	}
}

void vMeteorChangeType(int tank)
{
	vRemoveMeteor(tank);
}

void vMeteorCopyStats2(int oldTank, int newTank)
{
	g_esMeteorPlayer[newTank].g_iAmmoCount = g_esMeteorPlayer[oldTank].g_iAmmoCount;
	g_esMeteorPlayer[newTank].g_iCooldown = g_esMeteorPlayer[oldTank].g_iCooldown;
}

void vMeteor(int tank, int pos = -1)
{
	g_esMeteorPlayer[tank].g_bActivated = true;

	vMeteor2(tank, pos);

	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esMeteorCache[tank].g_iHumanAbility == 1)
	{
		g_esMeteorPlayer[tank].g_iAmmoCount++;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman", g_esMeteorPlayer[tank].g_iAmmoCount, g_esMeteorCache[tank].g_iHumanAmmo);
	}

	if (g_esMeteorCache[tank].g_iMeteorMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Meteor", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Meteor", LANG_SERVER, sTankName);
	}
}

void vMeteor2(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esMeteorCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esMeteorPlayer[tank].g_iTankType) || (g_esMeteorCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMeteorCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMeteorAbility[g_esMeteorPlayer[tank].g_iTankType].g_iAccessFlags, g_esMeteorPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flInterval;
	flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esMeteorCache[tank].g_flMeteorInterval;
	DataPack dpMeteor;
	CreateDataTimer(flInterval, tTimerMeteor, dpMeteor, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpMeteor.WriteCell(GetClientUserId(tank));
	dpMeteor.WriteCell(g_esMeteorPlayer[tank].g_iTankType);
	dpMeteor.WriteCell(GetTime());
	dpMeteor.WriteCell(pos);
}

void vMeteor3(int tank, int rock, int pos = -1)
{
	if (!MT_IsTankSupported(tank) || bIsAreaNarrow(tank, g_esMeteorCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esMeteorPlayer[tank].g_iTankType) || (g_esMeteorCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMeteorCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMeteorAbility[g_esMeteorPlayer[tank].g_iTankType].g_iAccessFlags, g_esMeteorPlayer[tank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esMeteorPlayer[tank].g_iTankType) || !MT_IsCustomTankSupported(tank) || !bIsValidEntity(rock))
	{
		return;
	}

	RemoveEntity(rock);

	switch (g_esMeteorCache[tank].g_iMeteorMode)
	{
		case 0:
		{
			static float flRockPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flRockPos);
			vSpawnBreakProp(tank, flRockPos, 50.0, MODEL_GASCAN);
			vSpawnBreakProp(tank, flRockPos, 50.0, MODEL_PROPANETANK);
		}
		case 1:
		{
			static float flRockPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flRockPos);
			vSpawnBreakProp(tank, flRockPos, 50.0, MODEL_PROPANETANK);

			static float flTankPos[3], flSurvivorPos[3], flDamage;
			GetClientAbsOrigin(tank, flTankPos);
			flDamage = (pos != -1) ? MT_GetCombinationSetting(tank, 2, pos) : g_esMeteorCache[tank].g_flMeteorDamage;
			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esMeteorPlayer[tank].g_iTankType, g_esMeteorAbility[g_esMeteorPlayer[tank].g_iTankType].g_iImmunityFlags, g_esMeteorPlayer[iSurvivor].g_iImmunityFlags))
				{
					GetClientAbsOrigin(iSurvivor, flSurvivorPos);
					if (GetVectorDistance(flTankPos, flSurvivorPos) <= 200.0)
					{
						vDamagePlayer(iSurvivor, tank, MT_GetScaledDamage(flDamage), "16");
					}
				}
			}

			vPushNearbyEntities(tank, flRockPos);
		}
	}
}

void vMeteorAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esMeteorCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esMeteorPlayer[tank].g_iTankType) || (g_esMeteorCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMeteorCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esMeteorAbility[g_esMeteorPlayer[tank].g_iTankType].g_iAccessFlags, g_esMeteorPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsTank(tank, MT_CHECK_FAKECLIENT) || (g_esMeteorPlayer[tank].g_iAmmoCount < g_esMeteorCache[tank].g_iHumanAmmo && g_esMeteorCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esMeteorCache[tank].g_flMeteorChance)
		{
			vMeteor(tank);
		}
		else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esMeteorCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman2");
		}
	}
	else if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esMeteorCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorAmmo");
	}
}

void vRemoveMeteor(int tank)
{
	g_esMeteorPlayer[tank].g_bActivated = false;
	g_esMeteorPlayer[tank].g_iAmmoCount = 0;
	g_esMeteorPlayer[tank].g_iCooldown = -1;
}

void vMeteorReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveMeteor(iPlayer);
		}
	}
}

void vMeteorReset2(int tank)
{
	g_esMeteorPlayer[tank].g_bActivated = false;

	if (g_esMeteorCache[tank].g_iMeteorMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Meteor2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Meteor2", LANG_SERVER, sTankName);
	}
}

void vMeteorReset3(int tank)
{
	int iTime = GetTime();
	g_esMeteorPlayer[tank].g_iCooldown = (g_esMeteorPlayer[tank].g_iAmmoCount < g_esMeteorCache[tank].g_iHumanAmmo && g_esMeteorCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esMeteorCache[tank].g_iHumanCooldown) : -1;
	if (g_esMeteorPlayer[tank].g_iCooldown != -1 && g_esMeteorPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman5", g_esMeteorPlayer[tank].g_iCooldown - iTime);
	}
}

public Action tTimerMeteorCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esMeteorAbility[g_esMeteorPlayer[iTank].g_iTankType].g_iAccessFlags, g_esMeteorPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esMeteorPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esMeteorCache[iTank].g_iMeteorAbility == 0 || g_esMeteorPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vMeteor(iTank, iPos);

	return Plugin_Continue;
}

public Action tTimerDestroyMeteor(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iMeteor, iTank;
	iMeteor = EntRefToEntIndex(pack.ReadCell());
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || iMeteor == INVALID_ENT_REFERENCE || !bIsValidEntity(iMeteor))
	{
		return Plugin_Stop;
	}

	static int iPos;
	iPos = pack.ReadCell();
	vMeteor3(iTank, iMeteor, iPos);

	return Plugin_Continue;
}

public Action tTimerMeteor(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esMeteorCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esMeteorPlayer[iTank].g_iTankType) || (g_esMeteorCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esMeteorCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esMeteorAbility[g_esMeteorPlayer[iTank].g_iTankType].g_iAccessFlags, g_esMeteorPlayer[iTank].g_iAccessFlags)) || !MT_IsCustomTankSupported(iTank) || iType != g_esMeteorPlayer[iTank].g_iTankType || !g_esMeteorPlayer[iTank].g_bActivated)
	{
		g_esMeteorPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static int iTime, iPos, iDuration, iCurrentTime;
	iTime = pack.ReadCell();
	iPos = pack.ReadCell();
	iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 4, iPos)) : g_esMeteorCache[iTank].g_iMeteorDuration;
	iCurrentTime = GetTime();
	if (g_esMeteorCache[iTank].g_iMeteorAbility == 0 || ((!bIsTank(iTank, MT_CHECK_FAKECLIENT) || (g_esMeteorCache[iTank].g_iHumanAbility == 1 && g_esMeteorCache[iTank].g_iHumanMode == 0)) && (iTime + iDuration) < iCurrentTime))
	{
		vMeteorReset2(iTank);

		if (bIsTank(iTank, MT_CHECK_FAKECLIENT) && g_esMeteorCache[iTank].g_iHumanAbility == 1 && g_esMeteorCache[iTank].g_iHumanMode == 0 && (g_esMeteorPlayer[iTank].g_iCooldown == -1 || g_esMeteorPlayer[iTank].g_iCooldown < iCurrentTime))
		{
			vMeteorReset3(iTank);
		}

		return Plugin_Stop;
	}

	static float flPos[3], flAngles[3], flMinRadius, flMaxRadius;
	GetClientEyePosition(iTank, flPos);
	flAngles[0] = GetRandomFloat(-20.0, 20.0);
	flAngles[1] = GetRandomFloat(-20.0, 20.0);
	flAngles[2] = 60.0;
	GetVectorAngles(flAngles, flAngles);

	flMinRadius = (iPos != -1) ? MT_GetCombinationSetting(iTank, 6, iPos) : g_esMeteorCache[iTank].g_flMeteorRadius[0];
	flMaxRadius = (iPos != -1) ? MT_GetCombinationSetting(iTank, 7, iPos) : g_esMeteorCache[iTank].g_flMeteorRadius[1];

	static float flHitpos[3], flDistance;
	iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);
	flDistance = GetVectorDistance(flPos, flHitpos);
	if (flDistance > 1600.0)
	{
		flDistance = 1600.0;
	}

	static float flVector[3];
	MakeVectorFromPoints(flPos, flHitpos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitpos);
	if (flDistance > 100.0)
	{
		static int iMeteor;
		iMeteor = CreateEntityByName("tank_rock");
		if (bIsValidEntity(iMeteor))
		{
			static float flAngles2[3];
			for (int iIndex = 0; iIndex < sizeof(flAngles2); iIndex++)
			{
				flAngles2[iIndex] = GetRandomFloat(flMinRadius, flMaxRadius);
			}

			static float flVelocity[3];
			flVelocity[0] = GetRandomFloat(0.0, 350.0);
			flVelocity[1] = GetRandomFloat(0.0, 350.0);
			flVelocity[2] = GetRandomFloat(0.0, 30.0);

			TeleportEntity(iMeteor, flHitpos, flAngles2, NULL_VECTOR);
			DispatchSpawn(iMeteor);
			TeleportEntity(iMeteor, NULL_VECTOR, NULL_VECTOR, flVelocity);
			ActivateEntity(iMeteor);
			AcceptEntityInput(iMeteor, "Ignite");

			SetEntPropEnt(iMeteor, Prop_Data, "m_hThrower", iTank);
			iMeteor = EntIndexToEntRef(iMeteor);
			vDeleteEntity(iMeteor, g_esMeteorCache[iTank].g_flMeteorLifetime);

			DataPack dpMeteor;
			CreateDataTimer(10.0, tTimerDestroyMeteor, dpMeteor, TIMER_FLAG_NO_MAPCHANGE);
			dpMeteor.WriteCell(iMeteor);
			dpMeteor.WriteCell(GetClientUserId(iTank));
			dpMeteor.WriteCell(iPos);
		}
	}

	static int iMeteor;
	iMeteor = -1;
	while ((iMeteor = FindEntityByClassname(iMeteor, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		static int iTank2;
		iTank2 = GetEntPropEnt(iMeteor, Prop_Data, "m_hThrower");
		if (iTank == iTank2 && flGetGroundUnits(iMeteor) < 200.0)
		{
			vMeteor3(iTank2, iMeteor, iPos);
		}
	}

	return Plugin_Continue;
}