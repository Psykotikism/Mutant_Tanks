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

// Super Tanks++: Drop Ability
#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Drop Ability",
	author = ST_AUTHOR,
	description = "The Super Tank drops weapons upon death.",
	version = ST_VERSION,
	url = ST_URL
};

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

bool g_bCloneInstalled, g_bDrop[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sWeaponClass[32][128], g_sWeaponModel[32][128];

ConVar g_cvSTAssaultRifleAmmo, g_cvSTAutoShotgunAmmo, g_cvSTGrenadeLauncherAmmo, g_cvSTHuntingRifleAmmo, g_cvSTShotgunAmmo, g_cvSTSMGAmmo, g_cvSTSniperRifleAmmo;

float g_flDropChance[ST_MAXTYPES + 1], g_flDropChance2[ST_MAXTYPES + 1], g_flDropClipChance[ST_MAXTYPES + 1], g_flDropClipChance2[ST_MAXTYPES + 1], g_flDropWeaponScale[ST_MAXTYPES + 1], g_flDropWeaponScale2[ST_MAXTYPES + 1];

int g_iDrop[MAXPLAYERS + 1], g_iDropAbility[ST_MAXTYPES + 1], g_iDropAbility2[ST_MAXTYPES + 1], g_iDropMessage[ST_MAXTYPES + 1], g_iDropMessage2[ST_MAXTYPES + 1], g_iDropMode[ST_MAXTYPES + 1], g_iDropMode2[ST_MAXTYPES + 1], g_iDropWeapon[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Drop Ability only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

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
	LoadTranslations("super_tanks++.phrases");

	g_cvSTAssaultRifleAmmo = FindConVar("ammo_assaultrifle_max");
	g_cvSTAutoShotgunAmmo = bIsValidGame() ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTGrenadeLauncherAmmo = FindConVar("ammo_grenadelauncher_max");
	g_cvSTHuntingRifleAmmo = FindConVar("ammo_huntingrifle_max");
	g_cvSTShotgunAmmo = bIsValidGame() ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTSMGAmmo = FindConVar("ammo_smg_max");
	g_cvSTSniperRifleAmmo = FindConVar("ammo_sniperrifle_max");
}

public void OnMapStart()
{
	vReset();

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

	if (bIsValidGame())
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
	else
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

public void OnClientPutInServer(int client)
{
	vResetDrop(client);
}

public void OnMapEnd()
{
	vReset();
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iDropAbility[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", 0);
				g_iDropAbility[iIndex] = iClamp(g_iDropAbility[iIndex], 0, 1);
				g_iDropMessage[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Message", 0);
				g_iDropMessage[iIndex] = iClamp(g_iDropMessage[iIndex], 0, 1);
				g_flDropChance[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Chance", 33.3);
				g_flDropChance[iIndex] = flClamp(g_flDropChance[iIndex], 0.1, 100.0);
				g_flDropClipChance[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Clip Chance", 33.3);
				g_flDropClipChance[iIndex] = flClamp(g_flDropClipChance[iIndex], 0.1, 100.0);
				g_iDropMode[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Mode", 0);
				g_iDropMode[iIndex] = iClamp(g_iDropMode[iIndex], 0, 2);
				g_flDropWeaponScale[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", 1.0);
				g_flDropWeaponScale[iIndex] = flClamp(g_flDropWeaponScale[iIndex], 1.0, 2.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iDropAbility2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", g_iDropAbility[iIndex]);
				g_iDropAbility2[iIndex] = iClamp(g_iDropAbility2[iIndex], 0, 1);
				g_iDropMessage2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Message", g_iDropMessage[iIndex]);
				g_iDropMessage2[iIndex] = iClamp(g_iDropMessage2[iIndex], 0, 1);
				g_flDropChance2[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Chance", g_flDropChance[iIndex]);
				g_flDropChance2[iIndex] = flClamp(g_flDropChance2[iIndex], 0.1, 100.0);
				g_flDropClipChance2[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Clip Chance", g_flDropClipChance[iIndex]);
				g_flDropClipChance2[iIndex] = flClamp(g_flDropClipChance2[iIndex], 0.1, 100.0);
				g_iDropMode2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Mode", g_iDropMode[iIndex]);
				g_iDropMode2[iIndex] = iClamp(g_iDropMode2[iIndex], 0, 2);
				g_flDropWeaponScale2[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", g_flDropWeaponScale[iIndex]);
				g_flDropWeaponScale2[iIndex] = flClamp(g_flDropWeaponScale2[iIndex], 1.0, 2.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);

		float flDropChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flDropChance[ST_TankType(iTank)] : g_flDropChance2[ST_TankType(iTank)];

		if (iDropAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flDropChance && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsValidEntity(g_iDrop[iTank]))
		{
			float flPos[3], flAngles[3];
			int iDropMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropMessage[ST_TankType(iTank)] : g_iDropMessage2[ST_TankType(iTank)];

			GetClientEyePosition(iTank, flPos);
			GetClientAbsAngles(iTank, flAngles);

			if (iDropMode(iTank) != 2 && StrContains(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon") != -1)
			{
				int iDrop = CreateEntityByName(g_sWeaponClass[g_iDropWeapon[iTank]]);
				if (bIsValidEntity(iDrop))
				{
					TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
					DispatchSpawn(iDrop);

					if (bIsValidGame())
					{
						SetEntPropFloat(iDrop , Prop_Send, "m_flModelScale", flDropWeaponScale(iTank));
					}

					int iAmmo, iClip;
					if (StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_ak47") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_desert") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_sg552"))
					{
						iAmmo = g_cvSTAssaultRifleAmmo.IntValue;
					}
					else if (StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_autoshotgun") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_shotgun_spas"))
					{
						iAmmo = g_cvSTAutoShotgunAmmo.IntValue;
					}
					else if (StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_grenade_launcher"))
					{
						iAmmo = g_cvSTGrenadeLauncherAmmo.IntValue;
					}
					else if (StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_hunting_rifle"))
					{
						iAmmo = g_cvSTHuntingRifleAmmo.IntValue;
					}
					else if (StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_pumpshotgun") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_shotgun_chrome"))
					{
						iAmmo = g_cvSTShotgunAmmo.IntValue;
					}
					else if (StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg_silenced") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg_mp5"))
					{
						iAmmo = g_cvSTSMGAmmo.IntValue;
					}
					else if (StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_scout") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_military") || StrEqual(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_awp"))
					{
						iAmmo = g_cvSTSniperRifleAmmo.IntValue;
					}

					float flDropClipChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flDropClipChance[ST_TankType(iTank)] : g_flDropClipChance2[ST_TankType(iTank)];
					if (GetRandomFloat(0.1, 100.0) <= flDropClipChance)
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

					if (iDropMessage == 1)
					{
						char sTankName[33];
						ST_TankName(iTank, sTankName);
						PrintToChatAll("%s %t", ST_TAG2, "Drop", sTankName);
					}
				}
			}
			else if (iDropMode(iTank) != 1 && bIsValidGame())
			{
				int iDrop = CreateEntityByName("weapon_melee");
				if (bIsValidEntity(iDrop))
				{
					DispatchKeyValue(iDrop, "melee_script_name", g_sWeaponClass[g_iDropWeapon[iTank]]);
					TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
					DispatchSpawn(iDrop);
					SetEntPropFloat(iDrop, Prop_Send, "m_flModelScale", flDropWeaponScale(iTank));

					if (iDropMessage == 1)
					{
						char sTankName[33];
						ST_TankName(iTank, sTankName);
						PrintToChatAll("%s %t", ST_TAG2, "Drop2", sTankName);
					}
				}
			}
		}

		vDeleteDrop(iTank);
	}
}

public void ST_BossStage(int tank)
{
	vDeleteDrop(tank);
}

public void ST_Ability(int tank)
{
	if (iDropAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bDrop[tank])
	{
		g_bDrop[tank] = true;
		CreateTimer(1.0, tTimerDrop, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
}

static void vDeleteDrop(int tank)
{
	if (bIsValidEntity(g_iDrop[tank]))
	{
		RemoveEntity(g_iDrop[tank]);
	}

	g_iDrop[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vResetDrop(iPlayer);
		}
	}
}

static void vResetDrop(int tank)
{
	g_bDrop[tank] = false;
	g_iDrop[tank] = 0;
	g_iDropWeapon[tank] = 0;
}

static float flDropWeaponScale(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flDropWeaponScale[ST_TankType(tank)] : g_flDropWeaponScale2[ST_TankType(tank)];
}

static int iDropAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDropAbility[ST_TankType(tank)] : g_iDropAbility2[ST_TankType(tank)];
}

static int iDropMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDropMode[ST_TankType(tank)] : g_iDropMode2[ST_TankType(tank)];
}

public Action tTimerDrop(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bDrop[iTank])
	{
		g_bDrop[iTank] = false;
		return Plugin_Stop;
	}

	if (iDropAbility(iTank) == 0)
	{
		g_bDrop[iTank] = false;
		return Plugin_Stop;
	}

	vDeleteDrop(iTank);

	int iDropValue, iPosition;

	switch (iDropMode(iTank))
	{
		case 0: iDropValue = GetRandomInt(1, 31);
		case 1: iDropValue = GetRandomInt(1, 19);
		case 2: iDropValue = GetRandomInt(20, 31);
	}

	int iWeapon = bIsValidGame() ? iDropValue : GetRandomInt(1, 6);

	switch (GetRandomInt(1, 2))
	{
		case 1: iPosition = 1;
		case 2: iPosition = 2;
	}

	float flScale;

	int iDrop = CreateEntityByName("prop_dynamic_override");
	if (bIsValidEntity(iDrop))
	{
		float flPos[3], flAngles[3];

		char sPosition[32];

		SetEntityModel(iDrop, g_sWeaponModel[iWeapon]);
		TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
		DispatchSpawn(iDrop);
		vSetEntityParent(iDrop, iTank);

		switch (iPosition)
		{
			case 1: sPosition = "rhand";
			case 2: sPosition = "lhand";
		}

		SetVariantString(sPosition);
		AcceptEntityInput(iDrop, "SetParentAttachment");

		if (bIsValidGame())
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

			flScale *= flDropWeaponScale(iTank);
		}
		else
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

		SetEntProp(iDrop, Prop_Send, "m_CollisionGroup", 2);

		if (bIsValidGame())
		{
			SetEntPropFloat(iDrop , Prop_Send, "m_flModelScale", flScale);
		}

		g_iDrop[iTank] = iDrop;
		g_iDropWeapon[iTank] = iWeapon;
	}

	return Plugin_Continue;
}