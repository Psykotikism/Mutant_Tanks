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

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

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

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Drop Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MELEE_AXE_V "models/weapons/melee/v_fireaxe.mdl"
#define MELEE_AXE_W "models/weapons/melee/w_fireaxe.mdl"
#define MELEE_BAT_V "models/weapons/melee/v_bat.mdl"
#define MELEE_BAT_W "models/weapons/melee/w_bat.mdl"
#define MELEE_CHAINSAW_V "models/weapons/melee/v_chainsaw.mdl"
#define MELEE_CHAINSAW_W "models/weapons/melee/w_chainsaw.mdl"
#define MELEE_CRICKET_V "models/weapons/melee/v_cricket_bat.mdl"
#define MELEE_CRICKET_W "models/weapons/melee/w_cricket_bat.mdl"
#define MELEE_CROWBAR_V "models/weapons/melee/v_crowbar.mdl"
#define MELEE_CROWBAR_W "models/weapons/melee/w_crowbar.mdl"
#define MELEE_GOLFCLUB_V "models/weapons/melee/v_golfclub.mdl"
#define MELEE_GOLFCLUB_W "models/weapons/melee/w_golfclub.mdl"
#define MELEE_GUITAR_V "models/weapons/melee/v_electric_guitar.mdl"
#define MELEE_GUITAR_W "models/weapons/melee/w_electric_guitar.mdl"
#define MELEE_KATANA_V "models/weapons/melee/v_katana.mdl"
#define MELEE_KATANA_W "models/weapons/melee/w_katana.mdl"
#define MELEE_KNIFE_V "models/v_models/v_knife_t.mdl"
#define MELEE_KNIFE_W "models/w_models/weapons/w_knife_t.mdl"
#define MELEE_MACHETE_V "models/weapons/melee/v_machete.mdl"
#define MELEE_MACHETE_W "models/weapons/melee/w_machete.mdl"
#define MELEE_PAN_V "models/weapons/melee/v_frying_pan.mdl"
#define MELEE_PAN_W "models/weapons/melee/w_frying_pan.mdl"
#define MELEE_TONFA_V "models/weapons/melee/v_tonfa.mdl"
#define MELEE_TONFA_W "models/weapons/melee/w_tonfa.mdl"

#define SCRIPT_AXE "scripts/melee/fireaxe.txt"
#define SCRIPT_BAT "scripts/melee/baseball_bat.txt"
#define SCRIPT_CRICKET "scripts/melee/cricket_bat.txt"
#define SCRIPT_CROWBAR "scripts/melee/crowbar.txt"
#define SCRIPT_GOLFCLUB "scripts/melee/golfclub.txt"
#define SCRIPT_GUITAR "scripts/melee/electric_guitar.txt"
#define SCRIPT_KATANA "scripts/melee/katana.txt"
#define SCRIPT_KNIFE "scripts/melee/knife.txt"
#define SCRIPT_MACHETE "scripts/melee/machete.txt"
#define SCRIPT_PAN "scripts/melee/frying_pan.txt"
#define SCRIPT_TONFA "scripts/melee/tonfa.txt"

#define WEAPON_AUTO_V "models/v_models/weapons/v_autoshot_m4super.mdl"
#define WEAPON_AUTO_W "models/w_models/weapons/w_autoshot_m4super.mdl"
#define WEAPON_HUNT_V "models/v_models/weapons/v_sniper_mini14.mdl"
#define WEAPON_HUNT_W "models/w_models/weapons/w_sniper_mini14.mdl"
#define WEAPON_M16_V "models/v_models/weapons/v_rifle_m16a2.mdl"
#define WEAPON_M16_W "models/w_models/weapons/w_rifle_m16a2.mdl"
#define WEAPON_PISTOL_V "models/v_models/weapons/v_pistol_1911.mdl"
#define WEAPON_PISTOL_W "models/w_models/weapons/w_pistol_1911.mdl"
#define WEAPON_PUMP_V "models/v_models/weapons/v_pumpshotgun_a.mdl"
#define WEAPON_PUMP_W "models/w_models/weapons/w_pumpshotgun_a.mdl"
#define WEAPON_SMG_V "models/v_models/weapons/v_smg_uzi.mdl"
#define WEAPON_SMG_W "models/w_models/weapons/w_smg_uzi.mdl"

#define WEAPON2_AK47_V "models/v_models/weapons/v_rifle_ak47.mdl"
#define WEAPON2_AK47_W "models/w_models/weapons/w_rifle_ak47.mdl"
#define WEAPON2_AUTO_V "models/v_models/weapons/v_autoshot_m4super.mdl"
#define WEAPON2_AUTO_W "models/w_models/weapons/w_autoshot_m4super.mdl"
#define WEAPON2_AWP_V "models/v_models/weapons/v_sniper_awp.mdl"
#define WEAPON2_AWP_W "models/w_models/weapons/w_sniper_awp.mdl"
#define WEAPON2_CHROME_V "models/v_models/weapons/v_shotgun.mdl"
#define WEAPON2_CHROME_W "models/w_models/weapons/w_shotgun.mdl"
#define WEAPON2_DESERT_V "models/v_models/weapons/v_desert_rifle.mdl"
#define WEAPON2_DESERT_W "models/w_models/weapons/w_desert_rifle.mdl"
#define WEAPON2_GRENADE_V "models/v_models/weapons/v_grenade_launcher.mdl"
#define WEAPON2_GRENADE_W "models/w_models/weapons/w_grenade_launcher.mdl"
#define WEAPON2_HUNT_V "models/v_models/weapons/v_sniper_mini14.mdl"
#define WEAPON2_HUNT_W "models/w_models/weapons/w_sniper_mini14.mdl"
#define WEAPON2_M16_V "models/v_models/weapons/v_rifle_m16a2.mdl"
#define WEAPON2_M16_W "models/w_models/weapons/w_rifle_m16a2.mdl"
#define WEAPON2_M60_V "models/v_models/weapons/v_m60.mdl"
#define WEAPON2_M60_W "models/w_models/weapons/w_m60.mdl"
#define WEAPON2_MAGNUM_V "models/v_models/weapons/v_desert_eagle.mdl"
#define WEAPON2_MAGNUM_W "models/w_models/weapons/w_desert_eagle.mdl"
#define WEAPON2_MILITARY_V "models/v_models/weapons/v_sniper_military.mdl"
#define WEAPON2_MILITARY_W "models/w_models/weapons/w_sniper_military.mdl"
#define WEAPON2_MP5_V "models/v_models/weapons/v_smg_mp5.mdl"
#define WEAPON2_MP5_W "models/w_models/weapons/w_smg_mp5.mdl"
#define WEAPON2_PISTOL_V "models/v_models/weapons/v_pistol_a.mdl"
#define WEAPON2_PISTOL_W "models/w_models/weapons/w_pistol_a.mdl"
#define WEAPON2_PUMP_V "models/v_models/weapons/v_pumpshotgun_a.mdl"
#define WEAPON2_PUMP_W "models/w_models/weapons/w_pumpshotgun_a.mdl"
#define WEAPON2_SCOUT_V "models/v_models/weapons/v_sniper_scout.mdl"
#define WEAPON2_SCOUT_W "models/w_models/weapons/w_sniper_scout.mdl"
#define WEAPON2_SG552_V "models/v_models/weapons/v_rifle_sg552.mdl"
#define WEAPON2_SG552_W "models/w_models/weapons/w_rifle_sg552.mdl"
#define WEAPON2_SILENCED_V "models/v_models/weapons/v_smg_a.mdl"
#define WEAPON2_SILENCED_W "models/w_models/weapons/w_smg_a.mdl"
#define WEAPON2_SMG_V "models/v_models/weapons/v_smg_uzi.mdl"
#define WEAPON2_SMG_W "models/w_models/weapons/w_smg_uzi.mdl"
#define WEAPON2_SPAS_V "models/v_models/weapons/v_shotgun_spas.mdl"
#define WEAPON2_SPAS_W "models/w_models/weapons/w_shotgun_spas.mdl"

#define MT_MENU_DROP "Drop Ability"

bool g_bCloneInstalled, g_bDrop[MAXPLAYERS + 1];

char g_sWeaponClass[32][128], g_sWeaponModel[32][128];

ConVar g_cvMTAssaultRifleAmmo, g_cvMTAutoShotgunAmmo, g_cvMTGrenadeLauncherAmmo, g_cvMTHuntingRifleAmmo, g_cvMTShotgunAmmo, g_cvMTSMGAmmo, g_cvMTSniperRifleAmmo;

float g_flDropChance[MT_MAXTYPES + 1], g_flDropClipChance[MT_MAXTYPES + 1], g_flDropWeaponScale[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iDrop[MAXPLAYERS + 1], g_iDropAbility[MT_MAXTYPES + 1], g_iDropMessage[MT_MAXTYPES + 1], g_iDropMode[MT_MAXTYPES + 1], g_iDropWeapon[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_drop", cmdDropInfo, "View information about the Drop ability.");

	g_cvMTAssaultRifleAmmo = FindConVar("ammo_assaultrifle_max");
	g_cvMTAutoShotgunAmmo = bIsValidGame() ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvMTGrenadeLauncherAmmo = FindConVar("ammo_grenadelauncher_max");
	g_cvMTHuntingRifleAmmo = FindConVar("ammo_huntingrifle_max");
	g_cvMTShotgunAmmo = bIsValidGame() ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvMTSMGAmmo = FindConVar("ammo_smg_max");
	g_cvMTSniperRifleAmmo = FindConVar("ammo_sniperrifle_max");
}

public void OnMapStart()
{
	PrecacheModel(MELEE_AXE_V, true);
	PrecacheModel(MELEE_AXE_W, true);
	PrecacheModel(MELEE_CHAINSAW_V, true);
	PrecacheModel(MELEE_CHAINSAW_W, true);
	PrecacheModel(MELEE_CRICKET_V, true);
	PrecacheModel(MELEE_CRICKET_W, true);
	PrecacheModel(MELEE_CROWBAR_V, true);
	PrecacheModel(MELEE_CROWBAR_W, true);
	PrecacheModel(MELEE_GOLFCLUB_V, true);
	PrecacheModel(MELEE_GOLFCLUB_W, true);
	PrecacheModel(MELEE_GUITAR_V, true);
	PrecacheModel(MELEE_GUITAR_W, true);
	PrecacheModel(MELEE_KATANA_V, true);
	PrecacheModel(MELEE_KATANA_W, true);
	PrecacheModel(MELEE_KNIFE_V, true);
	PrecacheModel(MELEE_KNIFE_W, true);
	PrecacheModel(MELEE_MACHETE_V, true);
	PrecacheModel(MELEE_MACHETE_W, true);
	PrecacheModel(MELEE_PAN_V, true);
	PrecacheModel(MELEE_PAN_W, true);
	PrecacheModel(MELEE_TONFA_V, true);
	PrecacheModel(MELEE_TONFA_W, true);

	PrecacheGeneric(SCRIPT_AXE, true);
	PrecacheGeneric(SCRIPT_BAT, true);
	PrecacheGeneric(SCRIPT_CRICKET, true);
	PrecacheGeneric(SCRIPT_CROWBAR, true);
	PrecacheGeneric(SCRIPT_GOLFCLUB, true);
	PrecacheGeneric(SCRIPT_GUITAR, true);
	PrecacheGeneric(SCRIPT_KATANA, true);
	PrecacheGeneric(SCRIPT_KNIFE, true);
	PrecacheGeneric(SCRIPT_MACHETE, true);
	PrecacheGeneric(SCRIPT_PAN, true);
	PrecacheGeneric(SCRIPT_TONFA, true);

	PrecacheModel(WEAPON2_AWP_V, true);
	PrecacheModel(WEAPON2_AWP_W, true);
	PrecacheModel(WEAPON2_GRENADE_V, true);
	PrecacheModel(WEAPON2_GRENADE_W, true);
	PrecacheModel(WEAPON2_M60_V, true);
	PrecacheModel(WEAPON2_M60_W, true);
	PrecacheModel(WEAPON2_MP5_V, true);
	PrecacheModel(WEAPON2_MP5_W, true);
	PrecacheModel(WEAPON2_SCOUT_V, true);
	PrecacheModel(WEAPON2_SCOUT_W, true);
	PrecacheModel(WEAPON2_SG552_V, true);
	PrecacheModel(WEAPON2_SG552_W, true);

	vReset();

	switch (bIsValidGame())
	{
		case true:
		{
			g_sWeaponModel[1] = WEAPON2_AK47_W;
			g_sWeaponModel[2] = WEAPON2_AUTO_W;
			g_sWeaponModel[3] = WEAPON2_AWP_W;
			g_sWeaponModel[4] = WEAPON2_CHROME_W;
			g_sWeaponModel[5] = WEAPON2_DESERT_W;
			g_sWeaponModel[6] = WEAPON2_GRENADE_W;
			g_sWeaponModel[7] = WEAPON2_HUNT_W;
			g_sWeaponModel[8] = WEAPON2_M16_W;
			g_sWeaponModel[9] = WEAPON2_M60_W;
			g_sWeaponModel[10] = WEAPON2_MAGNUM_W;
			g_sWeaponModel[11] = WEAPON2_MILITARY_W;
			g_sWeaponModel[12] = WEAPON2_MP5_W;
			g_sWeaponModel[13] = WEAPON2_PUMP_W;
			g_sWeaponModel[14] = WEAPON2_PUMP_W;
			g_sWeaponModel[15] = WEAPON2_SCOUT_W;
			g_sWeaponModel[16] = WEAPON2_SG552_W;
			g_sWeaponModel[17] = WEAPON2_SILENCED_W;
			g_sWeaponModel[18] = WEAPON2_SMG_W;
			g_sWeaponModel[19] = WEAPON2_SPAS_W;
			g_sWeaponModel[20] = MELEE_AXE_W;
			g_sWeaponModel[21] = MELEE_BAT_W;
			g_sWeaponModel[22] = MELEE_CHAINSAW_W;
			g_sWeaponModel[23] = MELEE_CRICKET_W;
			g_sWeaponModel[24] = MELEE_CROWBAR_W;
			g_sWeaponModel[25] = MELEE_GOLFCLUB_W;
			g_sWeaponModel[26] = MELEE_GUITAR_W;
			g_sWeaponModel[27] = MELEE_KATANA_W;
			g_sWeaponModel[28] = MELEE_KNIFE_W;
			g_sWeaponModel[29] = MELEE_MACHETE_W;
			g_sWeaponModel[30] = MELEE_PAN_W;
			g_sWeaponModel[31] = MELEE_TONFA_W;

			g_sWeaponClass[1] = "weapon_rifle_ak47";
			g_sWeaponClass[2] = "weapon_autoshotgun";
			g_sWeaponClass[3] = "weapon_sniper_awp";
			g_sWeaponClass[4] = "weapon_shotgun_chrome";
			g_sWeaponClass[5] = "weapon_rifle_desert";
			g_sWeaponClass[6] = "weapon_grenade_launcher";
			g_sWeaponClass[7] = "weapon_hunting_rifle";
			g_sWeaponClass[8] = "weapon_rifle";
			g_sWeaponClass[9] = "weapon_rifle_m60";
			g_sWeaponClass[10] = "weapon_pistol_magnum";
			g_sWeaponClass[11] = "weapon_sniper_military";
			g_sWeaponClass[12] = "weapon_smg_mp5";
			g_sWeaponClass[13] = "weapon_pistol";
			g_sWeaponClass[14] = "weapon_pumpshotgun";
			g_sWeaponClass[15] = "weapon_sniper_scout";
			g_sWeaponClass[16] = "weapon_rifle_sg552";
			g_sWeaponClass[17] = "weapon_smg_silenced";
			g_sWeaponClass[18] = "weapon_smg";
			g_sWeaponClass[19] = "weapon_shotgun_spas";
			g_sWeaponClass[20] = "fireaxe";
			g_sWeaponClass[21] = "baseball_bat";
			g_sWeaponClass[22] = "weapon_chainsaw";
			g_sWeaponClass[23] = "cricket_bat";
			g_sWeaponClass[24] = "crowbar";
			g_sWeaponClass[25] = "golfclub";
			g_sWeaponClass[26] = "electric_guitar";
			g_sWeaponClass[27] = "katana";
			g_sWeaponClass[28] = "knife";
			g_sWeaponClass[29] = "machete";
			g_sWeaponClass[30] = "frying_pan";
			g_sWeaponClass[31] = "tonfa";
		}
		case false:
		{
			g_sWeaponModel[1] = WEAPON_AUTO_W;
			g_sWeaponModel[2] = WEAPON_HUNT_W;
			g_sWeaponModel[3] = WEAPON_M16_W;
			g_sWeaponModel[4] = WEAPON_PISTOL_W;
			g_sWeaponModel[5] = WEAPON_PUMP_W;
			g_sWeaponModel[6] = WEAPON_SMG_W;

			g_sWeaponClass[1] = "weapon_autoshotgun";
			g_sWeaponClass[2] = "weapon_hunting_rifle";
			g_sWeaponClass[3] = "weapon_rifle";
			g_sWeaponClass[4] = "weapon_pistol";
			g_sWeaponClass[5] = "weapon_pumpshotgun";
			g_sWeaponClass[6] = "weapon_smg";
		}
	}
}

public void OnClientPutInServer(int client)
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iDropAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "DropDetails");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vDropMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "DropMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
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
	menu.AddItem(MT_MENU_DROP, MT_MENU_DROP);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_DROP, false))
	{
		vDropMenu(client, 0);
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
		g_iDropAbility[iIndex] = 0;
		g_iDropMessage[iIndex] = 0;
		g_flDropChance[iIndex] = 33.3;
		g_flDropClipChance[iIndex] = 33.3;
		g_iDropMode[iIndex] = 0;
		g_flDropWeaponScale[iIndex] = 1.0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "dropability", false) || StrEqual(subsection, "drop ability", false) || StrEqual(subsection, "drop_ability", false) || StrEqual(subsection, "drop", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		MT_FindAbility(type, 11, bHasAbilities(subsection, "dropability", "drop ability", "drop_ability", "drop"));
		g_iHumanAbility[type] = iGetValue(subsection, "dropability", "drop ability", "drop_ability", "drop", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iDropAbility[type] = iGetValue(subsection, "dropability", "drop ability", "drop_ability", "drop", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iDropAbility[type], value, 0, 1);
		g_iDropMessage[type] = iGetValue(subsection, "dropability", "drop ability", "drop_ability", "drop", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iDropMessage[type], value, 0, 1);
		g_flDropChance[type] = flGetValue(subsection, "dropability", "drop ability", "drop_ability", "drop", key, "DropChance", "Drop Chance", "Drop_Chance", "chance", g_flDropChance[type], value, 0.0, 100.0);
		g_flDropClipChance[type] = flGetValue(subsection, "dropability", "drop ability", "drop_ability", "drop", key, "DropClipChance", "Drop Clip Chance", "Drop_Clip_Chance", "clipchance", g_flDropClipChance[type], value, 0.0, 100.0);
		g_iDropMode[type] = iGetValue(subsection, "dropability", "drop ability", "drop_ability", "drop", key, "DropMode", "Drop Mode", "Drop_Mode", "mode", g_iDropMode[type], value, 0, 2);
		g_flDropWeaponScale[type] = flGetValue(subsection, "dropability", "drop ability", "drop_ability", "drop", key, "DropWeaponScale", "Drop Weapon Scale", "Drop_Weapon_Scale", "weaponscale", g_flDropWeaponScale[type], value, 1.0, 2.0);

		if (StrEqual(subsection, "dropability", false) || StrEqual(subsection, "drop ability", false) || StrEqual(subsection, "drop_ability", false) || StrEqual(subsection, "drop", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}
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
			vRemoveDrop(iBot);

			vReset2(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vRemoveDrop(iTank);

			vReset2(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_bDrop[iTank])
		{
			if (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank))
			{
				vDropWeapon(iTank);
			}

			vReset2(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iDropAbility[MT_GetTankType(tank)] == 1 && !g_bDrop[tank])
	{
		g_bDrop[tank] = true;

		CreateTimer(1.0, tTimerDrop, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY2 == MT_SPECIAL_KEY2)
		{
			if (g_iDropAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_bDrop[tank])
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "DropHuman2");
					case false:
					{
						g_bDrop[tank] = true;

						CreateTimer(1.0, tTimerDrop, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "DropHuman");
					}
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vDropWeapon(tank);

	if (!revert)
	{
		g_bDrop[tank] = false;
	}
}

static void vDropWeapon(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iDropAbility[MT_GetTankType(tank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flDropChance[MT_GetTankType(tank)] && bIsValidEntity(g_iDrop[tank]))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		float flPos[3], flAngles[3];
		GetClientEyePosition(tank, flPos);
		GetClientAbsAngles(tank, flAngles);

		if (g_iDropMode[MT_GetTankType(tank)] != 2 && StrContains(g_sWeaponClass[g_iDropWeapon[tank]], "weapon") != -1)
		{
			int iDrop = CreateEntityByName(g_sWeaponClass[g_iDropWeapon[tank]]);
			if (bIsValidEntity(iDrop))
			{
				TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
				DispatchSpawn(iDrop);

				if (bIsValidGame())
				{
					SetEntPropFloat(iDrop , Prop_Send, "m_flModelScale", g_flDropWeaponScale[MT_GetTankType(tank)]);
				}

				int iAmmo, iClip;
				if (StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_rifle") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_rifle_ak47") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_rifle_desert") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_rifle_sg552"))
				{
					iAmmo = g_cvMTAssaultRifleAmmo.IntValue;
				}
				else if (StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_autoshotgun") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_shotgun_spas"))
				{
					iAmmo = g_cvMTAutoShotgunAmmo.IntValue;
				}
				else if (StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_grenade_launcher"))
				{
					iAmmo = g_cvMTGrenadeLauncherAmmo.IntValue;
				}
				else if (StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_hunting_rifle"))
				{
					iAmmo = g_cvMTHuntingRifleAmmo.IntValue;
				}
				else if (StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_pumpshotgun") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_shotgun_chrome"))
				{
					iAmmo = g_cvMTShotgunAmmo.IntValue;
				}
				else if (StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_smg") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_smg_silenced") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_smg_mp5"))
				{
					iAmmo = g_cvMTSMGAmmo.IntValue;
				}
				else if (StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_sniper_scout") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_sniper_military") || StrEqual(g_sWeaponClass[g_iDropWeapon[tank]], "weapon_sniper_awp"))
				{
					iAmmo = g_cvMTSniperRifleAmmo.IntValue;
				}

				if (GetRandomFloat(0.1, 100.0) <= g_flDropClipChance[MT_GetTankType(tank)])
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

				if (g_iDropMessage[MT_GetTankType(tank)] == 1)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Drop", sTankName);
				}
			}
		}
		else if (g_iDropMode[MT_GetTankType(tank)] != 1 && bIsValidGame())
		{
			int iDrop = CreateEntityByName("weapon_melee");
			if (bIsValidEntity(iDrop))
			{
				DispatchKeyValue(iDrop, "melee_script_name", g_sWeaponClass[g_iDropWeapon[tank]]);
				TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
				DispatchSpawn(iDrop);
				SetEntPropFloat(iDrop, Prop_Send, "m_flModelScale", g_flDropWeaponScale[MT_GetTankType(tank)]);

				if (g_iDropMessage[MT_GetTankType(tank)] == 1)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Drop2", sTankName);
				}
			}
		}
	}

	vRemoveDrop(tank);
}

static void vRemoveDrop(int tank)
{
	if (bIsValidEntity(g_iDrop[tank]))
	{
		MT_HideEntity(g_iDrop[tank], false);
		RemoveEntity(g_iDrop[tank]);
	}

	g_iDrop[tank] = INVALID_ENT_REFERENCE;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vReset2(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bDrop[tank] = false;
	g_iDrop[tank] = INVALID_ENT_REFERENCE;
	g_iDropWeapon[tank] = 0;
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
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iAbilityFlags))
		{
			return false;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iGlobalFlags))
		{
			return false;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientTypeFlags & iAbilityFlags))
		{
			return false;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientGlobalFlags & iAbilityFlags))
		{
			return false;
		}
	}

	return true;
}

public Action tTimerDrop(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || g_iDropAbility[MT_GetTankType(iTank)] == 0 || !g_bDrop[iTank])
	{
		g_bDrop[iTank] = false;

		return Plugin_Stop;
	}

	vRemoveDrop(iTank);

	int iDropValue, iPosition;

	switch (g_iDropMode[MT_GetTankType(iTank)])
	{
		case 0: iDropValue = GetRandomInt(1, 31);
		case 1: iDropValue = GetRandomInt(1, 19);
		case 2: iDropValue = GetRandomInt(20, 31);
	}

	switch (GetRandomInt(1, 2))
	{
		case 1: iPosition = 1;
		case 2: iPosition = 2;
	}

	g_iDrop[iTank] = CreateEntityByName("prop_dynamic_override");
	if (bIsValidEntity(g_iDrop[iTank]))
	{
		float flPos[3], flAngles[3], flScale;
		int iWeapon = bIsValidGame() ? iDropValue : GetRandomInt(1, 6);

		SetEntityModel(g_iDrop[iTank], g_sWeaponModel[iWeapon]);
		TeleportEntity(g_iDrop[iTank], flPos, flAngles, NULL_VECTOR);
		DispatchSpawn(g_iDrop[iTank]);
		vSetEntityParent(g_iDrop[iTank], iTank, true);

		char sPosition[32];

		switch (iPosition)
		{
			case 1: sPosition = "rhand";
			case 2: sPosition = "lhand";
		}

		SetVariantString(sPosition);
		AcceptEntityInput(g_iDrop[iTank], "SetParentAttachment");

		switch (bIsValidGame())
		{
			case true:
			{
				if (iWeapon == 22)
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
				else if (iWeapon >= 1)
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

				flScale = 2.5;

				switch (iWeapon)
				{
					case 29: flScale = 2.0;
					case 21: flScale = 1.7;
					case 30: flScale = 2.3;
					case 26: flScale = 3.0;
					case 22: flScale = 4.0;
					case 27: flScale = 3.5;
				}

				flScale *= g_flDropWeaponScale[MT_GetTankType(iTank)];
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

		SetEntProp(g_iDrop[iTank], Prop_Send, "m_CollisionGroup", 2);

		if (bIsValidGame())
		{
			SetEntPropFloat(g_iDrop[iTank] , Prop_Send, "m_flModelScale", flScale);
		}

		g_iDropWeapon[iTank] = iWeapon;
		MT_HideEntity(g_iDrop[iTank], true);
	}

	return Plugin_Continue;
}