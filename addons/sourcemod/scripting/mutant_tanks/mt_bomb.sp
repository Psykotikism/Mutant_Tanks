/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

//#file "Bomb Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Bomb Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates explosions.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Bomb Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

#define SOUND_HIT "animation/van_inside_hit_wall.wav"
#define SOUND_BOMB "animation/bombing_run_01.wav"

#define MT_MENU_BOMB "Bomb Ability"

enum struct esPlayer
{
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flBombChance;
	float g_flBombDeathChance;
	float g_flBombRange;
	float g_flBombRangeChance;
	float g_flBombRockChance;

	int g_iAccessFlags;
	int g_iBombAbility;
	int g_iBombDeath;
	int g_iBombEffect;
	int g_iBombHit;
	int g_iBombHitMode;
	int g_iBombMessage;
	int g_iBombRockBreak;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flBombChance;
	float g_flBombDeathChance;
	float g_flBombRange;
	float g_flBombRangeChance;
	float g_flBombRockChance;

	int g_iAccessFlags;
	int g_iBombAbility;
	int g_iBombDeath;
	int g_iBombEffect;
	int g_iBombHit;
	int g_iBombHitMode;
	int g_iBombMessage;
	int g_iBombRockBreak;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flBombChance;
	float g_flBombDeathChance;
	float g_flBombRange;
	float g_flBombRangeChance;
	float g_flBombRockChance;

	int g_iBombAbility;
	int g_iBombDeath;
	int g_iBombEffect;
	int g_iBombHit;
	int g_iBombHitMode;
	int g_iBombMessage;
	int g_iBombRockBreak;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_bomb", cmdBombInfo, "View information about the Bomb ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	PrecacheSound(SOUND_HIT, true);
	PrecacheSound(SOUND_BOMB, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveBomb(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveBomb(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdBombInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vBombMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vBombMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iBombMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Bomb Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iBombMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iBombAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "BombDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vBombMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "BombMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH];

			switch (param2)
			{
				case 0:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);

					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_BOMB, MT_MENU_BOMB);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_BOMB, false))
	{
		vBombMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_BOMB, false))
	{
		FormatEx(buffer, size, "%T", "BombMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iBombHitMode == 0 || g_esCache[attacker].g_iBombHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBombHit(victim, attacker, g_esCache[attacker].g_flBombChance, g_esCache[attacker].g_iBombHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && (g_esCache[victim].g_iBombHitMode == 0 || g_esCache[victim].g_iBombHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBombHit(attacker, victim, g_esCache[victim].g_flBombChance, g_esCache[victim].g_iBombHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("bombability");
	list2.PushString("bomb ability");
	list3.PushString("bomb_ability");
	list4.PushString("bomb");
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
				g_esAbility[iIndex].g_iImmunityFlags = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iBombAbility = 0;
				g_esAbility[iIndex].g_iBombEffect = 0;
				g_esAbility[iIndex].g_iBombMessage = 0;
				g_esAbility[iIndex].g_flBombChance = 33.3;
				g_esAbility[iIndex].g_iBombDeath = 0;
				g_esAbility[iIndex].g_flBombDeathChance = 200.0;
				g_esAbility[iIndex].g_iBombHit = 0;
				g_esAbility[iIndex].g_iBombHitMode = 0;
				g_esAbility[iIndex].g_flBombRange = 150.0;
				g_esAbility[iIndex].g_flBombRangeChance = 15.0;
				g_esAbility[iIndex].g_iBombRockBreak = 0;
				g_esAbility[iIndex].g_flBombRockChance = 33.3;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iBombAbility = 0;
					g_esPlayer[iPlayer].g_iBombEffect = 0;
					g_esPlayer[iPlayer].g_iBombMessage = 0;
					g_esPlayer[iPlayer].g_flBombChance = 0.0;
					g_esPlayer[iPlayer].g_iBombDeath = 0;
					g_esPlayer[iPlayer].g_flBombDeathChance = 0.0;
					g_esPlayer[iPlayer].g_iBombHit = 0;
					g_esPlayer[iPlayer].g_iBombHitMode = 0;
					g_esPlayer[iPlayer].g_flBombRange = 0.0;
					g_esPlayer[iPlayer].g_flBombRangeChance = 0.0;
					g_esPlayer[iPlayer].g_iBombRockBreak = 0;
					g_esPlayer[iPlayer].g_flBombRockChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iBombAbility = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iBombAbility, value, 0, 1);
		g_esPlayer[admin].g_iBombEffect = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iBombEffect, value, 0, 7);
		g_esPlayer[admin].g_iBombMessage = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iBombMessage, value, 0, 7);
		g_esPlayer[admin].g_flBombChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombChance", "Bomb Chance", "Bomb_Chance", "chance", g_esPlayer[admin].g_flBombChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iBombDeath = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombDeath", "Bomb Death", "Bomb_Death", "death", g_esPlayer[admin].g_iBombDeath, value, 0, 1);
		g_esPlayer[admin].g_flBombDeathChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombDeathChance", "Bomb Death Chance", "Bomb_Death_Chance", "deathchance", g_esPlayer[admin].g_flBombDeathChance, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iBombHit = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombHit", "Bomb Hit", "Bomb_Hit", "hit", g_esPlayer[admin].g_iBombHit, value, 0, 1);
		g_esPlayer[admin].g_iBombHitMode = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombHitMode", "Bomb Hit Mode", "Bomb_Hit_Mode", "hitmode", g_esPlayer[admin].g_iBombHitMode, value, 0, 2);
		g_esPlayer[admin].g_flBombRange = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRange", "Bomb Range", "Bomb_Range", "range", g_esPlayer[admin].g_flBombRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flBombRangeChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRangeChance", "Bomb Range Chance", "Bomb_Range_Chance", "rangechance", g_esPlayer[admin].g_flBombRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iBombRockBreak = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRockBreak", "Bomb Rock Break", "Bomb_Rock_Break", "rock", g_esPlayer[admin].g_iBombRockBreak, value, 0, 1);
		g_esPlayer[admin].g_flBombRockChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRockChance", "Bomb Rock Chance", "Bomb_Rock_Chance", "rockchance", g_esPlayer[admin].g_flBombRockChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "bombability", false) || StrEqual(subsection, "bomb ability", false) || StrEqual(subsection, "bomb_ability", false) || StrEqual(subsection, "bomb", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iBombAbility = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iBombAbility, value, 0, 1);
		g_esAbility[type].g_iBombEffect = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iBombEffect, value, 0, 7);
		g_esAbility[type].g_iBombMessage = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iBombMessage, value, 0, 7);
		g_esAbility[type].g_flBombChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombChance", "Bomb Chance", "Bomb_Chance", "chance", g_esAbility[type].g_flBombChance, value, 0.0, 100.0);
		g_esAbility[type].g_iBombDeath = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombDeath", "Bomb Death", "Bomb_Death", "death", g_esAbility[type].g_iBombDeath, value, 0, 1);
		g_esAbility[type].g_flBombDeathChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombDeathChance", "Bomb Death Chance", "Bomb_Death_Chance", "deathchance", g_esAbility[type].g_flBombDeathChance, value, 1.0, 999999.0);
		g_esAbility[type].g_iBombHit = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombHit", "Bomb Hit", "Bomb_Hit", "hit", g_esAbility[type].g_iBombHit, value, 0, 1);
		g_esAbility[type].g_iBombHitMode = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombHitMode", "Bomb Hit Mode", "Bomb_Hit_Mode", "hitmode", g_esAbility[type].g_iBombHitMode, value, 0, 2);
		g_esAbility[type].g_flBombRange = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRange", "Bomb Range", "Bomb_Range", "range", g_esAbility[type].g_flBombRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flBombRangeChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRangeChance", "Bomb Range Chance", "Bomb_Range_Chance", "rangechance", g_esAbility[type].g_flBombRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iBombRockBreak = iGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRockBreak", "Bomb Rock Break", "Bomb_Rock_Break", "rock", g_esAbility[type].g_iBombRockBreak, value, 0, 1);
		g_esAbility[type].g_flBombRockChance = flGetKeyValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRockChance", "Bomb Rock Chance", "Bomb_Rock_Chance", "rockchance", g_esAbility[type].g_flBombRockChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "bombability", false) || StrEqual(subsection, "bomb ability", false) || StrEqual(subsection, "bomb_ability", false) || StrEqual(subsection, "bomb", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flBombChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBombChance, g_esAbility[type].g_flBombChance);
	g_esCache[tank].g_flBombDeathChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBombDeathChance, g_esAbility[type].g_flBombDeathChance);
	g_esCache[tank].g_flBombRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBombRange, g_esAbility[type].g_flBombRange);
	g_esCache[tank].g_flBombRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBombRangeChance, g_esAbility[type].g_flBombRangeChance);
	g_esCache[tank].g_flBombRockChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flBombRockChance, g_esAbility[type].g_flBombRockChance);
	g_esCache[tank].g_iBombAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBombAbility, g_esAbility[type].g_iBombAbility);
	g_esCache[tank].g_iBombDeath = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBombDeath, g_esAbility[type].g_iBombDeath);
	g_esCache[tank].g_iBombEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBombEffect, g_esAbility[type].g_iBombEffect);
	g_esCache[tank].g_iBombHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBombHit, g_esAbility[type].g_iBombHit);
	g_esCache[tank].g_iBombHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBombHitMode, g_esAbility[type].g_iBombHitMode);
	g_esCache[tank].g_iBombMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBombMessage, g_esAbility[type].g_iBombMessage);
	g_esCache[tank].g_iBombRockBreak = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iBombRockBreak, g_esAbility[type].g_iBombRockBreak);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vBombRange(iTank);
			vRemoveBomb(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iBombAbility == 1)
	{
		vBombAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iBombAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "BombHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vBombAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveBomb(tank);

	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank) && g_esCache[tank].g_iBombAbility == 1)
	{
		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
		{
			return;
		}

		static float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);
		EmitSoundToAll(SOUND_BOMB, tank);
	}
}

public void MT_OnPostTankSpawn(int tank)
{
	vBombRange(tank);
}

public void MT_OnRockBreak(int tank, int rock)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank) && g_esCache[tank].g_iBombRockBreak == 1)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flBombRockChance)
		{
			static float flPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
			vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);
			EmitSoundToAll(SOUND_BOMB, tank);

			if (g_esCache[tank].g_iBombMessage & MT_MESSAGE_SPECIAL)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Bomb2", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Bomb2", LANG_SERVER, sTankName);
			}
		}
	}
}

static void vBombAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		g_esPlayer[tank].g_bFailed = false;
		g_esPlayer[tank].g_bNoAmmo = false;

		static float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		static float flSurvivorPos[3], flDistance;
		static int iSurvivorCount;
		iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_esCache[tank].g_flBombRange)
				{
					vBombHit(iSurvivor, tank, g_esCache[tank].g_flBombRangeChance, g_esCache[tank].g_iBombAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "BombHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "BombAmmo");
	}
}

static void vBombHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "BombHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "BombHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				static float flPos[3];
				GetClientAbsOrigin(survivor, flPos);
				vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);

				vEffect(survivor, tank, g_esCache[tank].g_iBombEffect, flags);
				EmitSoundToAll(SOUND_HIT, survivor);

				if (g_esCache[tank].g_iBombMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Bomb", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Bomb", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "BombHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "BombAmmo");
		}
	}
}

static void vBombRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(tank) && g_esCache[tank].g_iBombDeath == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flBombDeathChance)
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		static float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);
		EmitSoundToAll(SOUND_BOMB, tank);
	}
}

static void vRemoveBomb(int tank)
{
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveBomb(iPlayer);
		}
	}
}