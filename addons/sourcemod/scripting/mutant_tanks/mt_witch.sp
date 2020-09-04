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

#file "Witch Ability v8.77"

public Plugin myinfo =
{
	name = "[MT] Witch Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank converts nearby common infected into Witch minions.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Witch Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_WITCH "Witch Ability"

enum struct esPlayer
{
	float g_flWitchChance;
	float g_flWitchDamage;
	float g_flWitchRange;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iTankType;
	int g_iWitchAbility;
	int g_iWitchAmount;
	int g_iWitchMessage;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flWitchChance;
	float g_flWitchDamage;
	float g_flWitchRange;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iWitchAbility;
	int g_iWitchAmount;
	int g_iWitchMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flWitchChance;
	float g_flWitchDamage;
	float g_flWitchRange;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iWitchAbility;
	int g_iWitchAmount;
	int g_iWitchMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_witch", cmdWitchInfo, "View information about the Witch ability.");

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

	vRemoveWitch(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveWitch(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdWitchInfo(int client, int args)
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
		case false: vWitchMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWitchMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWitchMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Witch Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWitchMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iWitchAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "WitchDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vWitchMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "WitchMenu", param1);
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
	menu.AddItem(MT_MENU_WITCH, MT_MENU_WITCH);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_WITCH, false))
	{
		vWitchMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_WITCH, false))
	{
		FormatEx(buffer, size, "%T", "WitchMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (bIsWitch(attacker) && bIsSurvivor(victim))
		{
			int iOwner;
			if (HasEntProp(attacker, Prop_Send, "m_hOwnerEntity"))
			{
				iOwner = GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity");
			}

			if (MT_IsTankSupported(iOwner) && bIsCloneAllowed(iOwner))
			{
				if ((!MT_HasAdminAccess(iOwner) && !bHasAdminAccess(iOwner, g_esAbility[g_esPlayer[iOwner].g_iTankType].g_iAccessFlags, g_esPlayer[iOwner].g_iAccessFlags)) || MT_IsAdminImmune(victim, iOwner) || bIsAdminImmune(victim, g_esPlayer[iOwner].g_iTankType, g_esAbility[g_esPlayer[iOwner].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
				{
					return Plugin_Handled;
				}

				damage = g_esCache[iOwner].g_flWitchDamage;

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
	list.PushString("witchability");
	list2.PushString("witch ability");
	list3.PushString("witch_ability");
	list4.PushString("witch");
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
				g_esAbility[iIndex].g_iWitchAbility = 0;
				g_esAbility[iIndex].g_iWitchMessage = 0;
				g_esAbility[iIndex].g_iWitchAmount = 3;
				g_esAbility[iIndex].g_flWitchChance = 33.3;
				g_esAbility[iIndex].g_flWitchDamage = 5.0;
				g_esAbility[iIndex].g_flWitchRange = 500.0;
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
					g_esPlayer[iPlayer].g_iWitchAbility = 0;
					g_esPlayer[iPlayer].g_iWitchMessage = 0;
					g_esPlayer[iPlayer].g_iWitchAmount = 0;
					g_esPlayer[iPlayer].g_flWitchChance = 0.0;
					g_esPlayer[iPlayer].g_flWitchDamage = 0.0;
					g_esPlayer[iPlayer].g_flWitchRange = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iWitchAbility = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iWitchAbility, value, 0, 1);
		g_esPlayer[admin].g_iWitchMessage = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iWitchMessage, value, 0, 1);
		g_esPlayer[admin].g_iWitchAmount = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchAmount", "Witch Amount", "Witch_Amount", "amount", g_esPlayer[admin].g_iWitchAmount, value, 1, 25);
		g_esPlayer[admin].g_flWitchChance = flGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchChance", "Witch Chance", "Witch_Chance", "chance", g_esPlayer[admin].g_flWitchChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flWitchDamage = flGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchDamage", "Witch Damage", "Witch_Damage", "damage", g_esPlayer[admin].g_flWitchDamage, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flWitchRange = flGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchRange", "Witch Range", "Witch_Range", "range", g_esPlayer[admin].g_flWitchRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, "witchability", false) || StrEqual(subsection, "witch ability", false) || StrEqual(subsection, "witch_ability", false) || StrEqual(subsection, "witch", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iWitchAbility = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iWitchAbility, value, 0, 1);
		g_esAbility[type].g_iWitchMessage = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iWitchMessage, value, 0, 1);
		g_esAbility[type].g_iWitchAmount = iGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchAmount", "Witch Amount", "Witch_Amount", "amount", g_esAbility[type].g_iWitchAmount, value, 1, 25);
		g_esAbility[type].g_flWitchChance = flGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchChance", "Witch Chance", "Witch_Chance", "chance", g_esAbility[type].g_flWitchChance, value, 0.0, 100.0);
		g_esAbility[type].g_flWitchDamage = flGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchDamage", "Witch Damage", "Witch_Damage", "damage", g_esAbility[type].g_flWitchDamage, value, 1.0, 999999.0);
		g_esAbility[type].g_flWitchRange = flGetKeyValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchRange", "Witch Range", "Witch_Range", "range", g_esAbility[type].g_flWitchRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, "witchability", false) || StrEqual(subsection, "witch ability", false) || StrEqual(subsection, "witch_ability", false) || StrEqual(subsection, "witch", false))
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
	g_esCache[tank].g_flWitchChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWitchChance, g_esAbility[type].g_flWitchChance);
	g_esCache[tank].g_flWitchDamage = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWitchDamage, g_esAbility[type].g_flWitchDamage);
	g_esCache[tank].g_flWitchRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flWitchRange, g_esAbility[type].g_flWitchRange);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iWitchAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWitchAbility, g_esAbility[type].g_iWitchAbility);
	g_esCache[tank].g_iWitchAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWitchAmount, g_esAbility[type].g_iWitchAmount);
	g_esCache[tank].g_iWitchMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iWitchMessage, g_esAbility[type].g_iWitchMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vWitchRange(iTank);
			vRemoveWitch(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iWitchAbility == 1)
	{
		vWitchAbility(tank);
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

		if (button & MT_SPECIAL_KEY)
		{
			if (g_esCache[tank].g_iWitchAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman3", g_esPlayer[tank].g_iCooldown - iTime);
					case false: vWitchAbility(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveWitch(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	vWitchRange(tank);
}

static void vRemoveWitch(int tank)
{
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveWitch(iPlayer);
		}
	}
}

static void vSpawnWitch(int tank, float pos[3], float angles[3])
{
	static int iWitch;
	iWitch = CreateEntityByName("witch");
	if (bIsValidEntity(iWitch))
	{
		TeleportEntity(iWitch, pos, angles, NULL_VECTOR);
		DispatchSpawn(iWitch);
		ActivateEntity(iWitch);
		SetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity", tank);
	}
}

static void vWitchAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flWitchChance)
		{
			static int iTime;
			iTime = GetTime();
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);

				g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
				if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman4", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}

			static float flTankPos[3], flInfectedPos[3], flInfectedAngles[3], flDistance;
			static int iInfected;
			iInfected = -1;
			while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
			{
				if (iGetWitchCount() < g_esCache[tank].g_iWitchAmount)
				{
					GetClientAbsOrigin(tank, flTankPos);
					GetEntPropVector(iInfected, Prop_Send, "m_vecOrigin", flInfectedPos);
					GetEntPropVector(iInfected, Prop_Send, "m_angRotation", flInfectedAngles);

					flDistance = GetVectorDistance(flInfectedPos, flTankPos);
					if (flDistance <= g_esCache[tank].g_flWitchRange)
					{
						RemoveEntity(iInfected);
						vSpawnWitch(tank, flInfectedPos, flInfectedAngles);
					}
				}

				if (g_esCache[tank].g_iWitchMessage == 1)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Witch", sTankName);
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "WitchAmmo");
	}
}

static void vWitchRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(tank) && g_esCache[tank].g_iWitchAbility == 1)
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
		{
			return;
		}

		static float flTankPos[3], flTankAngles[3];
		GetClientAbsOrigin(tank, flTankPos);
		GetClientAbsAngles(tank, flTankAngles);
		vSpawnWitch(tank, flTankPos, flTankAngles);
	}
}