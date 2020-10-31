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

//#file "Lightning Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Lightning Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates lightning storms.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Lightning Ability\" only supports Left 4 Dead 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define PARTICLE_LIGHTNING "storm_lightning_01"

#define SPRITE_EXPLODE "sprites/zerogxplode.spr"

#define SOUND_EXPLOSION "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav"

#define MT_MENU_LIGHTNING "Lightning Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flLightningChance;
	float g_flLightningInterval;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iLightningAbility;
	int g_iLightningDamage;
	int g_iLightningDuration;
	int g_iLightningMessage;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flLightningChance;
	float g_flLightningInterval;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iLightningAbility;
	int g_iLightningDamage;
	int g_iLightningDuration;
	int g_iLightningMessage;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flLightningChance;
	float g_flLightningInterval;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iLightningAbility;
	int g_iLightningDamage;
	int g_iLightningDuration;
	int g_iLightningMessage;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_lightning", cmdLightningInfo, "View information about the Lightning ability.");
}

public void OnMapStart()
{
	PrecacheModel(SPRITE_EXPLODE, true);

	iPrecacheParticle(PARTICLE_LIGHTNING);

	PrecacheSound(SOUND_EXPLOSION, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveLightning(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveLightning(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdLightningInfo(int client, int args)
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
		case false: vLightningMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vLightningMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iLightningMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Lightning Ability Information");
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

public int iLightningMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iLightningAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "LightningDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iLightningDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vLightningMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "LightningMenu", param1);
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
	menu.AddItem(MT_MENU_LIGHTNING, MT_MENU_LIGHTNING);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_LIGHTNING, false))
	{
		vLightningMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_LIGHTNING, false))
	{
		FormatEx(buffer, size, "%T", "LightningMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsValidEntity(inflictor) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "env_explosion"))
		{
			static int iTank;
			iTank = HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") : 0;
			if (MT_IsTankSupported(iTank) && MT_IsCustomTankSupported(iTank) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)))
			{
				if (bIsInfected(victim) || (bIsSurvivor(victim) && (MT_IsAdminImmune(victim, iTank) || bIsAdminImmune(victim, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))))
				{
					return Plugin_Handled;
				}

				damage = MT_GetScaledDamage(float(g_esCache[iTank].g_iLightningDamage));

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
	list.PushString("lightningability");
	list2.PushString("lightning ability");
	list3.PushString("lightning_ability");
	list4.PushString("lightning");
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
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iLightningAbility = 0;
				g_esAbility[iIndex].g_iLightningMessage = 0;
				g_esAbility[iIndex].g_flLightningChance = 33.3;
				g_esAbility[iIndex].g_iLightningDamage = 5;
				g_esAbility[iIndex].g_iLightningDuration = 5;
				g_esAbility[iIndex].g_flLightningInterval = 1.0;
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
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iLightningAbility = 0;
					g_esPlayer[iPlayer].g_iLightningMessage = 0;
					g_esPlayer[iPlayer].g_flLightningChance = 0.0;
					g_esPlayer[iPlayer].g_iLightningDamage = 0;
					g_esPlayer[iPlayer].g_iLightningDuration = 0;
					g_esPlayer[iPlayer].g_flLightningInterval = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iLightningAbility = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iLightningAbility, value, 0, 1);
		g_esPlayer[admin].g_iLightningMessage = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iLightningMessage, value, 0, 1);
		g_esPlayer[admin].g_flLightningChance = flGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningChance", "Lightning Chance", "Lightning_Chance", "chance", g_esPlayer[admin].g_flLightningChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iLightningDamage = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningDamage", "Lightning Damage", "Lightning_Damage", "damage", g_esPlayer[admin].g_iLightningDamage, value, 1, 999999);
		g_esPlayer[admin].g_iLightningDuration = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningDuration", "Lightning Duration", "Lightning_Duration", "duration", g_esPlayer[admin].g_iLightningDuration, value, 1, 999999);
		g_esPlayer[admin].g_flLightningInterval = flGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningInterval", "Lightning Interval", "Lightning_Interval", "interval", g_esPlayer[admin].g_flLightningInterval, value, 0.1, 999999.0);

		if (StrEqual(subsection, "lightningability", false) || StrEqual(subsection, "lightning ability", false) || StrEqual(subsection, "lightning_ability", false) || StrEqual(subsection, "lightning", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iLightningAbility = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iLightningAbility, value, 0, 1);
		g_esAbility[type].g_iLightningMessage = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iLightningMessage, value, 0, 1);
		g_esAbility[type].g_flLightningChance = flGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningChance", "Lightning Chance", "Lightning_Chance", "chance", g_esAbility[type].g_flLightningChance, value, 0.0, 100.0);
		g_esAbility[type].g_iLightningDamage = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningDamage", "Lightning Damage", "Lightning_Damage", "damage", g_esAbility[type].g_iLightningDamage, value, 1, 999999);
		g_esAbility[type].g_iLightningDuration = iGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningDuration", "Lightning Duration", "Lightning_Duration", "duration", g_esAbility[type].g_iLightningDuration, value, 1, 999999);
		g_esAbility[type].g_flLightningInterval = flGetKeyValue(subsection, "lightningability", "lightning ability", "lightning_ability", "lightning", key, "LightningInterval", "Lightning Interval", "Lightning_Interval", "interval", g_esAbility[type].g_flLightningInterval, value, 0.1, 999999.0);

		if (StrEqual(subsection, "lightningability", false) || StrEqual(subsection, "lightning ability", false) || StrEqual(subsection, "lightning_ability", false) || StrEqual(subsection, "lightning", false))
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
	g_esCache[tank].g_flLightningChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLightningChance, g_esAbility[type].g_flLightningChance);
	g_esCache[tank].g_flLightningInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLightningInterval, g_esAbility[type].g_flLightningInterval);
	g_esCache[tank].g_iLightningAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLightningAbility, g_esAbility[type].g_iLightningAbility);
	g_esCache[tank].g_iLightningDamage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLightningDamage, g_esAbility[type].g_iLightningDamage);
	g_esCache[tank].g_iLightningDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLightningDuration, g_esAbility[type].g_iLightningDuration);
	g_esCache[tank].g_iLightningMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLightningMessage, g_esAbility[type].g_iLightningMessage);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveLightning(oldTank);
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
			vRemoveLightning(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveLightning(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveLightning(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iLightningAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vLightningAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iLightningAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
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
							vLightningAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman4", g_esPlayer[tank].g_iCooldown - iTime);
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

								vLightning(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
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
	vRemoveLightning(tank);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
}

static void vLightning(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	DataPack dpLightning;
	CreateDataTimer(g_esCache[tank].g_flLightningInterval, tTimerLightning, dpLightning, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpLightning.WriteCell(GetClientUserId(tank));
	dpLightning.WriteCell(g_esPlayer[tank].g_iTankType);
	dpLightning.WriteCell(GetTime());
}

static void vLightningAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flLightningChance)
		{
			g_esPlayer[tank].g_bActivated = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			vLightning(tank);

			if (g_esCache[tank].g_iLightningMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Lightning", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Lightning", LANG_SERVER, sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningAmmo");
	}
}

static void vRemoveLightning(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveLightning(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	if (g_esCache[tank].g_iLightningMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Lightning2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Lightning2", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "LightningHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

public Action tTimerLightning(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (g_esCache[iTank].g_iLightningAbility == 0 || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0)) && (iTime + g_esCache[iTank].g_iLightningDuration) < iCurrentTime))
	{
		vReset2(iTank);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
		{
			vReset3(iTank);
		}

		return Plugin_Stop;
	}

	static char sTargetName[64];
	static float flOrigin[3], flRadius, flRadius2;
	GetClientAbsOrigin(iTank, flOrigin);
	flRadius = GetRandomFloat(100.0, 360.0);
	flRadius2 = GetRandomFloat(0.0, 360.0);
	flOrigin[0] += flRadius * Cosine(DegToRad(flRadius2));
	flOrigin[1] += flRadius * Sine(DegToRad(flRadius2));

	static int iTarget;
	iTarget = CreateEntityByName("info_particle_target");
	if (bIsValidEntity(iTarget))
	{
		Format(sTargetName, sizeof(sTargetName), "mutant_tank_target_%i_%i", iTank, g_esPlayer[iTank].g_iTankType);
		DispatchKeyValue(iTarget, "targetname", sTargetName);
		TeleportEntity(iTarget, flOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iTarget);
		ActivateEntity(iTarget);
		SetVariantString("OnUser2 !self:Kill::2.0:1");
		AcceptEntityInput(iTarget, "AddOutput");
		AcceptEntityInput(iTarget, "FireUser2");
	}

	static int iExplosion;
	iExplosion = CreateEntityByName("env_explosion");
	if (bIsValidEntity(iExplosion))
	{
		DispatchKeyValue(iExplosion, "fireballsprite", SPRITE_EXPLODE);

		static char sDamage[7];
		IntToString(g_esCache[iTank].g_iLightningDamage, sDamage, sizeof(sDamage));
		DispatchKeyValue(iExplosion, "iMagnitude", sDamage);
		DispatchKeyValue(iExplosion, "rendermode", "5");
		DispatchKeyValue(iExplosion, "spawnflags", "0");

		TeleportEntity(iExplosion, flOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iExplosion);

		SetEntPropEnt(iExplosion, Prop_Send, "m_hOwnerEntity", iTank);
		SetEntProp(iExplosion, Prop_Send, "m_iTeamNum", 3);
		AcceptEntityInput(iExplosion, "Explode");

		iExplosion = EntIndexToEntRef(iExplosion);
		vDeleteEntity(iExplosion, 2.0);

		EmitSoundToAll(SOUND_EXPLOSION, iExplosion, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}

	flOrigin[2] += 1800.0;

	static int iLightning;
	iLightning = CreateEntityByName("info_particle_system");
	if (bIsValidEntity(iLightning))
	{
		DispatchKeyValue(iLightning, "effect_name", PARTICLE_LIGHTNING);
		DispatchKeyValue(iLightning, "cpoint1", sTargetName);

		TeleportEntity(iLightning, flOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iLightning);
		ActivateEntity(iLightning);
		AcceptEntityInput(iLightning, "Start");

		iLightning = EntIndexToEntRef(iLightning);
		vDeleteEntity(iLightning, 2.0);
	}

	return Plugin_Continue;
}