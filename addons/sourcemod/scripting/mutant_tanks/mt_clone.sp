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
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

//#file "Clone Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Clone Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates clones of itself.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Clone Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	CreateNative("MT_IsCloneSupported", aNative_IsCloneSupported);
	CreateNative("MT_IsTankClone", aNative_IsTankClone);

	RegPluginLibrary("mt_clone");

	return APLRes_Success;
}

#define MT_MENU_CLONE "Clone Ability"

enum struct esPlayer
{
	bool g_bCloned;

	float g_flCloneChance;

	int g_iAccessFlags;
	int g_iCloneAbility;
	int g_iCloneAmount;
	int g_iCloneHealth;
	int g_iCloneMessage;
	int g_iCloneMode;
	int g_iCloneReplace;
	int g_iCloneType;
	int g_iCooldown;
	int g_iCount;
	int g_iCount2;
	int g_iOwner;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flCloneChance;

	int g_iAccessFlags;
	int g_iCloneAbility;
	int g_iCloneAmount;
	int g_iCloneHealth;
	int g_iCloneMessage;
	int g_iCloneMode;
	int g_iCloneReplace;
	int g_iCloneType;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flCloneChance;

	int g_iCloneAbility;
	int g_iCloneAmount;
	int g_iCloneHealth;
	int g_iCloneMessage;
	int g_iCloneMode;
	int g_iCloneReplace;
	int g_iCloneType;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public any aNative_IsCloneSupported(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
	{
		int iOwner = g_esPlayer[iTank].g_iOwner;
		if (g_esPlayer[iTank].g_iTankType == g_esPlayer[iOwner].g_iTankType && g_esCache[iOwner].g_iCloneMode == 0 && g_esPlayer[iTank].g_bCloned)
		{
			return false;
		}
	}

	return true;
}

public any aNative_IsTankClone(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	return MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iTank].g_bCloned;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_clone", cmdCloneInfo, "View information about the Clone ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveClone(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveClone(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdCloneInfo(int client, int args)
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
		case false: vCloneMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vCloneMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iCloneMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Clone Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iCloneMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iCloneAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount2, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "CloneDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vCloneMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "CloneMenu", param1);
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
	menu.AddItem(MT_MENU_CLONE, MT_MENU_CLONE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_CLONE, false))
	{
		vCloneMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_CLONE, false))
	{
		FormatEx(buffer, size, "%T", "CloneMenu2", client);
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
	list.PushString("cloneability");
	list2.PushString("clone ability");
	list3.PushString("clone_ability");
	list4.PushString("clone");
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
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 60;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iCloneAbility = 0;
				g_esAbility[iIndex].g_iCloneMessage = 0;
				g_esAbility[iIndex].g_iCloneAmount = 2;
				g_esAbility[iIndex].g_flCloneChance = 33.3;
				g_esAbility[iIndex].g_iCloneHealth = 1000;
				g_esAbility[iIndex].g_iCloneMode = 0;
				g_esAbility[iIndex].g_iCloneReplace = 1;
				g_esAbility[iIndex].g_iCloneType = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iCloneAbility = 0;
					g_esPlayer[iPlayer].g_iCloneMessage = 0;
					g_esPlayer[iPlayer].g_iCloneAmount = 0;
					g_esPlayer[iPlayer].g_flCloneChance = 0.0;
					g_esPlayer[iPlayer].g_iCloneHealth = 0;
					g_esPlayer[iPlayer].g_iCloneMode = 0;
					g_esPlayer[iPlayer].g_iCloneReplace = 0;
					g_esPlayer[iPlayer].g_iCloneType = -1;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iCloneAbility = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iCloneAbility, value, 0, 1);
		g_esPlayer[admin].g_iCloneMessage = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iCloneMessage, value, 0, 1);
		g_esPlayer[admin].g_iCloneAmount = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneAmount", "Clone Amount", "Clone_Amount", "amount", g_esPlayer[admin].g_iCloneAmount, value, 1, 15);
		g_esPlayer[admin].g_flCloneChance = flGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneChance", "Clone Chance", "Clone_Chance", "chance", g_esPlayer[admin].g_flCloneChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iCloneHealth = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneHealth", "Clone Health", "Clone_Health", "health", g_esPlayer[admin].g_iCloneHealth, value, 1, MT_MAXHEALTH);
		g_esPlayer[admin].g_iCloneMode = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneMode", "Clone Mode", "Clone_Mode", "mode", g_esPlayer[admin].g_iCloneMode, value, 0, 1);
		g_esPlayer[admin].g_iCloneReplace = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneReplace", "Clone Replace", "Clone_Replace", "replace", g_esPlayer[admin].g_iCloneReplace, value, 0, 1);
		g_esPlayer[admin].g_iCloneType = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneType", "Clone Type", "Clone_Type", "type", g_esPlayer[admin].g_iCloneType, value, -1, MT_MAXTYPES);

		if (StrEqual(subsection, "cloneability", false) || StrEqual(subsection, "clone ability", false) || StrEqual(subsection, "clone_ability", false) || StrEqual(subsection, "clone", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iCloneAbility = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iCloneAbility, value, 0, 1);
		g_esAbility[type].g_iCloneMessage = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iCloneMessage, value, 0, 1);
		g_esAbility[type].g_iCloneAmount = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneAmount", "Clone Amount", "Clone_Amount", "amount", g_esAbility[type].g_iCloneAmount, value, 1, 15);
		g_esAbility[type].g_flCloneChance = flGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneChance", "Clone Chance", "Clone_Chance", "chance", g_esAbility[type].g_flCloneChance, value, 0.0, 100.0);
		g_esAbility[type].g_iCloneHealth = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneHealth", "Clone Health", "Clone_Health", "health", g_esAbility[type].g_iCloneHealth, value, 1, MT_MAXHEALTH);
		g_esAbility[type].g_iCloneMode = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneMode", "Clone Mode", "Clone_Mode", "mode", g_esAbility[type].g_iCloneMode, value, 0, 1);
		g_esAbility[type].g_iCloneReplace = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneReplace", "Clone Replace", "Clone_Replace", "replace", g_esAbility[type].g_iCloneReplace, value, 0, 1);
		g_esAbility[type].g_iCloneType = iGetKeyValue(subsection, "cloneability", "clone ability", "clone_ability", "clone", key, "CloneType", "Clone Type", "Clone_Type", "type", g_esAbility[type].g_iCloneType, value, -1, MT_MAXTYPES);

		if (StrEqual(subsection, "cloneability", false) || StrEqual(subsection, "clone ability", false) || StrEqual(subsection, "clone_ability", false) || StrEqual(subsection, "clone", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flCloneChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flCloneChance, g_esAbility[type].g_flCloneChance);
	g_esCache[tank].g_iCloneAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCloneAbility, g_esAbility[type].g_iCloneAbility);
	g_esCache[tank].g_iCloneAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCloneAmount, g_esAbility[type].g_iCloneAmount);
	g_esCache[tank].g_iCloneHealth = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCloneHealth, g_esAbility[type].g_iCloneHealth);
	g_esCache[tank].g_iCloneMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCloneMessage, g_esAbility[type].g_iCloneMessage);
	g_esCache[tank].g_iCloneMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCloneMode, g_esAbility[type].g_iCloneMode);
	g_esCache[tank].g_iCloneReplace = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCloneReplace, g_esAbility[type].g_iCloneReplace);
	g_esCache[tank].g_iCloneType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCloneType, g_esAbility[type].g_iCloneType);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iClone = 1; iClone <= MaxClients; iClone++)
	{
		if (bIsTank(iClone, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iClone].g_bCloned)
		{
			switch (bIsValidClient(iClone, MT_CHECK_FAKECLIENT))
			{
				case true: ForcePlayerSuicide(iClone);
				case false: KickClient(iClone);
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveClone(iTank, true);

			if (g_esCache[iTank].g_iCloneAbility == 1)
			{
				switch (g_esPlayer[iTank].g_bCloned)
				{
					case true:
					{
						for (int iOwner = 1; iOwner <= MaxClients; iOwner++)
						{
							if (MT_IsTankSupported(iOwner, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iTank].g_iOwner == iOwner)
							{
								g_esPlayer[iTank].g_bCloned = false;
								g_esPlayer[iTank].g_iOwner = 0;

								switch (g_esPlayer[iOwner].g_iCount)
								{
									case 0, 1:
									{
										g_esPlayer[iOwner].g_iCount = 0;

										static int iTime;
										iTime = GetTime();
										if (MT_IsTankSupported(iOwner, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iOwner) || bHasAdminAccess(iOwner, g_esAbility[g_esPlayer[iOwner].g_iTankType].g_iAccessFlags, g_esPlayer[iOwner].g_iAccessFlags)) && g_esCache[iOwner].g_iHumanAbility == 1 && (g_esPlayer[iOwner].g_iCooldown == -1 || g_esPlayer[iOwner].g_iCooldown < iTime))
										{
											g_esPlayer[iOwner].g_iCooldown = (g_esPlayer[iOwner].g_iCount < g_esCache[iOwner].g_iHumanAmmo && g_esCache[iOwner].g_iHumanAmmo > 0) ? (iTime + g_esCache[iOwner].g_iHumanCooldown) : -1;
											if (g_esPlayer[iOwner].g_iCooldown != -1 && g_esPlayer[iOwner].g_iCooldown > iTime)
											{
												MT_PrintToChat(iOwner, "%s %t", MT_TAG3, "CloneHuman6", g_esPlayer[iOwner].g_iCooldown - iTime);
											}
										}
									}
									default:
									{
										if (g_esCache[iOwner].g_iCloneReplace == 1)
										{
											g_esPlayer[iOwner].g_iCount--;
										}

										if (MT_IsTankSupported(iOwner, MT_CHECK_FAKECLIENT) && g_esCache[iOwner].g_iHumanAbility == 1)
										{
											MT_PrintToChat(iOwner, "%s %t", MT_TAG3, "CloneHuman5");
										}
									}
								}

								break;
							}
						}
					}
					case false:
					{
						for (int iClone = 1; iClone <= MaxClients; iClone++)
						{
							if (MT_IsTankSupported(iTank, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iClone].g_iOwner == iTank)
							{
								g_esPlayer[iClone].g_iOwner = 0;
							}
						}
					}
				}
			}
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && g_esCache[tank].g_iCloneAbility == 1 && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
	{
		vCloneAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY)
		{
			if (g_esCache[tank].g_iCloneAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;
				if (!g_esPlayer[tank].g_bCloned && !bRecharging)
				{
					vCloneAbility(tank);
				}
				else if (g_esPlayer[tank].g_bCloned)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman3");
				}
				else if (bRecharging)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman4", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveClone(tank, revert);
}

static void vClone(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	iTypeCount = 0;
	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
	{
		if (!MT_IsTypeEnabled(iIndex) || !MT_CanTypeSpawn(iIndex) || MT_DoesTypeRequireHumans(iIndex) || g_esAbility[iIndex].g_iCloneAbility == 1 || g_esPlayer[tank].g_iTankType == iIndex)
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	static int iType;
	iType = (iTypeCount > 0) ? iTankTypes[GetRandomInt(1, iTypeCount)] : g_esPlayer[tank].g_iTankType;
	MT_SpawnTank(tank, iType);
}

static void vCloneAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iCloneAmount && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flCloneChance)
		{
			static float flHitPosition[3], flPosition[3], flAngles[3], flVector[3];
			GetClientEyePosition(tank, flPosition);
			GetClientEyeAngles(tank, flAngles);
			flAngles[0] = -25.0;

			GetAngleVectors(flAngles, flAngles, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(flAngles, flAngles);
			ScaleVector(flAngles, -1.0);
			vCopyVector(flAngles, flVector);
			GetVectorAngles(flAngles, flAngles);

			static Handle hTrace;
			hTrace = TR_TraceRayFilterEx(flPosition, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
			if (hTrace != null)
			{
				if (TR_DidHit(hTrace))
				{
					TR_GetEndPosition(flHitPosition, hTrace);
					NormalizeVector(flVector, flVector);
					ScaleVector(flVector, -40.0);
					AddVectors(flHitPosition, flVector, flHitPosition);

					static float flDistance;
					flDistance = GetVectorDistance(flHitPosition, flPosition);
					if (40.0 < flDistance < 200.0)
					{
						bool[] bTankBoss = new bool[MaxClients + 1];
						for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
						{
							bTankBoss[iPlayer] = false;
							if (MT_IsTankSupported(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
							{
								bTankBoss[iPlayer] = true;
							}
						}

						switch (g_esCache[tank].g_iCloneType)
						{
							case -1: MT_SpawnTank(tank, g_esPlayer[tank].g_iTankType);
							case 0: vClone(tank);
							default:
							{
								static int iType;
								iType = (g_esAbility[g_esCache[tank].g_iCloneType].g_iCloneAbility == 1) ? g_esPlayer[tank].g_iTankType : g_esCache[tank].g_iCloneType;
								MT_SpawnTank(tank, iType);
							}
						}

						static int iSelectedType;
						iSelectedType = 0;
						for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
						{
							if (MT_IsTankSupported(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !bTankBoss[iPlayer])
							{
								iSelectedType = iPlayer;

								break;
							}
						}

						if (bIsTank(iSelectedType))
						{
							TeleportEntity(iSelectedType, flHitPosition, NULL_VECTOR, NULL_VECTOR);

							g_esPlayer[iSelectedType].g_bCloned = true;
							g_esPlayer[tank].g_iCount++;
							g_esPlayer[iSelectedType].g_iOwner = tank;

							static int iNewHealth;
							iNewHealth = (g_esCache[tank].g_iCloneHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : g_esCache[tank].g_iCloneHealth;
							//SetEntityHealth(iSelectedType, iNewHealth);
							SetEntProp(iSelectedType, Prop_Data, "m_iHealth", iNewHealth);
							SetEntProp(iSelectedType, Prop_Data, "m_iMaxHealth", iNewHealth);

							if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
							{
								g_esPlayer[tank].g_iCount2++;

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman", g_esPlayer[tank].g_iCount2, g_esCache[tank].g_iHumanAmmo);
							}

							if (g_esCache[tank].g_iCloneMessage == 1)
							{
								static char sTankName[33];
								MT_GetTankName(tank, sTankName);
								MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Clone", sTankName);
							}
						}
					}
				}

				delete hTrace;
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CloneAmmo");
	}
}

static void vRemoveClone(int tank, bool revert = false)
{
	if (!revert)
	{
		g_esPlayer[tank].g_bCloned = false;
	}

	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveClone(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}