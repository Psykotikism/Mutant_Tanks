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

#define MT_VAMPIRE_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_VAMPIRE_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Vampire Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank gains health from hurting survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Vampire Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}
#else
	#if MT_VAMPIRE_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_VAMPIRE_SECTION "vampireability"
#define MT_VAMPIRE_SECTION2 "vampire ability"
#define MT_VAMPIRE_SECTION3 "vampire_ability"
#define MT_VAMPIRE_SECTION4 "vampire"

#define MT_MENU_VAMPIRE "Vampire Ability"

enum struct esVampirePlayer
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flVampireChance;
	float g_flVampireHealthMultiplier;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iVampireAbility;
	int g_iVampireEffect;
	int g_iVampireHealth;
	int g_iVampireMessage;
}

esVampirePlayer g_esVampirePlayer[MAXPLAYERS + 1];

enum struct esVampireTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flVampireChance;
	float g_flVampireHealthMultiplier;

	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iVampireAbility;
	int g_iVampireEffect;
	int g_iVampireHealth;
	int g_iVampireMessage;
}

esVampireTeammate g_esVampireTeammate[MAXPLAYERS + 1];

enum struct esVampireAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flVampireChance;
	float g_flVampireHealthMultiplier;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iVampireAbility;
	int g_iVampireEffect;
	int g_iVampireHealth;
	int g_iVampireMessage;
}

esVampireAbility g_esVampireAbility[MT_MAXTYPES + 1];

enum struct esVampireSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flVampireChance;
	float g_flVampireHealthMultiplier;

	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iVampireAbility;
	int g_iVampireEffect;
	int g_iVampireHealth;
	int g_iVampireMessage;
}

esVampireSpecial g_esVampireSpecial[MT_MAXTYPES + 1];

enum struct esVampireCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flVampireChance;
	float g_flVampireHealthMultiplier;

	int g_iHumanAbility;
	int g_iRequiresHumans;
	int g_iVampireAbility;
	int g_iVampireEffect;
	int g_iVampireHealth;
	int g_iVampireMessage;
}

esVampireCache g_esVampireCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_vampire", cmdVampireInfo, "View information about the Vampire ability.");

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
void vVampireClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnVampireTakeDamage);
}

#if !defined MT_ABILITIES_MAIN2
Action cmdVampireInfo(int client, int args)
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
		case false: vVampireMenu(client, MT_VAMPIRE_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vVampireMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_VAMPIRE_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iVampireMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Vampire Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iVampireMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esVampireCache[param1].g_iVampireAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "VampireDetails");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esVampireCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vVampireMenu(param1, MT_VAMPIRE_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pVampire = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "VampireMenu", param1);
			pVampire.SetTitle(sMenuTitle);
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
void vVampireDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_VAMPIRE, MT_MENU_VAMPIRE);
}

#if defined MT_ABILITIES_MAIN2
void vVampireMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_VAMPIRE, false))
	{
		vVampireMenu(client, MT_VAMPIRE_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vVampireMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_VAMPIRE, false))
	{
		FormatEx(buffer, size, "%T", "VampireMenu2", client);
	}
}

Action OnVampireTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		bool bCaught = bIsSurvivorCaught(victim);
		if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
		{
			if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && !bIsPlayerIncapacitated(attacker) && g_esVampireCache[attacker].g_iVampireAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esVampireCache[attacker].g_flVampireChance && bIsSurvivor(victim))
			{
				if (bIsAreaNarrow(attacker, g_esVampireCache[attacker].g_flOpenAreasOnly) || bIsAreaWide(attacker, g_esVampireCache[attacker].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esVampirePlayer[attacker].g_iTankType, attacker) || (g_esVampireCache[attacker].g_iRequiresHumans > 0 && iGetHumanCount() < g_esVampireCache[attacker].g_iRequiresHumans) || (!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esVampireAbility[g_esVampirePlayer[attacker].g_iTankType].g_iAccessFlags, g_esVampirePlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esVampirePlayer[attacker].g_iTankType, g_esVampireAbility[g_esVampirePlayer[attacker].g_iTankType].g_iImmunityFlags, g_esVampirePlayer[victim].g_iImmunityFlags))
				{
					return Plugin_Continue;
				}

				if (!bIsInfected(attacker, MT_CHECK_FAKECLIENT) || g_esVampireCache[attacker].g_iHumanAbility == 1)
				{
					float flHealth = (g_esVampireCache[attacker].g_iVampireHealth > 0) ? float(g_esVampireCache[attacker].g_iVampireHealth) : damage;
					flHealth *= g_esVampireCache[attacker].g_flVampireHealthMultiplier;
					int iDamage = RoundToNearest(flHealth),
						iHealth = GetEntProp(attacker, Prop_Data, "m_iHealth"),
						iMaxHealth = MT_TankMaxHealth(attacker, 1),
						iNewHealth = (iHealth + iDamage),
						iLeftover = (iNewHealth > MT_MAXHEALTH) ? (iDamage - MT_MAXHEALTH) : iNewHealth,
						iFinalHealth = iClamp(iNewHealth, 1, MT_MAXHEALTH),
						iTotalHealth = (iNewHealth > MT_MAXHEALTH) ? iLeftover : iDamage;
					MT_TankMaxHealth(attacker, 3, (iMaxHealth + iTotalHealth));
					SetEntProp(attacker, Prop_Data, "m_iHealth", iFinalHealth);
					vScreenEffect(victim, attacker, g_esVampireCache[attacker].g_iVampireEffect, MT_ATTACK_CLAW);

					if (g_esVampireCache[attacker].g_iVampireMessage == 1)
					{
						char sTankName[33];
						MT_GetTankName(attacker, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Vampire", sTankName, victim);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Vampire", LANG_SERVER, sTankName, victim);
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vVampirePluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_VAMPIRE);
}

#if defined MT_ABILITIES_MAIN2
void vVampireAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_VAMPIRE_SECTION);
	list2.PushString(MT_VAMPIRE_SECTION2);
	list3.PushString(MT_VAMPIRE_SECTION3);
	list4.PushString(MT_VAMPIRE_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vVampireConfigsLoad(int mode)
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
				g_esVampireAbility[iIndex].g_iAccessFlags = 0;
				g_esVampireAbility[iIndex].g_iImmunityFlags = 0;
				g_esVampireAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esVampireAbility[iIndex].g_iHumanAbility = 0;
				g_esVampireAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esVampireAbility[iIndex].g_iRequiresHumans = 0;
				g_esVampireAbility[iIndex].g_iVampireAbility = 0;
				g_esVampireAbility[iIndex].g_iVampireEffect = 0;
				g_esVampireAbility[iIndex].g_iVampireHealth = 0;
				g_esVampireAbility[iIndex].g_iVampireMessage = 0;
				g_esVampireAbility[iIndex].g_flVampireChance = 33.3;
				g_esVampireAbility[iIndex].g_flVampireHealthMultiplier = 1.0;

				g_esVampireSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esVampireSpecial[iIndex].g_iHumanAbility = -1;
				g_esVampireSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esVampireSpecial[iIndex].g_iRequiresHumans = -1;
				g_esVampireSpecial[iIndex].g_iVampireAbility = -1;
				g_esVampireSpecial[iIndex].g_iVampireEffect = -1;
				g_esVampireSpecial[iIndex].g_iVampireHealth = -1;
				g_esVampireSpecial[iIndex].g_iVampireMessage = -1;
				g_esVampireSpecial[iIndex].g_flVampireChance = -1.0;
				g_esVampireSpecial[iIndex].g_flVampireHealthMultiplier = -1.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esVampirePlayer[iPlayer].g_iAccessFlags = -1;
				g_esVampirePlayer[iPlayer].g_iImmunityFlags = -1;
				g_esVampirePlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esVampirePlayer[iPlayer].g_iHumanAbility = -1;
				g_esVampirePlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esVampirePlayer[iPlayer].g_iRequiresHumans = -1;
				g_esVampirePlayer[iPlayer].g_iVampireAbility = -1;
				g_esVampirePlayer[iPlayer].g_iVampireEffect = -1;
				g_esVampirePlayer[iPlayer].g_iVampireHealth = -1;
				g_esVampirePlayer[iPlayer].g_iVampireMessage = -1;
				g_esVampirePlayer[iPlayer].g_flVampireChance = -1.0;
				g_esVampirePlayer[iPlayer].g_flVampireHealthMultiplier = -1.0;

				g_esVampireTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esVampireTeammate[iPlayer].g_iHumanAbility = -1;
				g_esVampireTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esVampireTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esVampireTeammate[iPlayer].g_iVampireAbility = -1;
				g_esVampireTeammate[iPlayer].g_iVampireEffect = -1;
				g_esVampireTeammate[iPlayer].g_iVampireHealth = -1;
				g_esVampireTeammate[iPlayer].g_iVampireMessage = -1;
				g_esVampireTeammate[iPlayer].g_flVampireChance = -1.0;
				g_esVampireTeammate[iPlayer].g_flVampireHealthMultiplier = -1.0;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVampireConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esVampireTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esVampireTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVampireTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVampireTeammate[admin].g_iHumanAbility, value, -1, 1);
			g_esVampireTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVampireTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVampireTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVampireTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esVampireTeammate[admin].g_iVampireAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVampireTeammate[admin].g_iVampireAbility, value, -1, 1);
			g_esVampireTeammate[admin].g_iVampireEffect = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVampireTeammate[admin].g_iVampireEffect, value, -1, 1);
			g_esVampireTeammate[admin].g_iVampireHealth = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealth", "Vampire Health", "Vampire_Health", "health", g_esVampireTeammate[admin].g_iVampireHealth, value, -1, MT_MAXHEALTH);
			g_esVampireTeammate[admin].g_iVampireMessage = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVampireTeammate[admin].g_iVampireMessage, value, -1, 1);
			g_esVampireTeammate[admin].g_flVampireChance = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireChance", "Vampire Chance", "Vampire_Chance", "chance", g_esVampireTeammate[admin].g_flVampireChance, value, -1.0, 100.0);
			g_esVampireTeammate[admin].g_flVampireHealthMultiplier = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealthMultiplier", "Vampire Health Multiplier", "Vampire_Health_Multiplier", "hpmulti", g_esVampireTeammate[admin].g_flVampireHealthMultiplier, value, -1.0, 99999.0);
		}
		else
		{
			g_esVampirePlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esVampirePlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVampirePlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVampirePlayer[admin].g_iHumanAbility, value, -1, 1);
			g_esVampirePlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVampirePlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVampirePlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVampirePlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esVampirePlayer[admin].g_iVampireAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVampirePlayer[admin].g_iVampireAbility, value, -1, 1);
			g_esVampirePlayer[admin].g_iVampireEffect = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVampirePlayer[admin].g_iVampireEffect, value, -1, 1);
			g_esVampirePlayer[admin].g_iVampireHealth = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealth", "Vampire Health", "Vampire_Health", "health", g_esVampirePlayer[admin].g_iVampireHealth, value, -1, MT_MAXHEALTH);
			g_esVampirePlayer[admin].g_iVampireMessage = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVampirePlayer[admin].g_iVampireMessage, value, -1, 1);
			g_esVampirePlayer[admin].g_flVampireChance = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireChance", "Vampire Chance", "Vampire_Chance", "chance", g_esVampirePlayer[admin].g_flVampireChance, value, -1.0, 100.0);
			g_esVampirePlayer[admin].g_flVampireHealthMultiplier = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealthMultiplier", "Vampire Health Multiplier", "Vampire_Health_Multiplier", "hpmulti", g_esVampirePlayer[admin].g_flVampireHealthMultiplier, value, -1.0, 99999.0);
			g_esVampirePlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esVampirePlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esVampireSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esVampireSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVampireSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVampireSpecial[type].g_iHumanAbility, value, -1, 1);
			g_esVampireSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVampireSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVampireSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVampireSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esVampireSpecial[type].g_iVampireAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVampireSpecial[type].g_iVampireAbility, value, -1, 1);
			g_esVampireSpecial[type].g_iVampireEffect = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVampireSpecial[type].g_iVampireEffect, value, -1, 1);
			g_esVampireSpecial[type].g_iVampireHealth = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealth", "Vampire Health", "Vampire_Health", "health", g_esVampireSpecial[type].g_iVampireHealth, value, -1, MT_MAXHEALTH);
			g_esVampireSpecial[type].g_iVampireMessage = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVampireSpecial[type].g_iVampireMessage, value, -1, 1);
			g_esVampireSpecial[type].g_flVampireChance = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireChance", "Vampire Chance", "Vampire_Chance", "chance", g_esVampireSpecial[type].g_flVampireChance, value, -1.0, 100.0);
			g_esVampireSpecial[type].g_flVampireHealthMultiplier = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealthMultiplier", "Vampire Health Multiplier", "Vampire_Health_Multiplier", "hpmulti", g_esVampireSpecial[type].g_flVampireHealthMultiplier, value, -1.0, 99999.0);
		}
		else
		{
			g_esVampireAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esVampireAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esVampireAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esVampireAbility[type].g_iHumanAbility, value, -1, 1);
			g_esVampireAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esVampireAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esVampireAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esVampireAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esVampireAbility[type].g_iVampireAbility = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esVampireAbility[type].g_iVampireAbility, value, -1, 1);
			g_esVampireAbility[type].g_iVampireEffect = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esVampireAbility[type].g_iVampireEffect, value, -1, 1);
			g_esVampireAbility[type].g_iVampireHealth = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealth", "Vampire Health", "Vampire_Health", "health", g_esVampireAbility[type].g_iVampireHealth, value, -1, MT_MAXHEALTH);
			g_esVampireAbility[type].g_iVampireMessage = iGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esVampireAbility[type].g_iVampireMessage, value, -1, 1);
			g_esVampireAbility[type].g_flVampireChance = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireChance", "Vampire Chance", "Vampire_Chance", "chance", g_esVampireAbility[type].g_flVampireChance, value, -1.0, 100.0);
			g_esVampireAbility[type].g_flVampireHealthMultiplier = flGetKeyValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "VampireHealthMultiplier", "Vampire Health Multiplier", "Vampire_Health_Multiplier", "hpmulti", g_esVampireAbility[type].g_flVampireHealthMultiplier, value, -1.0, 99999.0);
			g_esVampireAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esVampireAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_VAMPIRE_SECTION, MT_VAMPIRE_SECTION2, MT_VAMPIRE_SECTION3, MT_VAMPIRE_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vVampireSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esVampirePlayer[tank].g_iTankType = apply ? type : 0;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esVampireCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_flCloseAreasOnly, g_esVampirePlayer[tank].g_flCloseAreasOnly, g_esVampireSpecial[type].g_flCloseAreasOnly, g_esVampireAbility[type].g_flCloseAreasOnly, 1);
		g_esVampireCache[tank].g_flVampireChance = flGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_flVampireChance, g_esVampirePlayer[tank].g_flVampireChance, g_esVampireSpecial[type].g_flVampireChance, g_esVampireAbility[type].g_flVampireChance, 1);
		g_esVampireCache[tank].g_flVampireHealthMultiplier = flGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_flVampireHealthMultiplier, g_esVampirePlayer[tank].g_flVampireHealthMultiplier, g_esVampireSpecial[type].g_flVampireHealthMultiplier, g_esVampireAbility[type].g_flVampireHealthMultiplier, 1);
		g_esVampireCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_iHumanAbility, g_esVampirePlayer[tank].g_iHumanAbility, g_esVampireSpecial[type].g_iHumanAbility, g_esVampireAbility[type].g_iHumanAbility, 1);
		g_esVampireCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_flOpenAreasOnly, g_esVampirePlayer[tank].g_flOpenAreasOnly, g_esVampireSpecial[type].g_flOpenAreasOnly, g_esVampireAbility[type].g_flOpenAreasOnly, 1);
		g_esVampireCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_iRequiresHumans, g_esVampirePlayer[tank].g_iRequiresHumans, g_esVampireSpecial[type].g_iRequiresHumans, g_esVampireAbility[type].g_iRequiresHumans, 1);
		g_esVampireCache[tank].g_iVampireAbility = iGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_iVampireAbility, g_esVampirePlayer[tank].g_iVampireAbility, g_esVampireSpecial[type].g_iVampireAbility, g_esVampireAbility[type].g_iVampireAbility, 1);
		g_esVampireCache[tank].g_iVampireEffect = iGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_iVampireEffect, g_esVampirePlayer[tank].g_iVampireEffect, g_esVampireSpecial[type].g_iVampireEffect, g_esVampireAbility[type].g_iVampireEffect, 1);
		g_esVampireCache[tank].g_iVampireHealth = iGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_iVampireHealth, g_esVampirePlayer[tank].g_iVampireHealth, g_esVampireSpecial[type].g_iVampireHealth, g_esVampireAbility[type].g_iVampireHealth, 1);
		g_esVampireCache[tank].g_iVampireMessage = iGetSubSettingValue(apply, bHuman, g_esVampireTeammate[tank].g_iVampireMessage, g_esVampirePlayer[tank].g_iVampireMessage, g_esVampireSpecial[type].g_iVampireMessage, g_esVampireAbility[type].g_iVampireMessage, 1);
	}
	else
	{
		g_esVampireCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_flCloseAreasOnly, g_esVampireAbility[type].g_flCloseAreasOnly, 1);
		g_esVampireCache[tank].g_flVampireChance = flGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_flVampireChance, g_esVampireAbility[type].g_flVampireChance, 1);
		g_esVampireCache[tank].g_flVampireHealthMultiplier = flGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_flVampireHealthMultiplier, g_esVampireAbility[type].g_flVampireHealthMultiplier, 1);
		g_esVampireCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_iHumanAbility, g_esVampireAbility[type].g_iHumanAbility, 1);
		g_esVampireCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_flOpenAreasOnly, g_esVampireAbility[type].g_flOpenAreasOnly, 1);
		g_esVampireCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_iRequiresHumans, g_esVampireAbility[type].g_iRequiresHumans, 1);
		g_esVampireCache[tank].g_iVampireAbility = iGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_iVampireAbility, g_esVampireAbility[type].g_iVampireAbility, 1);
		g_esVampireCache[tank].g_iVampireEffect = iGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_iVampireEffect, g_esVampireAbility[type].g_iVampireEffect, 1);
		g_esVampireCache[tank].g_iVampireHealth = iGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_iVampireHealth, g_esVampireAbility[type].g_iVampireHealth, 1);
		g_esVampireCache[tank].g_iVampireMessage = iGetSettingValue(apply, bHuman, g_esVampirePlayer[tank].g_iVampireMessage, g_esVampireAbility[type].g_iVampireMessage, 1);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif