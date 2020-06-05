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

public Plugin myinfo =
{
	name = "[MT] Absorb Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank absorbs most of the damage it receives.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Absorb Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"

#define MT_MENU_ABSORB "Absorb Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flAbsorbBulletDivisor;
	float g_flAbsorbChance;
	float g_flAbsorbExplosiveDivisor;
	float g_flAbsorbFireDivisor;
	float g_flAbsorbMeleeDivisor;

	int g_iAbsorbAbility;
	int g_iAbsorbDuration;
	int g_iAbsorbMessage;
	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iDuration;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flAbsorbBulletDivisor;
	float g_flAbsorbChance;
	float g_flAbsorbExplosiveDivisor;
	float g_flAbsorbFireDivisor;
	float g_flAbsorbMeleeDivisor;

	int g_iAbsorbAbility;
	int g_iAbsorbDuration;
	int g_iAbsorbMessage;
	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flAbsorbBulletDivisor;
	float g_flAbsorbChance;
	float g_flAbsorbExplosiveDivisor;
	float g_flAbsorbFireDivisor;
	float g_flAbsorbMeleeDivisor;

	int g_iAbsorbAbility;
	int g_iAbsorbDuration;
	int g_iAbsorbMessage;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_absorb", cmdAbsorbInfo, "View information about the Absorb ability.");

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
	PrecacheSound(SOUND_METAL, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveAbsorb(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveAbsorb(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAbsorbInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vAbsorbMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAbsorbMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAbsorbMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Absorb Ability Information");
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

public int iAbsorbMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iAbsorbAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbsorbDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iAbsorbDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vAbsorbMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "AbsorbMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];

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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 7:
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
	menu.AddItem(MT_MENU_ABSORB, MT_MENU_ABSORB);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ABSORB, false))
	{
		vAbsorbMenu(client, 0);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated || (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && g_esCache[client].g_iHumanMode == 1) || g_esPlayer[client].g_iDuration == -1)
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration < iTime)
	{
		if (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esAbility[g_esPlayer[client].g_iTankType].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esCache[client].g_iHumanAbility == 1 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < iTime))
		{
			vReset3(client);
		}

		vReset2(client);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && g_esPlayer[victim].g_bActivated && bIsSurvivor(attacker))
		{
			if ((!bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags) && !MT_HasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			EmitSoundToClient(attacker, SOUND_METAL);

			if (damagetype & DMG_BULLET)
			{
				damage /= g_esCache[victim].g_flAbsorbBulletDivisor;
			}
			else if ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA))
			{
				damage /= g_esCache[victim].g_flAbsorbExplosiveDivisor;
			}
			else if (damagetype & DMG_BURN)
			{
				damage /= g_esCache[victim].g_flAbsorbFireDivisor;
			}
			else if ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB))
			{
				damage /= g_esCache[victim].g_flAbsorbMeleeDivisor;
			}

			return Plugin_Changed;
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
	list.PushString("absorbability");
	list2.PushString("absorb ability");
	list3.PushString("absorb_ability");
	list4.PushString("absorb");
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
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iAbsorbAbility = 0;
				g_esAbility[iIndex].g_iAbsorbMessage = 0;
				g_esAbility[iIndex].g_flAbsorbBulletDivisor = 20.0;
				g_esAbility[iIndex].g_flAbsorbChance = 33.3;
				g_esAbility[iIndex].g_iAbsorbDuration = 5;
				g_esAbility[iIndex].g_flAbsorbExplosiveDivisor = 20.0;
				g_esAbility[iIndex].g_flAbsorbFireDivisor = 200.0;
				g_esAbility[iIndex].g_flAbsorbMeleeDivisor = 200.0;
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
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iAbsorbAbility = 0;
					g_esPlayer[iPlayer].g_iAbsorbMessage = 0;
					g_esPlayer[iPlayer].g_flAbsorbBulletDivisor = 0.0;
					g_esPlayer[iPlayer].g_flAbsorbChance = 0.0;
					g_esPlayer[iPlayer].g_iAbsorbDuration = 0;
					g_esPlayer[iPlayer].g_flAbsorbExplosiveDivisor = 0.0;
					g_esPlayer[iPlayer].g_flAbsorbFireDivisor = 0.0;
					g_esPlayer[iPlayer].g_flAbsorbMeleeDivisor = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iAbsorbAbility = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iAbsorbAbility, value, 0, 1);
		g_esPlayer[admin].g_iAbsorbMessage = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iAbsorbMessage, value, 0, 1);
		g_esPlayer[admin].g_flAbsorbBulletDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbBulletDivisor", "Absorb Bullet Divisor", "Absorb_Bullet_Divisor", "bullet", g_esPlayer[admin].g_flAbsorbBulletDivisor, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flAbsorbChance = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbChance", "Absorb Chance", "Absorb_Chance", "chance", g_esPlayer[admin].g_flAbsorbChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iAbsorbDuration = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbDuration", "Absorb Duration", "Absorb_Duration", "duration", g_esPlayer[admin].g_iAbsorbDuration, value, 1, 999999);
		g_esPlayer[admin].g_flAbsorbExplosiveDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbExplosiveDivisor", "Absorb Explosive Divisor", "Absorb_Explosive_Divisor", "explosive", g_esPlayer[admin].g_flAbsorbExplosiveDivisor, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flAbsorbFireDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbFireDivisor", "Absorb Fire Divisor", "Absorb_Fire_Divisor", "fire", g_esPlayer[admin].g_flAbsorbFireDivisor, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flAbsorbMeleeDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbMeleeDivisor", "Absorb Melee Divisor", "Absorb_Melee_Divisor", "melee", g_esPlayer[admin].g_flAbsorbMeleeDivisor, value, 0.1, 999999.0);

		if (StrEqual(subsection, "absorbability", false) || StrEqual(subsection, "absorb ability", false) || StrEqual(subsection, "absorb_ability", false) || StrEqual(subsection, "absorb", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iAbsorbAbility = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iAbsorbAbility, value, 0, 1);
		g_esAbility[type].g_iAbsorbMessage = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iAbsorbMessage, value, 0, 1);
		g_esAbility[type].g_flAbsorbBulletDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbBulletDivisor", "Absorb Bullet Divisor", "Absorb_Bullet_Divisor", "bullet", g_esAbility[type].g_flAbsorbBulletDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_flAbsorbChance = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbChance", "Absorb Chance", "Absorb_Chance", "chance", g_esAbility[type].g_flAbsorbChance, value, 0.0, 100.0);
		g_esAbility[type].g_iAbsorbDuration = iGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbDuration", "Absorb Duration", "Absorb_Duration", "duration", g_esAbility[type].g_iAbsorbDuration, value, 1, 999999);
		g_esAbility[type].g_flAbsorbExplosiveDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbExplosiveDivisor", "Absorb Explosive Divisor", "Absorb_Explosive_Divisor", "explosive", g_esAbility[type].g_flAbsorbExplosiveDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_flAbsorbFireDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbFireDivisor", "Absorb Fire Divisor", "Absorb_Fire_Divisor", "fire", g_esAbility[type].g_flAbsorbFireDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_flAbsorbMeleeDivisor = flGetKeyValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbMeleeDivisor", "Absorb Melee Divisor", "Absorb_Melee_Divisor", "melee", g_esAbility[type].g_flAbsorbMeleeDivisor, value, 0.1, 999999.0);

		if (StrEqual(subsection, "absorbability", false) || StrEqual(subsection, "absorb ability", false) || StrEqual(subsection, "absorb_ability", false) || StrEqual(subsection, "absorb", false))
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
	g_esCache[tank].g_flAbsorbBulletDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAbsorbBulletDivisor, g_esAbility[type].g_flAbsorbBulletDivisor);
	g_esCache[tank].g_flAbsorbChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAbsorbChance, g_esAbility[type].g_flAbsorbChance);
	g_esCache[tank].g_flAbsorbExplosiveDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAbsorbExplosiveDivisor, g_esAbility[type].g_flAbsorbExplosiveDivisor);
	g_esCache[tank].g_flAbsorbFireDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAbsorbFireDivisor, g_esAbility[type].g_flAbsorbFireDivisor);
	g_esCache[tank].g_flAbsorbMeleeDivisor = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flAbsorbMeleeDivisor, g_esAbility[type].g_flAbsorbMeleeDivisor);
	g_esCache[tank].g_iAbsorbAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAbsorbAbility, g_esAbility[type].g_iAbsorbAbility);
	g_esCache[tank].g_iAbsorbDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAbsorbDuration, g_esAbility[type].g_iAbsorbDuration);
	g_esCache[tank].g_iAbsorbMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iAbsorbMessage, g_esAbility[type].g_iAbsorbMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveAbsorb(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iAbsorbAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vAbsorbAbility(tank);
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

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iAbsorbAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vAbsorbAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman4", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iCount++;

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset2(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveAbsorb(tank);
}

static void vAbsorbAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flAbsorbChance)
		{
			g_esPlayer[tank].g_bActivated = true;
			g_esPlayer[tank].g_iDuration = GetTime() + g_esCache[tank].g_iAbsorbDuration;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			if (g_esCache[tank].g_iAbsorbMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Absorb", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbAmmo");
	}
}

static void vRemoveAbsorb(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iDuration = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveAbsorb(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iDuration = -1;

	if (g_esCache[tank].g_iAbsorbMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Absorb2", sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "AbsorbHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}