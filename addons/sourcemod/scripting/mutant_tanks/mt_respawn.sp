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

//#file "Respawn Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Respawn Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank respawns upon death.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Respawn Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_RESPAWN "Respawn Ability"

enum struct esPlayer
{
	bool g_bRespawn;

	float g_flRespawnChance;

	int g_iAccessFlags;
	int g_iCount;
	int g_iCount2;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flRespawnChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flRespawnChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_respawn", cmdRespawnInfo, "View information about the Respawn ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveRespawn(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveRespawn(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRespawnInfo(int client, int args)
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
		case false: vRespawnMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRespawnMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRespawnMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Respawn Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRespawnMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iRespawnAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount2, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RespawnDetails");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vRespawnMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "RespawnMenu", param1);
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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
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
	menu.AddItem(MT_MENU_RESPAWN, MT_MENU_RESPAWN);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_RESPAWN, false))
	{
		vRespawnMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_RESPAWN, false))
	{
		FormatEx(buffer, size, "%T", "RespawnMenu2", client);
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
	list.PushString("respawnability");
	list2.PushString("respawn ability");
	list3.PushString("respawn_ability");
	list4.PushString("respawn");
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
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iRespawnAbility = 0;
				g_esAbility[iIndex].g_iRespawnMessage = 0;
				g_esAbility[iIndex].g_iRespawnAmount = 1;
				g_esAbility[iIndex].g_flRespawnChance = 33.3;
				g_esAbility[iIndex].g_iRespawnMaxType = 0;
				g_esAbility[iIndex].g_iRespawnMinType = 0;
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
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iRespawnAbility = 0;
					g_esPlayer[iPlayer].g_iRespawnMessage = 0;
					g_esPlayer[iPlayer].g_iRespawnAmount = 0;
					g_esPlayer[iPlayer].g_flRespawnChance = 0.0;
					g_esPlayer[iPlayer].g_iRespawnMaxType = 0;
					g_esPlayer[iPlayer].g_iRespawnMinType = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iRespawnAbility = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iRespawnAbility, value, 0, 1);
		g_esPlayer[admin].g_iRespawnMessage = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iRespawnMessage, value, 0, 1);
		g_esPlayer[admin].g_iRespawnAmount = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esPlayer[admin].g_iRespawnAmount, value, 1, 999999);
		g_esPlayer[admin].g_flRespawnChance = flGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esPlayer[admin].g_flRespawnChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "respawnability", false) || StrEqual(subsection, "respawn ability", false) || StrEqual(subsection, "respawn_ability", false) || StrEqual(subsection, "respawn", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RespawnType", false) || StrEqual(key, "Respawn Type", false) || StrEqual(key, "Respawn_Type", false) || StrEqual(key, "type", false))
			{
				static char sValue[10];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");

				static char sRange[2][5];
				ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

				g_esPlayer[admin].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esPlayer[admin].g_iRespawnMinType;
				g_esPlayer[admin].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esPlayer[admin].g_iRespawnMaxType;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iRespawnAbility = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iRespawnAbility, value, 0, 1);
		g_esAbility[type].g_iRespawnMessage = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRespawnMessage, value, 0, 1);
		g_esAbility[type].g_iRespawnAmount = iGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esAbility[type].g_iRespawnAmount, value, 1, 999999);
		g_esAbility[type].g_flRespawnChance = flGetKeyValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esAbility[type].g_flRespawnChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "respawnability", false) || StrEqual(subsection, "respawn ability", false) || StrEqual(subsection, "respawn_ability", false) || StrEqual(subsection, "respawn", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RespawnType", false) || StrEqual(key, "Respawn Type", false) || StrEqual(key, "Respawn_Type", false) || StrEqual(key, "type", false))
			{
				static char sValue[10];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");

				static char sRange[2][5];
				ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

				g_esAbility[type].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esAbility[type].g_iRespawnMinType;
				g_esAbility[type].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esAbility[type].g_iRespawnMaxType;
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);\
	g_esCache[tank].g_flRespawnChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRespawnChance, g_esAbility[type].g_flRespawnChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iRespawnAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnAbility, g_esAbility[type].g_iRespawnAbility);
	g_esCache[tank].g_iRespawnAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnAmount, g_esAbility[type].g_iRespawnAmount);
	g_esCache[tank].g_iRespawnMaxType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnMaxType, g_esAbility[type].g_iRespawnMaxType);
	g_esCache[tank].g_iRespawnMinType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnMinType, g_esAbility[type].g_iRespawnMinType);
	g_esCache[tank].g_iRespawnMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnMessage, g_esAbility[type].g_iRespawnMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iTank) && g_esCache[iTank].g_iRespawnAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[iTank].g_flRespawnChance)
		{
			if (MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)))
			{
				return;
			}

			float flPos[3], flAngles[3];
			GetEntPropVector(iTank, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(iTank, Prop_Send, "m_angRotation", flAngles);

			DataPack dpRespawn;
			CreateDataTimer(0.4, tTimerRespawn, dpRespawn, TIMER_FLAG_NO_MAPCHANGE);
			dpRespawn.WriteCell(GetClientUserId(iTank));
			dpRespawn.WriteFloat(flPos[0]);
			dpRespawn.WriteFloat(flPos[1]);
			dpRespawn.WriteFloat(flPos[2]);
			dpRespawn.WriteFloat(flAngles[0]);
			dpRespawn.WriteFloat(flAngles[1]);
			dpRespawn.WriteFloat(flAngles[2]);
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

		if (button & MT_SPECIAL_KEY2)
		{
			if (g_esCache[tank].g_iRespawnAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bRespawn)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman2");
					case false:
					{
						switch (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							case true:
							{
								g_esPlayer[tank].g_bRespawn = true;

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman");
							}
							case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveRespawn(tank);
}

static void vRemoveRespawn(int tank)
{
	g_esPlayer[tank].g_bRespawn = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRespawn(iPlayer);
		}
	}
}

static void vRespawn(int tank, int min = 0, int max = 0)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static int iMin, iMax, iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	iMin = (min > 0) ? min : MT_GetMinType();
	iMax = (max > 0) ? max : MT_GetMaxType();
	iTypeCount = 0;
	for (int iIndex = iMin; iIndex <= iMax; iIndex++)
	{
		if (!MT_IsTypeEnabled(iIndex) || !MT_CanTypeSpawn(iIndex) || MT_DoesTypeRequireHumans(iIndex) || g_esAbility[iIndex].g_iRespawnAbility == 1 || g_esPlayer[tank].g_iTankType == iIndex)
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

public Action tTimerRespawn(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank;
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || g_esCache[iTank].g_iRespawnAbility == 0)
	{
		g_esPlayer[iTank].g_iCount = 0;

		return Plugin_Stop;
	}

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && !g_esPlayer[iTank].g_bRespawn)
	{
		g_esPlayer[iTank].g_bRespawn = false;
		g_esPlayer[iTank].g_iCount = 0;

		return Plugin_Stop;
	}

	static float flPos[3], flAngles[3];
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	flAngles[0] = pack.ReadFloat();
	flAngles[1] = pack.ReadFloat();
	flAngles[2] = pack.ReadFloat();

	if (g_esPlayer[iTank].g_iCount < g_esCache[iTank].g_iRespawnAmount && (!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esPlayer[iTank].g_iCount2 < g_esCache[iTank].g_iHumanAmmo && g_esCache[iTank].g_iHumanAmmo > 0)))
	{
		g_esPlayer[iTank].g_bRespawn = false;
		g_esPlayer[iTank].g_iCount++;

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1)
		{
			g_esPlayer[iTank].g_iCount2++;

			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "RespawnHuman3", g_esPlayer[iTank].g_iCount2, g_esCache[iTank].g_iHumanAmmo);
		}

		bool[] bExists = new bool[MaxClients + 1];
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			bExists[iRespawn] = false;
			if (MT_IsTankSupported(iRespawn, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iRespawn))
			{
				bExists[iRespawn] = true;
			}
		}

		if (g_esCache[iTank].g_iRespawnMinType == 0 || g_esCache[iTank].g_iRespawnMaxType == 0)
		{
			vRespawn(iTank);
		}
		else
		{
			vRespawn(iTank, g_esCache[iTank].g_iRespawnMinType, g_esCache[iTank].g_iRespawnMaxType);
		}

		static int iNewTank;
		iNewTank = 0;
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			if (MT_IsTankSupported(iRespawn, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iRespawn) && !bExists[iRespawn])
			{
				iNewTank = iRespawn;
				g_esPlayer[iNewTank].g_bRespawn = false;
				g_esPlayer[iNewTank].g_iCount = g_esPlayer[iTank].g_iCount;
				g_esPlayer[iNewTank].g_iCount2 = g_esPlayer[iTank].g_iCount2;

				vRemoveRespawn(iTank);

				break;
			}
		}

		if (bIsTank(iNewTank))
		{
			TeleportEntity(iNewTank, flPos, flAngles, NULL_VECTOR);

			if (g_esCache[iTank].g_iRespawnMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(iTank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Respawn", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Respawn", LANG_SERVER, sTankName);
			}
		}
		else
		{
			vRemoveRespawn(iTank);
		}
	}
	else
	{
		vRemoveRespawn(iTank);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "RespawnAmmo");
		}
	}

	return Plugin_Continue;
}