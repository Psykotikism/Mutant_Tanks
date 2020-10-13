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

//#file "Throw Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Throw Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank throws cars, special infected, Witches, or itself.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Throw Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define MT_MENU_THROW "Throw Ability"

ConVar g_cvMTTankThrowForce;

enum struct esPlayer
{
	bool g_bActivated;

	float g_flThrowChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iThrowAbility;
	int g_iThrowCarOptions;
	int g_iThrowInfectedOptions;
	int g_iThrowMessage;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flThrowChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iThrowAbility;
	int g_iThrowCarOptions;
	int g_iThrowInfectedOptions;
	int g_iThrowMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flThrowChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iThrowAbility;
	int g_iThrowCarOptions;
	int g_iThrowInfectedOptions;
	int g_iThrowMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_throw", cmdThrowInfo, "View information about the Throw ability.");

	g_cvMTTankThrowForce = FindConVar("z_tank_throw_force");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_CAR, true);
	PrecacheModel(MODEL_CAR2, true);
	PrecacheModel(MODEL_CAR3, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveThrow(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveThrow(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdThrowInfo(int client, int args)
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
		case false: vThrowMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vThrowMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iThrowMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Throw Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iThrowMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iThrowAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				}
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ThrowDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vThrowMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "ThrowMenu", param1);
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
	menu.AddItem(MT_MENU_THROW, MT_MENU_THROW);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_THROW, false))
	{
		vThrowMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_THROW, false))
	{
		FormatEx(buffer, size, "%T", "ThrowMenu2", client);
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
	list.PushString("throwability");
	list2.PushString("throw ability");
	list3.PushString("throw_ability");
	list4.PushString("throw");
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
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iThrowAbility = 0;
				g_esAbility[iIndex].g_iThrowMessage = 0;
				g_esAbility[iIndex].g_iThrowCarOptions = 0;
				g_esAbility[iIndex].g_flThrowChance = 33.3;
				g_esAbility[iIndex].g_iThrowInfectedOptions = 0;
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
					g_esPlayer[iPlayer].g_iThrowAbility = 0;
					g_esPlayer[iPlayer].g_iThrowMessage = 0;
					g_esPlayer[iPlayer].g_iThrowCarOptions = 0;
					g_esPlayer[iPlayer].g_flThrowChance = 0.0;
					g_esPlayer[iPlayer].g_iThrowInfectedOptions = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iThrowAbility = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iThrowAbility, value, 0, 15);
		g_esPlayer[admin].g_iThrowMessage = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iThrowMessage, value, 0, 15);
		g_esPlayer[admin].g_iThrowCarOptions = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowCarOptions", "Throw Car Options", "Throw_Car_Options", "car", g_esPlayer[admin].g_iThrowCarOptions, value, 0, 7);
		g_esPlayer[admin].g_flThrowChance = flGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowChance", "Throw Chance", "Throw_Chance", "chance", g_esPlayer[admin].g_flThrowChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iThrowInfectedOptions = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowInfectedOptions", "Throw Infected Options", "Throw_Infected_Options", "infected", g_esPlayer[admin].g_iThrowInfectedOptions, value, 0, 127);

		if (StrEqual(subsection, "throwability", false) || StrEqual(subsection, "throw ability", false) || StrEqual(subsection, "throw_ability", false) || StrEqual(subsection, "throw", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iThrowAbility = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iThrowAbility, value, 0, 15);
		g_esAbility[type].g_iThrowMessage = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iThrowMessage, value, 0, 15);
		g_esAbility[type].g_iThrowCarOptions = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowCarOptions", "Throw Car Options", "Throw_Car_Options", "car", g_esAbility[type].g_iThrowCarOptions, value, 0, 7);
		g_esAbility[type].g_flThrowChance = flGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowChance", "Throw Chance", "Throw_Chance", "chance", g_esAbility[type].g_flThrowChance, value, 0.0, 100.0);
		g_esAbility[type].g_iThrowInfectedOptions = iGetKeyValue(subsection, "throwability", "throw ability", "throw_ability", "throw", key, "ThrowInfectedOptions", "Throw Infected Options", "Throw_Infected_Options", "infected", g_esAbility[type].g_iThrowInfectedOptions, value, 0, 127);

		if (StrEqual(subsection, "throwability", false) || StrEqual(subsection, "throw ability", false) || StrEqual(subsection, "throw_ability", false) || StrEqual(subsection, "throw", false))
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
	g_esCache[tank].g_flThrowChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flThrowChance, g_esAbility[type].g_flThrowChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iThrowAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowAbility, g_esAbility[type].g_iThrowAbility);
	g_esCache[tank].g_iThrowCarOptions = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowCarOptions, g_esAbility[type].g_iThrowCarOptions);
	g_esCache[tank].g_iThrowInfectedOptions = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowInfectedOptions, g_esAbility[type].g_iThrowInfectedOptions);
	g_esCache[tank].g_iThrowMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iThrowMessage, g_esAbility[type].g_iThrowMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveThrow(iTank);
		}
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

		if (button & MT_SPECIAL_KEY)
		{
			if (g_esCache[tank].g_iThrowAbility == 0 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;
				if (!g_esPlayer[tank].g_bActivated && !bRecharging)
				{
					switch (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
					{
						case true:
						{
							g_esPlayer[tank].g_bActivated = true;
							g_esPlayer[tank].g_iCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
						}
						case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowAmmo");
					}
				}
				else if (g_esPlayer[tank].g_bActivated)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman2");
				}
				else if (bRecharging)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ThrowHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveThrow(tank);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank) && g_esCache[tank].g_iThrowAbility > 0 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flThrowChance)
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility == 0) && !g_esPlayer[tank].g_bActivated)
		{
			g_esPlayer[tank].g_bActivated = true;
		}

		DataPack dpThrow;
		CreateDataTimer(0.1, tTimerThrow, dpThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpThrow.WriteCell(EntIndexToEntRef(rock));
		dpThrow.WriteCell(GetClientUserId(tank));
		dpThrow.WriteCell(g_esPlayer[tank].g_iTankType);
	}
}

static void vRemoveThrow(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveThrow(iPlayer);
		}
	}
}

public Action tTimerThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iRock;
	iRock = EntRefToEntIndex(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || (g_esCache[iTank].g_iThrowAbility == 0))
	{
		return Plugin_Stop;
	}

	if (!g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	static float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);

	static float flVector;
	flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		static int iAbilityCount, iAbilities[4], iAbilityFlag;
		iAbilityCount = 0;
		for (int iBit = 0; iBit < sizeof(iAbilities); iBit++)
		{
			iAbilityFlag = (1 << iBit);
			if (!(g_esCache[iTank].g_iThrowAbility & iAbilityFlag))
			{
				continue;
			}

			iAbilities[iAbilityCount] = iAbilityFlag;
			iAbilityCount++;
		}

		if (iAbilityCount > 0)
		{
			switch (iAbilities[GetRandomInt(0, iAbilityCount - 1)])
			{
				case 1:
				{
					static int iCar;
					iCar = CreateEntityByName("prop_physics");
					if (bIsValidEntity(iCar))
					{
						static int iOptionCount, iOptions[3], iFlag;
						iOptionCount = 0;
						for (int iBit = 0; iBit < sizeof(iOptions); iBit++)
						{
							iFlag = (1 << iBit);
							if (!(g_esCache[iTank].g_iThrowCarOptions & iFlag))
							{
								continue;
							}

							iOptions[iOptionCount] = iFlag;
							iOptionCount++;
						}

						switch (iOptions[GetRandomInt(0, iOptionCount - 1)])
						{
							case 1: SetEntityModel(iCar, MODEL_CAR);
							case 2: SetEntityModel(iCar, MODEL_CAR2);
							case 4: SetEntityModel(iCar, MODEL_CAR3);
							default:
							{
								switch (GetRandomInt(1, 3))
								{
									case 1: SetEntityModel(iCar, MODEL_CAR);
									case 2: SetEntityModel(iCar, MODEL_CAR2);
									case 3: SetEntityModel(iCar, MODEL_CAR3);
								}
							}
						}

						static int iCarColor[3];
						for (int iPos = 0; iPos < sizeof(iCarColor); iPos++)
						{
							iCarColor[iPos] = GetRandomInt(0, 255);
						}

						SetEntityRenderColor(iCar, iCarColor[0], iCarColor[1], iCarColor[2], 255);

						static float flPos[3];
						GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
						RemoveEntity(iRock);

						NormalizeVector(flVelocity, flVelocity);
						ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

						TeleportEntity(iCar, flPos, NULL_VECTOR, flVelocity);
						DispatchSpawn(iCar);

						CreateTimer(2.0, tTimerSetCarVelocity, EntIndexToEntRef(iCar), TIMER_FLAG_NO_MAPCHANGE);

						iCar = EntIndexToEntRef(iCar);
						vDeleteEntity(iCar, 10.0);

						if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_MELEE)
						{
							static char sTankName[33];
							MT_GetTankName(iTank, sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Throw", sTankName);
							MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Throw", sTankName);
						}
					}
				}
				case 2:
				{
					static int iInfected;
					iInfected = CreateFakeClient("Infected");
					if (bIsValidClient(iInfected))
					{
						static int iOptionCount, iOptions[7], iFlag;
						iOptionCount = 0;
						for (int iBit = 0; iBit < sizeof(iOptions); iBit++)
						{
							iFlag = (1 << iBit);
							if (!(g_esCache[iTank].g_iThrowInfectedOptions & iFlag))
							{
								continue;
							}

							iOptions[iOptionCount] = iFlag;
							iOptionCount++;
						}

						switch (iOptions[GetRandomInt(0, iOptionCount - 1)])
						{
							case 1: vSpawnInfected(iInfected, "smoker");
							case 2: vSpawnInfected(iInfected, "boomer");
							case 4: vSpawnInfected(iInfected, "hunter");
							case 8: vSpawnInfected(iInfected, bIsValidGame() ? "spitter" : "boomer");
							case 16: vSpawnInfected(iInfected, bIsValidGame() ? "jockey" : "hunter");
							case 32: vSpawnInfected(iInfected, bIsValidGame() ? "charger" : "smoker");
							case 64: vSpawnInfected(iInfected, "tank");
							default:
							{
								switch (GetRandomInt(1, 7))
								{
									case 1: vSpawnInfected(iInfected, "smoker");
									case 2: vSpawnInfected(iInfected, "boomer");
									case 3: vSpawnInfected(iInfected, "hunter");
									case 4: vSpawnInfected(iInfected, bIsValidGame() ? "spitter" : "boomer");
									case 5: vSpawnInfected(iInfected, bIsValidGame() ? "jockey" : "hunter");
									case 6: vSpawnInfected(iInfected, bIsValidGame() ? "charger" : "smoker");
									case 7: vSpawnInfected(iInfected, "tank");
								}
							}
						}

						static float flPos[3];
						GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
						RemoveEntity(iRock);

						NormalizeVector(flVelocity, flVelocity);
						ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

						TeleportEntity(iInfected, flPos, NULL_VECTOR, flVelocity);

						if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_RANGE)
						{
							static char sTankName[33];
							MT_GetTankName(iTank, sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Throw2", sTankName);
							MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Throw2", sTankName);
						}
					}
				}
				case 4:
				{
					static float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					RemoveEntity(iRock);

					NormalizeVector(flVelocity, flVelocity);
					ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

					TeleportEntity(iTank, flPos, NULL_VECTOR, flVelocity);

					if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_SPECIAL)
					{
						static char sTankName[33];
						MT_GetTankName(iTank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Throw3", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Throw3", sTankName);
					}
				}
				case 8:
				{
					static int iWitch;
					iWitch = CreateEntityByName("witch");
					if (bIsValidEntity(iWitch))
					{
						static float flPos[3];
						GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
						RemoveEntity(iRock);

						NormalizeVector(flVelocity, flVelocity);
						ScaleVector(flVelocity, g_cvMTTankThrowForce.FloatValue * 1.4);

						TeleportEntity(iWitch, flPos, NULL_VECTOR, flVelocity);
						DispatchSpawn(iWitch);
						ActivateEntity(iWitch);
						SetEntProp(iWitch, Prop_Send, "m_hOwnerEntity", iTank);
					}

					if (g_esCache[iTank].g_iThrowMessage & MT_MESSAGE_SPECIAL2)
					{
						static char sTankName[33];
						MT_GetTankName(iTank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Throw4", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Throw4", sTankName);
					}
				}
			}
		}

		g_esPlayer[iTank].g_bActivated = false;

		static int iTime;
		iTime = GetTime();
		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iTime))
		{
			g_esPlayer[iTank].g_iCooldown = (g_esPlayer[iTank].g_iCount < g_esCache[iTank].g_iHumanAmmo && g_esCache[iTank].g_iHumanAmmo > 0) ? (iTime + g_esCache[iTank].g_iHumanCooldown) : -1;
			if (g_esPlayer[iTank].g_iCooldown != -1 && g_esPlayer[iTank].g_iCooldown > iTime)
			{
				MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ThrowHuman4", g_esPlayer[iTank].g_iCooldown - iTime);
			}
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerSetCarVelocity(Handle timer, int ref)
{
	static int iCar;
	iCar = EntRefToEntIndex(ref);
	if (iCar == INVALID_ENT_REFERENCE || !bIsValidEntity(iCar))
	{
		return Plugin_Stop;
	}

	TeleportEntity(iCar, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));

	return Plugin_Continue;
}