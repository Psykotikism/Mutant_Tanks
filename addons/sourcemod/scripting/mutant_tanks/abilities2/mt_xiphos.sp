/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2023  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_XIPHOS_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_XIPHOS_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Xiphos Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank can steal health from survivors and vice-versa.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Xiphos Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}
#else
	#if MT_XIPHOS_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_XIPHOS_SECTION "xiphosability"
#define MT_XIPHOS_SECTION2 "xiphos ability"
#define MT_XIPHOS_SECTION3 "xiphos_ability"
#define MT_XIPHOS_SECTION4 "xiphos"

#define MT_XIPHOS_TANK (1 << 0) // tank xiphos
#define MT_XIPHOS_SURVIVOR (1 << 1) // survivor xiphos

#define MT_MENU_XIPHOS "Xiphos Ability"

enum struct esXiphosPlayer
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flXiphosChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esXiphosPlayer g_esXiphosPlayer[MAXPLAYERS + 1];

enum struct esXiphosTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flXiphosChance;

	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esXiphosTeammate g_esXiphosTeammate[MAXPLAYERS + 1];

enum struct esXiphosAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flXiphosChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esXiphosAbility g_esXiphosAbility[MT_MAXTYPES + 1];

enum struct esXiphosSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flXiphosChance;

	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esXiphosSpecial g_esXiphosSpecial[MT_MAXTYPES + 1];

enum struct esXiphosCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flXiphosChance;

	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iXiphosAbility;
	int g_iXiphosEffect;
	int g_iXiphosMaxHealth;
	int g_iXiphosMessage;
}

esXiphosCache g_esXiphosCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_xiphos", cmdXiphosInfo, "View information about the Xiphos ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}
#endif

#if defined MT_ABILITIES_MAIN2
void vXiphosClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnXiphosTakeDamage);
}

#if !defined MT_ABILITIES_MAIN2
Action cmdXiphosInfo(int client, int args)
{
	client = iGetListenServerHost(client, g_bDedicated);

	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG5, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vXiphosMenu(client, MT_XIPHOS_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vXiphosMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_XIPHOS_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iXiphosMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Xiphos Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iXiphosMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esXiphosCache[param1].g_iXiphosAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "XiphosDetails");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esXiphosCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vXiphosMenu(param1, MT_XIPHOS_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pXiphos = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "XiphosMenu", param1);
			pXiphos.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN2
void vXiphosDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_XIPHOS, MT_MENU_XIPHOS);
}

#if defined MT_ABILITIES_MAIN2
void vXiphosMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_XIPHOS, false))
	{
		vXiphosMenu(client, MT_XIPHOS_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vXiphosMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_XIPHOS, false))
	{
		FormatEx(buffer, size, "%T", "XiphosMenu2", client);
	}
}

Action OnXiphosTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && !bIsPlayerIncapacitated(attacker) && g_esXiphosCache[attacker].g_iXiphosAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esXiphosCache[attacker].g_flXiphosChance && bIsSurvivor(victim) && !bIsSurvivorDisabled(victim))
		{
			if (bIsAreaNarrow(attacker, g_esXiphosCache[attacker].g_flOpenAreasOnly) || bIsAreaWide(attacker, g_esXiphosCache[attacker].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esXiphosPlayer[attacker].g_iTankType, attacker) || (g_esXiphosCache[attacker].g_iRequiresHumans > 0 && iGetHumanCount() < g_esXiphosCache[attacker].g_iRequiresHumans) || (!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esXiphosAbility[g_esXiphosPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esXiphosPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esXiphosPlayer[attacker].g_iTankType, g_esXiphosAbility[g_esXiphosPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esXiphosPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
			if ((!bIsInfected(attacker, MT_CHECK_FAKECLIENT) || g_esXiphosCache[attacker].g_iHumanAbility == 1) && (StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
			{
				vXiphos(attacker, victim, damage, true);
				vScreenEffect(victim, attacker, g_esXiphosCache[attacker].g_iXiphosEffect, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && !bIsPlayerIncapacitated(victim) && g_esXiphosCache[victim].g_iXiphosAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esXiphosCache[victim].g_flXiphosChance && bIsSurvivor(attacker) && !bIsSurvivorDisabled(attacker))
		{
			if (bIsAreaNarrow(victim, g_esXiphosCache[victim].g_flOpenAreasOnly) || bIsAreaWide(victim, g_esXiphosCache[victim].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esXiphosPlayer[victim].g_iTankType, victim) || (g_esXiphosCache[victim].g_iRequiresHumans > 0 && iGetHumanCount() < g_esXiphosCache[victim].g_iRequiresHumans) || (!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esXiphosAbility[g_esXiphosPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esXiphosPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esXiphosPlayer[victim].g_iTankType, g_esXiphosAbility[g_esXiphosPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esXiphosPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (!bIsInfected(victim, MT_CHECK_FAKECLIENT) || g_esXiphosCache[victim].g_iHumanAbility == 1)
			{
				if (damagetype & DMG_BULLET)
				{
					damage /= 20.0;
				}
				else if ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA))
				{
					damage /= 20.0;
				}
				else if ((damagetype & DMG_BURN) || (damagetype & DMG_DIRECT))
				{
					damage /= 200.0;
				}
				else if ((damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable"))
				{
					damage /= 20.0;
				}
				else if ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB))
				{
					damage /= 200.0;
				}

				vXiphos(attacker, victim, damage, false);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vXiphosPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_XIPHOS);
}

#if defined MT_ABILITIES_MAIN2
void vXiphosAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_XIPHOS_SECTION);
	list2.PushString(MT_XIPHOS_SECTION2);
	list3.PushString(MT_XIPHOS_SECTION3);
	list4.PushString(MT_XIPHOS_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vXiphosConfigsLoad(int mode)
#else
public void MT_OnConfigsLoad(int mode)
#endif
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esXiphosAbility[iIndex].g_iAccessFlags = 0;
				g_esXiphosAbility[iIndex].g_iImmunityFlags = 0;
				g_esXiphosAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esXiphosAbility[iIndex].g_iHumanAbility = 0;
				g_esXiphosAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esXiphosAbility[iIndex].g_iRequiresHumans = 0;
				g_esXiphosAbility[iIndex].g_iXiphosAbility = 0;
				g_esXiphosAbility[iIndex].g_iXiphosEffect = 0;
				g_esXiphosAbility[iIndex].g_iXiphosMessage = 0;
				g_esXiphosAbility[iIndex].g_flXiphosChance = 33.3;
				g_esXiphosAbility[iIndex].g_iXiphosMaxHealth = 100;

				g_esXiphosSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esXiphosSpecial[iIndex].g_iHumanAbility = -1;
				g_esXiphosSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esXiphosSpecial[iIndex].g_iRequiresHumans = -1;
				g_esXiphosSpecial[iIndex].g_iXiphosAbility = -1;
				g_esXiphosSpecial[iIndex].g_iXiphosEffect = -1;
				g_esXiphosSpecial[iIndex].g_iXiphosMessage = -1;
				g_esXiphosSpecial[iIndex].g_flXiphosChance = -1.0;
				g_esXiphosSpecial[iIndex].g_iXiphosMaxHealth = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esXiphosPlayer[iPlayer].g_iAccessFlags = -1;
				g_esXiphosPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esXiphosPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esXiphosPlayer[iPlayer].g_iHumanAbility = -1;
				g_esXiphosPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esXiphosPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esXiphosPlayer[iPlayer].g_iXiphosAbility = -1;
				g_esXiphosPlayer[iPlayer].g_iXiphosEffect = -1;
				g_esXiphosPlayer[iPlayer].g_iXiphosMessage = -1;
				g_esXiphosPlayer[iPlayer].g_flXiphosChance = -1.0;
				g_esXiphosPlayer[iPlayer].g_iXiphosMaxHealth = -1;

				g_esXiphosTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esXiphosTeammate[iPlayer].g_iHumanAbility = -1;
				g_esXiphosTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esXiphosTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esXiphosTeammate[iPlayer].g_iXiphosAbility = -1;
				g_esXiphosTeammate[iPlayer].g_iXiphosEffect = -1;
				g_esXiphosTeammate[iPlayer].g_iXiphosMessage = -1;
				g_esXiphosTeammate[iPlayer].g_flXiphosChance = -1.0;
				g_esXiphosTeammate[iPlayer].g_iXiphosMaxHealth = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vXiphosConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esXiphosTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esXiphosTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esXiphosTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esXiphosTeammate[admin].g_iHumanAbility, value, -1, 1);
			g_esXiphosTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esXiphosTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esXiphosTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esXiphosTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esXiphosTeammate[admin].g_iXiphosAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esXiphosTeammate[admin].g_iXiphosAbility, value, -1, 1);
			g_esXiphosTeammate[admin].g_iXiphosEffect = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esXiphosTeammate[admin].g_iXiphosEffect, value, -1, 1);
			g_esXiphosTeammate[admin].g_iXiphosMessage = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esXiphosTeammate[admin].g_iXiphosMessage, value, -1, 3);
			g_esXiphosTeammate[admin].g_flXiphosChance = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosChance", "Xiphos Chance", "Xiphos_Chance", "chance", g_esXiphosTeammate[admin].g_flXiphosChance, value, -1.0, 100.0);
			g_esXiphosTeammate[admin].g_iXiphosMaxHealth = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosMaxHealth", "Xiphos Max Health", "Xiphos_Max_Health", "maxhealth", g_esXiphosTeammate[admin].g_iXiphosMaxHealth, value, -1, MT_MAXHEALTH);
		}
		else
		{
			g_esXiphosPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esXiphosPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esXiphosPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esXiphosPlayer[admin].g_iHumanAbility, value, -1, 1);
			g_esXiphosPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esXiphosPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esXiphosPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esXiphosPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esXiphosPlayer[admin].g_iXiphosAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esXiphosPlayer[admin].g_iXiphosAbility, value, -1, 1);
			g_esXiphosPlayer[admin].g_iXiphosEffect = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esXiphosPlayer[admin].g_iXiphosEffect, value, -1, 1);
			g_esXiphosPlayer[admin].g_iXiphosMessage = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esXiphosPlayer[admin].g_iXiphosMessage, value, -1, 3);
			g_esXiphosPlayer[admin].g_flXiphosChance = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosChance", "Xiphos Chance", "Xiphos_Chance", "chance", g_esXiphosPlayer[admin].g_flXiphosChance, value, -1.0, 100.0);
			g_esXiphosPlayer[admin].g_iXiphosMaxHealth = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosMaxHealth", "Xiphos Max Health", "Xiphos_Max_Health", "maxhealth", g_esXiphosPlayer[admin].g_iXiphosMaxHealth, value, -1, MT_MAXHEALTH);
			g_esXiphosPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esXiphosPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esXiphosSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esXiphosSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esXiphosSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esXiphosSpecial[type].g_iHumanAbility, value, -1, 1);
			g_esXiphosSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esXiphosSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esXiphosSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esXiphosSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esXiphosSpecial[type].g_iXiphosAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esXiphosSpecial[type].g_iXiphosAbility, value, -1, 1);
			g_esXiphosSpecial[type].g_iXiphosEffect = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esXiphosSpecial[type].g_iXiphosEffect, value, -1, 1);
			g_esXiphosSpecial[type].g_iXiphosMessage = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esXiphosSpecial[type].g_iXiphosMessage, value, -1, 3);
			g_esXiphosSpecial[type].g_flXiphosChance = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosChance", "Xiphos Chance", "Xiphos_Chance", "chance", g_esXiphosSpecial[type].g_flXiphosChance, value, -1.0, 100.0);
			g_esXiphosSpecial[type].g_iXiphosMaxHealth = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosMaxHealth", "Xiphos Max Health", "Xiphos_Max_Health", "maxhealth", g_esXiphosSpecial[type].g_iXiphosMaxHealth, value, -1, MT_MAXHEALTH);
		}
		else
		{
			g_esXiphosAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esXiphosAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esXiphosAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esXiphosAbility[type].g_iHumanAbility, value, -1, 1);
			g_esXiphosAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esXiphosAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esXiphosAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esXiphosAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esXiphosAbility[type].g_iXiphosAbility = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esXiphosAbility[type].g_iXiphosAbility, value, -1, 1);
			g_esXiphosAbility[type].g_iXiphosEffect = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esXiphosAbility[type].g_iXiphosEffect, value, -1, 1);
			g_esXiphosAbility[type].g_iXiphosMessage = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esXiphosAbility[type].g_iXiphosMessage, value, -1, 3);
			g_esXiphosAbility[type].g_flXiphosChance = flGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosChance", "Xiphos Chance", "Xiphos_Chance", "chance", g_esXiphosAbility[type].g_flXiphosChance, value, -1.0, 100.0);
			g_esXiphosAbility[type].g_iXiphosMaxHealth = iGetKeyValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "XiphosMaxHealth", "Xiphos Max Health", "Xiphos_Max_Health", "maxhealth", g_esXiphosAbility[type].g_iXiphosMaxHealth, value, -1, MT_MAXHEALTH);
			g_esXiphosAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esXiphosAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_XIPHOS_SECTION, MT_XIPHOS_SECTION2, MT_XIPHOS_SECTION3, MT_XIPHOS_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vXiphosSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esXiphosPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esXiphosPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esXiphosPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esXiphosCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_flCloseAreasOnly, g_esXiphosPlayer[tank].g_flCloseAreasOnly, g_esXiphosSpecial[iType].g_flCloseAreasOnly, g_esXiphosAbility[iType].g_flCloseAreasOnly, 1);
		g_esXiphosCache[tank].g_flXiphosChance = flGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_flXiphosChance, g_esXiphosPlayer[tank].g_flXiphosChance, g_esXiphosSpecial[iType].g_flXiphosChance, g_esXiphosAbility[iType].g_flXiphosChance, 1);
		g_esXiphosCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_iHumanAbility, g_esXiphosPlayer[tank].g_iHumanAbility, g_esXiphosSpecial[iType].g_iHumanAbility, g_esXiphosAbility[iType].g_iHumanAbility, 1);
		g_esXiphosCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_flOpenAreasOnly, g_esXiphosPlayer[tank].g_flOpenAreasOnly, g_esXiphosSpecial[iType].g_flOpenAreasOnly, g_esXiphosAbility[iType].g_flOpenAreasOnly, 1);
		g_esXiphosCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_iRequiresHumans, g_esXiphosPlayer[tank].g_iRequiresHumans, g_esXiphosSpecial[iType].g_iRequiresHumans, g_esXiphosAbility[iType].g_iRequiresHumans, 1);
		g_esXiphosCache[tank].g_iXiphosAbility = iGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_iXiphosAbility, g_esXiphosPlayer[tank].g_iXiphosAbility, g_esXiphosSpecial[iType].g_iXiphosAbility, g_esXiphosAbility[iType].g_iXiphosAbility, 1);
		g_esXiphosCache[tank].g_iXiphosEffect = iGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_iXiphosEffect, g_esXiphosPlayer[tank].g_iXiphosEffect, g_esXiphosSpecial[iType].g_iXiphosEffect, g_esXiphosAbility[iType].g_iXiphosEffect, 1);
		g_esXiphosCache[tank].g_iXiphosMaxHealth = iGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_iXiphosMaxHealth, g_esXiphosPlayer[tank].g_iXiphosMaxHealth, g_esXiphosSpecial[iType].g_iXiphosMaxHealth, g_esXiphosAbility[iType].g_iXiphosMaxHealth, 1);
		g_esXiphosCache[tank].g_iXiphosMessage = iGetSubSettingValue(apply, bHuman, g_esXiphosTeammate[tank].g_iXiphosMessage, g_esXiphosPlayer[tank].g_iXiphosMessage, g_esXiphosSpecial[iType].g_iXiphosMessage, g_esXiphosAbility[iType].g_iXiphosMessage, 1);
	}
	else
	{
		g_esXiphosCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_flCloseAreasOnly, g_esXiphosAbility[iType].g_flCloseAreasOnly, 1);
		g_esXiphosCache[tank].g_flXiphosChance = flGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_flXiphosChance, g_esXiphosAbility[iType].g_flXiphosChance, 1);
		g_esXiphosCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_iHumanAbility, g_esXiphosAbility[iType].g_iHumanAbility, 1);
		g_esXiphosCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_flOpenAreasOnly, g_esXiphosAbility[iType].g_flOpenAreasOnly, 1);
		g_esXiphosCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_iRequiresHumans, g_esXiphosAbility[iType].g_iRequiresHumans, 1);
		g_esXiphosCache[tank].g_iXiphosAbility = iGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_iXiphosAbility, g_esXiphosAbility[iType].g_iXiphosAbility, 1);
		g_esXiphosCache[tank].g_iXiphosEffect = iGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_iXiphosEffect, g_esXiphosAbility[iType].g_iXiphosEffect, 1);
		g_esXiphosCache[tank].g_iXiphosMaxHealth = iGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_iXiphosMaxHealth, g_esXiphosAbility[iType].g_iXiphosMaxHealth, 1);
		g_esXiphosCache[tank].g_iXiphosMessage = iGetSettingValue(apply, bHuman, g_esXiphosPlayer[tank].g_iXiphosMessage, g_esXiphosAbility[iType].g_iXiphosMessage, 1);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

void vXiphos(int attacker, int victim, float damage, bool tank)
{
	int iTank = tank ? attacker : victim,
		iDamage = (damage < 1.0) ? 1 : RoundToNearest(damage),
		iHealth = GetEntProp(attacker, Prop_Data, "m_iHealth"),
		iMaxHealth = tank ? MT_MAXHEALTH : g_esXiphosCache[iTank].g_iXiphosMaxHealth,
		iNewHealth = (iHealth + iDamage), iLeftover = 0, iFinalHealth = 0, iTotalHealth = 0;
	iMaxHealth = (!tank && g_esXiphosCache[iTank].g_iXiphosMaxHealth == 0) ? GetEntProp(attacker, Prop_Data, "m_iMaxHealth") : iMaxHealth;
	iLeftover = (iNewHealth > iMaxHealth) ? (iNewHealth - iMaxHealth) : iNewHealth;
	iFinalHealth = iClamp(iNewHealth, 1, iMaxHealth);
	iTotalHealth = (iNewHealth > iMaxHealth) ? iLeftover : iDamage;
	SetEntProp(attacker, Prop_Data, "m_iHealth", iFinalHealth);

	if (tank)
	{
		MT_TankMaxHealth(attacker, 3, (MT_TankMaxHealth(attacker, 1) + iTotalHealth));
	}

	int iFlag = tank ? MT_XIPHOS_TANK : MT_XIPHOS_SURVIVOR;
	if (g_esXiphosCache[iTank].g_iXiphosMessage & iFlag)
	{
		char sTankName[33];
		MT_GetTankName(iTank, sTankName);

		switch (tank)
		{
			case true:
			{
				MT_PrintToChatAll("%s %t", MT_TAG2, "Xiphos", sTankName, victim);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Xiphos", LANG_SERVER, sTankName, victim);
			}
			case false:
			{
				MT_PrintToChatAll("%s %t", MT_TAG2, "Xiphos2", attacker, sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Xiphos2", LANG_SERVER, attacker, sTankName);
			}
		}
	}
}