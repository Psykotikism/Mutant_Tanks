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

#file "Hypno Ability v8.77"

public Plugin myinfo =
{
	name = "[MT] Hypno Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank hypnotizes survivors to damage themselves or their teammates.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Hypno Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_HYPNO "Hypno Ability"

enum struct esPlayer
{
	bool g_bAffected;
	bool g_bHypno3;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHypnoAbility;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHypnoAbility;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iImmunityFlags;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHypnoAbility;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_hypno", cmdHypnoInfo, "View information about the Hypno ability.");

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
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

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

public Action cmdHypnoInfo(int client, int args)
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
		case false: vHypnoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHypnoMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHypnoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hypno Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iHypnoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHypnoAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HypnoDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esCache[param1].g_flHypnoDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vHypnoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "HypnoMenu", param1);
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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
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
	menu.AddItem(MT_MENU_HYPNO, MT_MENU_HYPNO);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_HYPNO, false))
	{
		vHypnoMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_HYPNO, false))
	{
		FormatEx(buffer, size, "%T", "HypnoMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker) && (g_esCache[attacker].g_iHypnoHitMode == 0 || g_esCache[attacker].g_iHypnoHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHypnoHit(victim, attacker, g_esCache[attacker].g_flHypnoChance, g_esCache[attacker].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && bIsSurvivor(attacker))
		{
			if ((g_esCache[victim].g_iHypnoHitMode == 0 || g_esCache[victim].g_iHypnoHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				if ((MT_HasAdminAccess(victim) || bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) && !MT_IsAdminImmune(attacker, victim) && !bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
				{
					vHypnoHit(attacker, victim, g_esCache[victim].g_flHypnoChance, g_esCache[victim].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
				}
			}

			if (g_esPlayer[attacker].g_bAffected)
			{
				if (damagetype & DMG_BULLET)
				{
					damage /= g_esCache[victim].g_flHypnoBulletDivisor;
				}
				else if ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA))
				{
					damage /= g_esCache[victim].g_flHypnoExplosiveDivisor;
				}
				else if (damagetype & DMG_BURN)
				{
					damage /= g_esCache[victim].g_flHypnoFireDivisor;
				}
				else if (damagetype & DMG_SLASH || (damagetype & DMG_CLUB))
				{
					damage /= g_esCache[victim].g_flHypnoMeleeDivisor;
				}

				static int iTarget;
				iTarget = iGetRandomSurvivor(attacker);
				iTarget = (g_esCache[victim].g_iHypnoMode == 1 && iTarget > 0) ? iTarget : attacker;

				static char sDamageType[32];
				IntToString(damagetype, sDamageType, sizeof(sDamageType));

				vDamageEntity(iTarget, attacker, damage, sDamageType);

				return Plugin_Changed;
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
	list.PushString("hypnoability");
	list2.PushString("hypno ability");
	list3.PushString("hypno_ability");
	list4.PushString("hypno");
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
				g_esAbility[iIndex].g_iHypnoAbility = 0;
				g_esAbility[iIndex].g_iHypnoEffect = 0;
				g_esAbility[iIndex].g_iHypnoMessage = 0;
				g_esAbility[iIndex].g_flHypnoBulletDivisor = 20.0;
				g_esAbility[iIndex].g_flHypnoChance = 33.3;
				g_esAbility[iIndex].g_flHypnoDuration = 5.0;
				g_esAbility[iIndex].g_flHypnoExplosiveDivisor = 20.0;
				g_esAbility[iIndex].g_flHypnoFireDivisor = 200.0;
				g_esAbility[iIndex].g_iHypnoHit = 0;
				g_esAbility[iIndex].g_iHypnoHitMode = 0;
				g_esAbility[iIndex].g_flHypnoMeleeDivisor = 200.0;
				g_esAbility[iIndex].g_iHypnoMode = 0;
				g_esAbility[iIndex].g_flHypnoRange = 150.0;
				g_esAbility[iIndex].g_flHypnoRangeChance = 15.0;
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
					g_esPlayer[iPlayer].g_iHypnoAbility = 0;
					g_esPlayer[iPlayer].g_iHypnoEffect = 0;
					g_esPlayer[iPlayer].g_iHypnoMessage = 0;
					g_esPlayer[iPlayer].g_flHypnoBulletDivisor = 0.0;
					g_esPlayer[iPlayer].g_flHypnoChance = 0.0;
					g_esPlayer[iPlayer].g_flHypnoDuration = 0.0;
					g_esPlayer[iPlayer].g_flHypnoExplosiveDivisor = 0.0;
					g_esPlayer[iPlayer].g_flHypnoFireDivisor = 0.0;
					g_esPlayer[iPlayer].g_iHypnoHit = 0;
					g_esPlayer[iPlayer].g_iHypnoHitMode = 0;
					g_esPlayer[iPlayer].g_flHypnoMeleeDivisor = 0.0;
					g_esPlayer[iPlayer].g_iHypnoMode = 0;
					g_esPlayer[iPlayer].g_flHypnoRange = 0.0;
					g_esPlayer[iPlayer].g_flHypnoRangeChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHypnoAbility = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iHypnoAbility, value, 0, 1);
		g_esPlayer[admin].g_iHypnoEffect = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iHypnoEffect, value, 0, 7);
		g_esPlayer[admin].g_iHypnoMessage = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iHypnoMessage, value, 0, 7);
		g_esPlayer[admin].g_flHypnoBulletDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_esPlayer[admin].g_flHypnoBulletDivisor, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flHypnoChance = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_esPlayer[admin].g_flHypnoChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flHypnoDuration = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_esPlayer[admin].g_flHypnoDuration, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flHypnoExplosiveDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_esPlayer[admin].g_flHypnoExplosiveDivisor, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flHypnoFireDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_esPlayer[admin].g_flHypnoFireDivisor, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iHypnoHit = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_esPlayer[admin].g_iHypnoHit, value, 0, 1);
		g_esPlayer[admin].g_iHypnoHitMode = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_esPlayer[admin].g_iHypnoHitMode, value, 0, 2);
		g_esPlayer[admin].g_flHypnoMeleeDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_esPlayer[admin].g_flHypnoMeleeDivisor, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iHypnoMode = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_esPlayer[admin].g_iHypnoMode, value, 0, 1);
		g_esPlayer[admin].g_flHypnoRange = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_esPlayer[admin].g_flHypnoRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flHypnoRangeChance = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_esPlayer[admin].g_flHypnoRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "hypnoability", false) || StrEqual(subsection, "hypno ability", false) || StrEqual(subsection, "hypno_ability", false) || StrEqual(subsection, "hypno", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHypnoAbility = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iHypnoAbility, value, 0, 1);
		g_esAbility[type].g_iHypnoEffect = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iHypnoEffect, value, 0, 7);
		g_esAbility[type].g_iHypnoMessage = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iHypnoMessage, value, 0, 7);
		g_esAbility[type].g_flHypnoBulletDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_esAbility[type].g_flHypnoBulletDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_flHypnoChance = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_esAbility[type].g_flHypnoChance, value, 0.0, 100.0);
		g_esAbility[type].g_flHypnoDuration = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_esAbility[type].g_flHypnoDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_flHypnoExplosiveDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_esAbility[type].g_flHypnoExplosiveDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_flHypnoFireDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_esAbility[type].g_flHypnoFireDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_iHypnoHit = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_esAbility[type].g_iHypnoHit, value, 0, 1);
		g_esAbility[type].g_iHypnoHitMode = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_esAbility[type].g_iHypnoHitMode, value, 0, 2);
		g_esAbility[type].g_flHypnoMeleeDivisor = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_esAbility[type].g_flHypnoMeleeDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_iHypnoMode = iGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_esAbility[type].g_iHypnoMode, value, 0, 1);
		g_esAbility[type].g_flHypnoRange = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_esAbility[type].g_flHypnoRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flHypnoRangeChance = flGetKeyValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_esAbility[type].g_flHypnoRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "hypnoability", false) || StrEqual(subsection, "hypno ability", false) || StrEqual(subsection, "hypno_ability", false) || StrEqual(subsection, "hypno", false))
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
	g_esCache[tank].g_flHypnoBulletDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoBulletDivisor, g_esAbility[type].g_flHypnoBulletDivisor);
	g_esCache[tank].g_flHypnoChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoChance, g_esAbility[type].g_flHypnoChance);
	g_esCache[tank].g_flHypnoDuration = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoDuration, g_esAbility[type].g_flHypnoDuration);
	g_esCache[tank].g_flHypnoExplosiveDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoExplosiveDivisor, g_esAbility[type].g_flHypnoExplosiveDivisor);
	g_esCache[tank].g_flHypnoFireDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoFireDivisor, g_esAbility[type].g_flHypnoFireDivisor);
	g_esCache[tank].g_flHypnoMeleeDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoMeleeDivisor, g_esAbility[type].g_flHypnoMeleeDivisor);
	g_esCache[tank].g_flHypnoRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoRange, g_esAbility[type].g_flHypnoRange);
	g_esCache[tank].g_flHypnoRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flHypnoRangeChance, g_esAbility[type].g_flHypnoRangeChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHypnoAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHypnoAbility, g_esAbility[type].g_iHypnoAbility);
	g_esCache[tank].g_iHypnoEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHypnoEffect, g_esAbility[type].g_iHypnoEffect);
	g_esCache[tank].g_iHypnoHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHypnoHit, g_esAbility[type].g_iHypnoHit);
	g_esCache[tank].g_iHypnoHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHypnoHitMode, g_esAbility[type].g_iHypnoHitMode);
	g_esCache[tank].g_iHypnoMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHypnoMessage, g_esAbility[type].g_iHypnoMessage);
	g_esCache[tank].g_iHypnoMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHypnoMode, g_esAbility[type].g_iHypnoMode);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveHypno(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iHypnoAbility == 1)
	{
		vHypnoAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
		{
			return;
		}

		if (button & MT_SUB_KEY)
		{
			if (g_esCache[tank].g_iHypnoAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vHypnoAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveHypno(tank);
}

static void vHypnoAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
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
				if (flDistance <= g_esCache[tank].g_flHypnoRange)
				{
					vHypnoHit(iSurvivor, tank, g_esCache[tank].g_flHypnoRangeChance, g_esCache[tank].g_iHypnoAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman4");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoAmmo");
	}
}

static void vHypnoHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bAffected)
			{
				g_esPlayer[survivor].g_bAffected = true;
				g_esPlayer[survivor].g_iOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
				{
					g_esPlayer[tank].g_iCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman5", g_esPlayer[tank].g_iCooldown - iTime);
					}
				}

				DataPack dpStopHypno;
				CreateDataTimer(g_esCache[tank].g_flHypnoDuration, tTimerStopHypno, dpStopHypno, TIMER_FLAG_NO_MAPCHANGE);
				dpStopHypno.WriteCell(GetClientUserId(survivor));
				dpStopHypno.WriteCell(GetClientUserId(tank));
				dpStopHypno.WriteCell(messages);

				vEffect(survivor, tank, g_esCache[tank].g_iHypnoEffect, flags);

				if (g_esCache[tank].g_iHypnoMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoAmmo");
		}
	}
}

static void vRemoveHypno(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bAffected && g_esPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bAffected = false;
			g_esPlayer[iSurvivor].g_iOwner = 0;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bAffected = false;
	g_esPlayer[tank].g_bHypno3 = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

public Action tTimerStopHypno(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_esPlayer[iSurvivor].g_bAffected)
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank))
	{
		g_esPlayer[iSurvivor].g_bAffected = false;
		g_esPlayer[iSurvivor].g_iOwner = 0;

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bAffected = false;
	g_esPlayer[iSurvivor].g_iOwner = 0;

	int iMessage = pack.ReadCell();
	if (g_esCache[iTank].g_iHypnoMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno2", iSurvivor);
	}

	return Plugin_Continue;
}