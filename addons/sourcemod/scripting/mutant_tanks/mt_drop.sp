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

#include <sourcemod>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Drop Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank drops weapons upon death.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bSecondGame;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	switch (GetEngineVersion())
	{
		case Engine_Left4Dead: g_bSecondGame = false;
		case Engine_Left4Dead2: g_bSecondGame = true;
		default:
		{
			strcopy(error, err_max, "\"[MT] Drop Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	return APLRes_Success;
}

#define MT_CONFIG_SECTION "dropability"
#define MT_CONFIG_SECTION2 "drop ability"
#define MT_CONFIG_SECTION3 "drop_ability"
#define MT_CONFIG_SECTION4 "drop"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_DROP "Drop Ability"

char g_sMeleeScripts[][] =
{
	"scripts/melee/fireaxe.txt", "scripts/melee/baseball_bat.txt", "scripts/melee/cricket_bat.txt", "scripts/melee/crowbar.txt", "scripts/melee/golfclub.txt", "scripts/melee/electric_guitar.txt",
	"scripts/melee/katana.txt", "scripts/melee/knife.txt", "scripts/melee/machete.txt", "scripts/melee/frying_pan.txt", "scripts/melee/tonfa.txt", "scripts/melee/pitchfork.txt", "scripts/melee/shovel.txt"
}, g_sWeaponClasses[][] =
{
	"weapon_autoshotgun", "weapon_hunting_rifle", "weapon_rifle", "weapon_pistol", "weapon_pumpshotgun", "weapon_smg"
}, g_sWeaponModelsView[][] =
{
	"models/v_models/weapons/v_autoshot_m4super.mdl", "models/v_models/weapons/v_sniper_mini14.mdl", "models/v_models/weapons/v_rifle_m16a2.mdl", "models/v_models/weapons/v_pistol_1911.mdl",
	"models/v_models/weapons/v_shotgun.mdl", "models/v_models/weapons/v_smg_uzi.mdl"
}, g_sWeaponModelsWorld[][] =
{
	"models/w_models/weapons/w_autoshot_m4super.mdl", "models/w_models/weapons/w_sniper_mini14.mdl", "models/w_models/weapons/w_rifle_m16a2.mdl", "models/w_models/weapons/w_pistol_1911.mdl",
	"models/w_models/weapons/w_shotgun.mdl", "models/w_models/weapons/w_smg_uzi.mdl"
}, g_sWeaponClasses2[][] =
{
	"weapon_rifle_ak47", "weapon_autoshotgun", "weapon_sniper_awp", "weapon_shotgun_chrome", "weapon_rifle_desert", "weapon_grenade_launcher", "weapon_hunting_rifle", "weapon_rifle",
	"weapon_rifle_m60", "weapon_pistol_magnum", "weapon_sniper_military", "weapon_smg_mp5", "weapon_pistol", "weapon_pumpshotgun", "weapon_sniper_scout", "weapon_rifle_sg552",
	"weapon_smg_silenced", "weapon_smg", "weapon_shotgun_spas", "fireaxe", "baseball_bat", "weapon_chainsaw", "cricket_bat", "crowbar", "golfclub", "electric_guitar", "katana", "knife",
	"machete", "frying_pan", "tonfa", "pitchfork", "shovel"
}, g_sWeaponModelsView2[][] =
{
	"models/v_models/weapons/v_rifle_ak47.mdl", "models/v_models/weapons/v_autoshot_m4super.mdl", "models/v_models/weapons/v_sniper_awp.mdl", "models/v_models/weapons/v_shotgun.mdl",
	"models/v_models/weapons/v_desert_rifle.mdl", "models/v_models/weapons/v_grenade_launcher.mdl", "models/v_models/weapons/v_sniper_mini14.mdl", "models/v_models/weapons/v_rifle_m16a2.mdl",
	"models/v_models/weapons/v_m60.mdl", "models/v_models/weapons/v_desert_eagle.mdl", "models/v_models/weapons/v_sniper_military.mdl", "models/v_models/weapons/v_smg_mp5.mdl",
	"models/v_models/weapons/v_pistol_a.mdl", "models/v_models/weapons/v_pumpshotgun_a.mdl", "models/v_models/weapons/v_sniper_scout.mdl", "models/v_models/weapons/v_rifle_sg552.mdl",
	"models/v_models/weapons/v_smg_a.mdl", "models/v_models/weapons/v_smg_uzi.mdl", "models/v_models/weapons/v_shotgun_spas.mdl", "models/weapons/melee/v_fireaxe.mdl", "models/weapons/melee/v_bat.mdl",
	"models/weapons/melee/v_chainsaw.mdl", "models/weapons/melee/v_cricket_bat.mdl", "models/weapons/melee/v_crowbar.mdl", "models/weapons/melee/v_golfclub.mdl", "models/weapons/melee/v_electric_guitar.mdl",
	"models/weapons/melee/v_katana.mdl", "models/v_models/v_knife_t.mdl", "models/weapons/melee/v_machete.mdl", "models/weapons/melee/v_frying_pan.mdl", "models/weapons/melee/v_tonfa.mdl",
	"models/weapons/melee/v_pitchfork.mdl", "models/weapons/melee/v_shovel.mdl"
}, g_sWeaponModelsWorld2[][] =
{
	"models/w_models/weapons/w_rifle_ak47.mdl", "models/w_models/weapons/w_autoshot_m4super.mdl", "models/w_models/weapons/w_sniper_awp.mdl", "models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_desert_rifle.mdl", "models/w_models/weapons/w_grenade_launcher.mdl", "models/w_models/weapons/w_sniper_mini14.mdl", "models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_m60.mdl", "models/w_models/weapons/w_desert_eagle.mdl", "models/w_models/weapons/w_sniper_military.mdl", "models/w_models/weapons/w_smg_mp5.mdl",
	"models/w_models/weapons/w_pistol_a.mdl", "models/w_models/weapons/w_pumpshotgun_a.mdl", "models/w_models/weapons/w_sniper_scout.mdl", "models/w_models/weapons/w_rifle_sg552.mdl",
	"models/w_models/weapons/w_smg_a.mdl", "models/w_models/weapons/w_smg_uzi.mdl", "models/w_models/weapons/w_shotgun_spas.mdl", "models/weapons/melee/w_fireaxe.mdl", "models/weapons/melee/w_bat.mdl",
	"models/weapons/melee/w_chainsaw.mdl", "models/weapons/melee/w_cricket_bat.mdl", "models/weapons/melee/w_crowbar.mdl", "models/weapons/melee/w_golfclub.mdl", "models/weapons/melee/w_electric_guitar.mdl",
	"models/weapons/melee/w_katana.mdl", "models/w_models/weapons/w_knife_t.mdl", "models/weapons/melee/w_machete.mdl", "models/weapons/melee/w_frying_pan.mdl", "models/weapons/melee/w_tonfa.mdl",
	"models/weapons/melee/w_pitchfork.mdl", "models/weapons/melee/w_shovel.mdl"
};

enum struct esGeneral
{
	ConVar g_cvMTAssaultRifleAmmo;
	ConVar g_cvMTAutoShotgunAmmo;
	ConVar g_cvMTGrenadeLauncherAmmo;
	ConVar g_cvMTHuntingRifleAmmo;
	ConVar g_cvMTShotgunAmmo;
	ConVar g_cvMTSMGAmmo;
	ConVar g_cvMTSniperRifleAmmo;
}

esGeneral g_esGeneral;

enum struct esPlayer
{
	bool g_bActivated;

	char g_sDropWeaponName[32];

	float g_flDropChance;
	float g_flDropClipChance;
	float g_flDropWeaponScale;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iDropAbility;
	int g_iDropMessage;
	int g_iDropHandPosition;
	int g_iDropMode;
	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iWeapon;
	int g_iWeaponIndex;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	char g_sDropWeaponName[32];

	float g_flDropChance;
	float g_flDropClipChance;
	float g_flDropWeaponScale;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iDropAbility;
	int g_iDropMessage;
	int g_iDropHandPosition;
	int g_iDropMode;
	int g_iHumanAbility;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	char g_sDropWeaponName[32];

	float g_flDropChance;
	float g_flDropClipChance;
	float g_flDropWeaponScale;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iDropAbility;
	int g_iDropMessage;
	int g_iDropHandPosition;
	int g_iDropMode;
	int g_iHumanAbility;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_drop", cmdDropInfo, "View information about the Drop ability.");

	g_esGeneral.g_cvMTAssaultRifleAmmo = FindConVar("ammo_assaultrifle_max");
	g_esGeneral.g_cvMTAutoShotgunAmmo = g_bSecondGame ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_esGeneral.g_cvMTGrenadeLauncherAmmo = FindConVar("ammo_grenadelauncher_max");
	g_esGeneral.g_cvMTHuntingRifleAmmo = FindConVar("ammo_huntingrifle_max");
	g_esGeneral.g_cvMTShotgunAmmo = g_bSecondGame ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_esGeneral.g_cvMTSMGAmmo = FindConVar("ammo_smg_max");
	g_esGeneral.g_cvMTSniperRifleAmmo = FindConVar("ammo_sniperrifle_max");
}

public void OnMapStart()
{
	for (int iPos = 0; iPos < sizeof(g_sMeleeScripts); iPos++)
	{
		PrecacheGeneric(g_sMeleeScripts[iPos], true);
	}

	switch (g_bSecondGame)
	{
		case true:
		{
			for (int iPos = 0; iPos < sizeof(g_sWeaponModelsWorld2); iPos++)
			{
				PrecacheModel(g_sWeaponModelsView2[iPos], true);
				PrecacheModel(g_sWeaponModelsWorld2[iPos], true);
			}
		}
		case false:
		{
			for (int iPos = 0; iPos < sizeof(g_sWeaponModelsWorld); iPos++)
			{
				PrecacheModel(g_sWeaponModelsView[iPos], true);
				PrecacheModel(g_sWeaponModelsWorld[iPos], true);
			}
		}
	}

	vReset();
}

public void OnClientPutInServer(int client)
{
	vReset2(client);
}

public void OnClientDisconnect_Post(int client)
{
	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdDropInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vDropMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vDropMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iDropMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Drop Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iDropMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iDropAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "DropDetails");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vDropMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pDrop = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "DropMenu", param1);
			pDrop.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_DROP, MT_MENU_DROP);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_DROP, false))
	{
		vDropMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_DROP, false))
	{
		FormatEx(buffer, size, "%T", "DropMenu2", client);
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
	list.PushString(MT_CONFIG_SECTION);
	list2.PushString(MT_CONFIG_SECTION2);
	list3.PushString(MT_CONFIG_SECTION3);
	list4.PushString(MT_CONFIG_SECTION4);
}

public void MT_OnCombineAbilities(int tank, int type, float random, const char[] combo, int survivor, int weapon, const char[] classname)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION4);
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_UPONDEATH && g_esCache[tank].g_iDropAbility == 1 && g_esCache[tank].g_iComboAbility == 1 && g_esPlayer[tank].g_bActivated)
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
				{
					static float flDelay;
					flDelay = MT_GetCombinationSetting(tank, 3, iPos);

					switch (flDelay)
					{
						case 0.0: vDropWeapon(tank, 0, random, iPos);
						default:
						{
							DataPack dpCombo;
							CreateDataTimer(flDelay, tTimerCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
							dpCombo.WriteCell(GetClientUserId(tank));
							dpCombo.WriteFloat(random);
							dpCombo.WriteCell(iPos);
						}
					}

					break;
				}
			}
		}
	}
}

public void MT_OnConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esAbility[iIndex].g_iAccessFlags = 0;
				g_esAbility[iIndex].g_iComboAbility = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iDropAbility = 0;
				g_esAbility[iIndex].g_iDropMessage = 0;
				g_esAbility[iIndex].g_flDropChance = 33.3;
				g_esAbility[iIndex].g_flDropClipChance = 33.3;
				g_esAbility[iIndex].g_iDropHandPosition = 0;
				g_esAbility[iIndex].g_iDropMode = 0;
				g_esAbility[iIndex].g_sDropWeaponName[0] = '\0';
				g_esAbility[iIndex].g_flDropWeaponScale = 1.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iComboAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_flOpenAreasOnly = 0.0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iDropAbility = 0;
					g_esPlayer[iPlayer].g_iDropMessage = 0;
					g_esPlayer[iPlayer].g_flDropChance = 0.0;
					g_esPlayer[iPlayer].g_flDropClipChance = 0.0;
					g_esPlayer[iPlayer].g_iDropHandPosition = 0;
					g_esPlayer[iPlayer].g_iDropMode = 0;
					g_esPlayer[iPlayer].g_sDropWeaponName[0] = '\0';
					g_esPlayer[iPlayer].g_flDropWeaponScale = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iDropAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iDropAbility, value, 0, 1);
		g_esPlayer[admin].g_iDropMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iDropMessage, value, 0, 1);
		g_esPlayer[admin].g_flDropChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropChance", "Drop Chance", "Drop_Chance", "chance", g_esPlayer[admin].g_flDropChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flDropClipChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropClipChance", "Drop Clip Chance", "Drop_Clip_Chance", "clipchance", g_esPlayer[admin].g_flDropClipChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iDropHandPosition = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropHandPosition", "Drop Hand Position", "Drop_Hand_Position", "handpos", g_esPlayer[admin].g_iDropHandPosition, value, 0, 3);
		g_esPlayer[admin].g_iDropMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropMode", "Drop Mode", "Drop_Mode", "mode", g_esPlayer[admin].g_iDropMode, value, 0, 2);
		g_esPlayer[admin].g_flDropWeaponScale = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropWeaponScale", "Drop Weapon Scale", "Drop_Weapon_Scale", "weaponscale", g_esPlayer[admin].g_flDropWeaponScale, value, 0.1, 2.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "DropWeaponName", false) || StrEqual(key, "Drop Weapon Name", false) || StrEqual(key, "Drop_Weapon_Name", false) || StrEqual(key, "weaponname", false))
			{
				strcopy(g_esPlayer[admin].g_sDropWeaponName, sizeof(esPlayer::g_sDropWeaponName), value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAbility[type].g_iComboAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_flOpenAreasOnly, value, 0.0, 999999.0);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iDropAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iDropAbility, value, 0, 1);
		g_esAbility[type].g_iDropMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iDropMessage, value, 0, 1);
		g_esAbility[type].g_flDropChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropChance", "Drop Chance", "Drop_Chance", "chance", g_esAbility[type].g_flDropChance, value, 0.0, 100.0);
		g_esAbility[type].g_flDropClipChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropClipChance", "Drop Clip Chance", "Drop_Clip_Chance", "clipchance", g_esAbility[type].g_flDropClipChance, value, 0.0, 100.0);
		g_esAbility[type].g_iDropHandPosition = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropHandPosition", "Drop Hand Position", "Drop_Hand_Position", "handpos", g_esAbility[type].g_iDropHandPosition, value, 0, 3);
		g_esAbility[type].g_iDropMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropMode", "Drop Mode", "Drop_Mode", "mode", g_esAbility[type].g_iDropMode, value, 0, 2);
		g_esAbility[type].g_flDropWeaponScale = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "DropWeaponScale", "Drop Weapon Scale", "Drop_Weapon_Scale", "weaponscale", g_esAbility[type].g_flDropWeaponScale, value, 0.1, 2.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "DropWeaponName", false) || StrEqual(key, "Drop Weapon Name", false) || StrEqual(key, "Drop_Weapon_Name", false) || StrEqual(key, "weaponname", false))
			{
				strcopy(g_esAbility[type].g_sDropWeaponName, sizeof(esAbility::g_sDropWeaponName), value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	vGetSettingValue(apply, bHuman, g_esCache[tank].g_sDropWeaponName, sizeof(esCache::g_sDropWeaponName), g_esPlayer[tank].g_sDropWeaponName, g_esAbility[type].g_sDropWeaponName);
	g_esCache[tank].g_flDropChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDropChance, g_esAbility[type].g_flDropChance);
	g_esCache[tank].g_flDropClipChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDropClipChance, g_esAbility[type].g_flDropClipChance);
	g_esCache[tank].g_flDropWeaponScale = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flDropWeaponScale, g_esAbility[type].g_flDropWeaponScale);
	g_esCache[tank].g_iDropAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDropAbility, g_esAbility[type].g_iDropAbility);
	g_esCache[tank].g_iDropMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDropMessage, g_esAbility[type].g_iDropMessage);
	g_esCache[tank].g_iDropHandPosition = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDropHandPosition, g_esAbility[type].g_iDropHandPosition);
	g_esCache[tank].g_iDropMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iDropMode, g_esAbility[type].g_iDropMode);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flOpenAreasOnly, g_esAbility[type].g_flOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveDrop(oldTank);
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vCopyStats(iBot, iTank);
			vRemoveDrop(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveDrop(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(iTank) && g_esPlayer[iTank].g_bActivated)
		{
			if (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags))
			{
				vDropWeapon(iTank, 1, GetRandomFloat(0.1, 100.0));
			}

			vReset2(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iDropAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		RequestFrame(vDropFrame, GetClientUserId(tank));
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY2)
		{
			if (g_esCache[tank].g_iDropAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bActivated)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "DropHuman2");
					case false:
					{
						RequestFrame(vDropFrame, GetClientUserId(tank));

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "DropHuman");
					}
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vDropWeapon(tank, 1, GetRandomFloat(0.1, 100.0));
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_bActivated = g_esPlayer[oldTank].g_bActivated;
	g_esPlayer[newTank].g_iWeapon = g_esPlayer[oldTank].g_iWeapon;
	g_esPlayer[newTank].g_iWeaponIndex = g_esPlayer[oldTank].g_iWeaponIndex;
}

static void vDropWeapon(int tank, int value, float random, int pos = -1)
{
	static float flChance;
	flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 1, pos) : g_esCache[tank].g_flDropChance;
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iDropAbility == 1 && random <= flChance && bIsValidEntRef(g_esPlayer[tank].g_iWeapon))
	{
		if (g_esCache[tank].g_iComboAbility == value || bIsAreaNarrow(tank, g_esCache[tank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		static char sWeapon[32];
		strcopy(sWeapon, sizeof(sWeapon), (g_bSecondGame ? g_sWeaponClasses2[g_esPlayer[tank].g_iWeaponIndex] : g_sWeaponClasses[g_esPlayer[tank].g_iWeaponIndex]));

		static float flPos[3], flAngles[3];
		GetClientEyePosition(tank, flPos);
		GetClientAbsAngles(tank, flAngles);

		if (g_esCache[tank].g_iDropMode != 2 && StrContains(sWeapon, "weapon") != -1)
		{
			static int iDrop;
			iDrop = CreateEntityByName(sWeapon);
			if (bIsValidEntity(iDrop))
			{
				TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
				DispatchSpawn(iDrop);

				static int iAmmo, iClip;
				iAmmo = 0;
				iClip = 0;
				if (StrEqual(sWeapon, "weapon_rifle") || StrEqual(sWeapon, "weapon_rifle_ak47") || StrEqual(sWeapon, "weapon_rifle_desert") || StrEqual(sWeapon, "weapon_rifle_sg552"))
				{
					iAmmo = g_esGeneral.g_cvMTAssaultRifleAmmo.IntValue;
				}
				else if (StrEqual(sWeapon, "weapon_autoshotgun") || StrEqual(sWeapon, "weapon_shotgun_spas"))
				{
					iAmmo = g_esGeneral.g_cvMTAutoShotgunAmmo.IntValue;
				}
				else if (StrEqual(sWeapon, "weapon_grenade_launcher"))
				{
					iAmmo = g_esGeneral.g_cvMTGrenadeLauncherAmmo.IntValue;
				}
				else if (StrEqual(sWeapon, "weapon_hunting_rifle"))
				{
					iAmmo = g_esGeneral.g_cvMTHuntingRifleAmmo.IntValue;
				}
				else if (StrEqual(sWeapon, "weapon_pumpshotgun") || StrEqual(sWeapon, "weapon_shotgun_chrome"))
				{
					iAmmo = g_esGeneral.g_cvMTShotgunAmmo.IntValue;
				}
				else if (StrEqual(sWeapon, "weapon_smg") || StrEqual(sWeapon, "weapon_smg_silenced") || StrEqual(sWeapon, "weapon_smg_mp5"))
				{
					iAmmo = g_esGeneral.g_cvMTSMGAmmo.IntValue;
				}
				else if (StrEqual(sWeapon, "weapon_sniper_scout") || StrEqual(sWeapon, "weapon_sniper_military") || StrEqual(sWeapon, "weapon_sniper_awp"))
				{
					iAmmo = g_esGeneral.g_cvMTSniperRifleAmmo.IntValue;
				}

				if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flDropClipChance)
				{
					iClip = iAmmo;
				}

				if (iClip > 0)
				{
					SetEntProp(iDrop, Prop_Send, "m_iClip1", iClip);
				}

				if (iAmmo > 0)
				{
					SetEntProp(iDrop, Prop_Send, "m_iExtraPrimaryAmmo", iAmmo);
				}

				if (g_esCache[tank].g_iDropMessage == 1)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Drop", sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Drop", LANG_SERVER, sTankName);
				}
			}
		}
		else if (g_esCache[tank].g_iDropMode != 1 && g_bSecondGame)
		{
			static int iDrop;
			iDrop = CreateEntityByName("weapon_melee");
			if (bIsValidEntity(iDrop))
			{
				DispatchKeyValue(iDrop, "melee_script_name", sWeapon);
				TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
				DispatchSpawn(iDrop);

				if (g_esCache[tank].g_iDropMessage == 1)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Drop2", sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Drop2", LANG_SERVER, sTankName);
				}
			}
		}
	}

	vRemoveDrop(tank);
}

static void vRemoveDrop(int tank)
{
	if (bIsValidEntRef(g_esPlayer[tank].g_iWeapon))
	{
		g_esPlayer[tank].g_iWeapon = EntRefToEntIndex(g_esPlayer[tank].g_iWeapon);
		if (bIsValidEntity(g_esPlayer[tank].g_iWeapon))
		{
			MT_HideEntity(g_esPlayer[tank].g_iWeapon, false);
			RemoveEntity(g_esPlayer[tank].g_iWeapon);
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveDrop(iPlayer);
			vReset2(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iWeapon = INVALID_ENT_REFERENCE;
	g_esPlayer[tank].g_iWeaponIndex = 0;
}

static int iGetNamedWeapon(int tank)
{
	if (g_esCache[tank].g_sDropWeaponName[0] == '\0')
	{
		return -1;
	}

	static char sName[32], sSet[2][20];
	static int iSize;
	iSize = g_bSecondGame ? sizeof(g_sWeaponClasses2) : sizeof(g_sWeaponClasses);
	for (int iPos = 0; iPos < iSize; iPos++)
	{
		strcopy(sName, sizeof(sName), (g_bSecondGame ? g_sWeaponClasses2[iPos] : g_sWeaponClasses[iPos]));
		if (StrContains(sName, "weapon_") != -1)
		{
			ExplodeString(sName, "eapon_", sSet, sizeof(sSet), sizeof(sSet[]));
			if (StrEqual(sSet[1], g_esCache[tank].g_sDropWeaponName, false))
			{
				return iPos;
			}
		}
		else if (StrEqual(sName, g_esCache[tank].g_sDropWeaponName, false))
		{
			return iPos;
		}
	}

	return -1;
}

static int iGetRandomWeapon(int tank)
{
	static int iDropValue;
	iDropValue = 0;

	switch (g_esCache[tank].g_iDropMode)
	{
		case 0: iDropValue = GetRandomInt(0, 30);
		case 1: iDropValue = GetRandomInt(0, 18);
		case 2: iDropValue = GetRandomInt(19, 30);
	}

	return g_bSecondGame ? iDropValue : GetRandomInt(0, 5);
}

public void vDropFrame(int userid)
{
	static int iTank;
	iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_flOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iDropAbility == 0 || g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return;
	}

	vRemoveDrop(iTank);

	static int iPosition, iWeapon;
	iPosition = 0 < g_esCache[iTank].g_iDropHandPosition < 3 ? g_esCache[iTank].g_iDropHandPosition : GetRandomInt(1, 2);

	iWeapon = iGetNamedWeapon(iTank);
	if (iWeapon == -1)
	{
		iWeapon = iGetRandomWeapon(iTank);
	}

	g_esPlayer[iTank].g_iWeapon = CreateEntityByName("prop_dynamic_override");
	if (bIsValidEntity(g_esPlayer[iTank].g_iWeapon))
	{
		static float flPos[3], flAngles[3], flScale;

		SetEntityModel(g_esPlayer[iTank].g_iWeapon, (g_bSecondGame ? g_sWeaponModelsWorld2[iWeapon] : g_sWeaponModelsWorld[iWeapon]));
		TeleportEntity(g_esPlayer[iTank].g_iWeapon, flPos, flAngles, NULL_VECTOR);
		DispatchSpawn(g_esPlayer[iTank].g_iWeapon);
		vSetEntityParent(g_esPlayer[iTank].g_iWeapon, iTank, true);

		static char sPosition[32];

		switch (iPosition)
		{
			case 1: sPosition = "rhand";
			case 2: sPosition = "lhand";
		}

		SetVariantString(sPosition);
		AcceptEntityInput(g_esPlayer[iTank].g_iWeapon, "SetParentAttachment");

		switch (g_bSecondGame)
		{
			case true:
			{
				if (iWeapon == 21)
				{
					switch (iPosition)
					{
						case 1:
						{
							vSetVector(flPos, -23.0, -30.0, -5.0);
							vSetVector(flAngles, 0.0, 60.0, 180.0);
						}
						case 2:
						{
							vSetVector(flPos, -9.0, -32.0, -1.0);
							vSetVector(flAngles, 0.0, 60.0, 180.0);
						}
					}
				}
				else if (iWeapon >= 0)
				{
					switch (iPosition)
					{
						case 1:
						{
							vSetVector(flPos, 1.0, -5.0, 3.0);
							vSetVector(flAngles, 0.0, -90.0, 90.0);
						}
						case 2:
						{
							vSetVector(flPos, 4.0, -5.0, -3.0);
							vSetVector(flAngles, 0.0, -90.0, 90.0);
						}
					}
				}
				else
				{
					switch (iPosition)
					{
						case 1:
						{
							vSetVector(flPos, -4.0, 0.0, 3.0);
							vSetVector(flAngles, 0.0, -11.0, 100.0);
						}
						case 2:
						{
							vSetVector(flPos, 4.0, 0.0, -3.0);
							vSetVector(flAngles, 0.0, -11.0, 100.0);
						}
					}
				}

				flScale = 1.5 * g_esCache[iTank].g_flDropWeaponScale;
			}
			case false:
			{
				switch (iPosition)
				{
					case 1:
					{
						vSetVector(flPos, 1.0, -5.0, 3.0);
						vSetVector(flAngles, 0.0, -90.0, 90.0);
					}
					case 2:
					{
						vSetVector(flPos, 4.0, -5.0, -3.0);
						vSetVector(flAngles, 0.0, -90.0, 90.0);
					}
				}
			}
		}

		SetEntProp(g_esPlayer[iTank].g_iWeapon, Prop_Send, "m_CollisionGroup", 2);

		if (g_bSecondGame)
		{
			SetEntPropFloat(g_esPlayer[iTank].g_iWeapon, Prop_Send, "m_flModelScale", flScale);
		}

		g_esPlayer[iTank].g_bActivated = true;
		g_esPlayer[iTank].g_iWeaponIndex = iWeapon;
		MT_HideEntity(g_esPlayer[iTank].g_iWeapon, true);
		g_esPlayer[iTank].g_iWeapon = EntIndexToEntRef(g_esPlayer[iTank].g_iWeapon);

		DataPack dpRender;
		CreateDataTimer(0.1, tTimerRenderWeapon, dpRender, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRender.WriteCell(g_esPlayer[iTank].g_iWeapon);
		dpRender.WriteCell(GetClientUserId(iTank));
	}
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iDropAbility == 0 || g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vDropWeapon(iTank, 0, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerRenderWeapon(Handle timer, DataPack pack)
{
	pack.Reset();

	int iWeapon = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iWeapon == INVALID_ENT_REFERENCE || !bIsValidEntity(iWeapon) || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iDropAbility == 0 || !g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	int iRed = 0, iGreen = 0, iBlue = 0, iAlpha = 0;
	GetEntityRenderColor(iTank, iRed, iGreen, iBlue, iAlpha);
	SetEntityRenderMode(iWeapon, GetEntityRenderMode(iTank));
	SetEntityRenderColor(iWeapon, _, _, _, iAlpha);

	return Plugin_Continue;
}