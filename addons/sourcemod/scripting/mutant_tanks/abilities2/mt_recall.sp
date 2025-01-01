/**
 * Mutant Tanks: A L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2017-2025  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_RECALL_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN2
	#if MT_RECALL_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities2" while compiling "mt_abilities2.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Recall Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank time travels to annoy survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

int g_iGraphicsLevel;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Recall Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#else
	#if MT_RECALL_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_RECALL_SECTION "recallability"
#define MT_RECALL_SECTION2 "recall ability"
#define MT_RECALL_SECTION3 "recall_ability"
#define MT_RECALL_SECTION4 "recall"

#define MT_MENU_RECALL "Recall Ability"

enum struct esRecallPlayer
{
	ArrayList g_alHealthVals;
	ArrayList g_alPrevLocations;

	bool g_bAffected;
	bool g_bBlockFall;

	float g_flCloseAreasOnly;
	float g_flLastRecall[2];
	float g_flOpenAreasOnly;
	float g_flRecallBlinkChance;
	float g_flRecallBlinkRange;
	float g_flRecallRewindChance;
	float g_flRecallRewindThreshold;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iInfectedType;
	int g_iOwner;
	int g_iRecallAbility;
	int g_iRecallBlinkCooldown;
	int g_iRecallBlinkCount;
	int g_iRecallMessage;
	int g_iRecallRewindCleanse;
	int g_iRecallRewindCooldown;
	int g_iRecallRewindLifetime;
	int g_iRecallRewindMode;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esRecallPlayer g_esRecallPlayer[MAXPLAYERS + 1];

enum struct esRecallTeammate
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRecallBlinkChance;
	float g_flRecallBlinkRange;
	float g_flRecallRewindChance;
	float g_flRecallRewindThreshold;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRecallAbility;
	int g_iRecallBlinkCooldown;
	int g_iRecallBlinkCount;
	int g_iRecallMessage;
	int g_iRecallRewindCleanse;
	int g_iRecallRewindCooldown;
	int g_iRecallRewindLifetime;
	int g_iRecallRewindMode;
	int g_iRequiresHumans;
}

esRecallTeammate g_esRecallTeammate[MAXPLAYERS + 1];

enum struct esRecallAbility
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRecallBlinkChance;
	float g_flRecallBlinkRange;
	float g_flRecallRewindChance;
	float g_flRecallRewindThreshold;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRecallAbility;
	int g_iRecallBlinkCooldown;
	int g_iRecallBlinkCount;
	int g_iRecallMessage;
	int g_iRecallRewindCleanse;
	int g_iRecallRewindCooldown;
	int g_iRecallRewindLifetime;
	int g_iRecallRewindMode;
	int g_iRequiresHumans;
}

esRecallAbility g_esRecallAbility[MT_MAXTYPES + 1];

enum struct esRecallSpecial
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRecallBlinkChance;
	float g_flRecallBlinkRange;
	float g_flRecallRewindChance;
	float g_flRecallRewindThreshold;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRecallAbility;
	int g_iRecallBlinkCooldown;
	int g_iRecallBlinkCount;
	int g_iRecallMessage;
	int g_iRecallRewindCleanse;
	int g_iRecallRewindCooldown;
	int g_iRecallRewindLifetime;
	int g_iRecallRewindMode;
	int g_iRequiresHumans;
}

esRecallSpecial g_esRecallSpecial[MT_MAXTYPES + 1];

enum struct esRecallCache
{
	float g_flCloseAreasOnly;
	float g_flOpenAreasOnly;
	float g_flRecallBlinkChance;
	float g_flRecallBlinkRange;
	float g_flRecallRewindChance;
	float g_flRecallRewindThreshold;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRecallAbility;
	int g_iRecallBlinkCooldown;
	int g_iRecallBlinkCount;
	int g_iRecallMessage;
	int g_iRecallRewindCleanse;
	int g_iRecallRewindCooldown;
	int g_iRecallRewindLifetime;
	int g_iRecallRewindMode;
	int g_iRequiresHumans;
}

esRecallCache g_esRecallCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN2
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_recall", cmdRecallInfo, "View information about the Recall ability.");

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
void vRecallMapStart()
#else
public void OnMapStart()
#endif
{
	vRecallReset();
}

#if defined MT_ABILITIES_MAIN2
void vRecallClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnRecallTakeDamage);
	vRemoveRecall(client);
}

#if defined MT_ABILITIES_MAIN2
void vRecallClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveRecall(client);
}

#if defined MT_ABILITIES_MAIN2
void vRecallMapEnd()
#else
public void OnMapEnd()
#endif
{
	vRecallReset();
}

#if !defined MT_ABILITIES_MAIN2
Action cmdRecallInfo(int client, int args)
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
		case false: vRecallMenu(client, MT_RECALL_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vRecallMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_RECALL_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iRecallMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Recall Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iRecallMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRecallCache[param1].g_iRecallAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esRecallCache[param1].g_iHumanAmmo - g_esRecallPlayer[param1].g_iAmmoCount), g_esRecallCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", (g_esRecallCache[param1].g_iHumanAmmo - g_esRecallPlayer[param1].g_iAmmoCount2), g_esRecallCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esRecallCache[param1].g_iHumanAbility == 1) ? g_esRecallCache[param1].g_iHumanCooldown : g_esRecallCache[param1].g_iRecallBlinkCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RecallDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esRecallCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esRecallCache[param1].g_iHumanAbility == 1) ? g_esRecallCache[param1].g_iHumanRangeCooldown : g_esRecallCache[param1].g_iRecallRewindCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vRecallMenu(param1, MT_RECALL_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pRecall = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "RecallMenu", param1);
			pRecall.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Cooldown", param1);
					case 4: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Details", param1);
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RangeCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN2
void vRecallDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_RECALL, MT_MENU_RECALL);
}

#if defined MT_ABILITIES_MAIN2
void vRecallMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_RECALL, false))
	{
		vRecallMenu(client, MT_RECALL_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_RECALL, false))
	{
		FormatEx(buffer, size, "%T", "RecallMenu2", client);
	}
}



#if defined MT_ABILITIES_MAIN2
void vRecallPlayerRunCmd(int client, int &buttons)
#else
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
#endif
{
	if (!bIsValidClient(client))
	{
#if defined MT_ABILITIES_MAIN2
		return;
#else
		return Plugin_Continue;
#endif
	}

	if (bIsHumanSurvivor(client) && MT_DoesSurvivorHaveRewardType(client, MT_REWARD_DEVELOPER4) && (buttons & IN_JUMP))
	{
		if (g_esRecallPlayer[client].g_alHealthVals == null || g_esRecallPlayer[client].g_alPrevLocations == null)
		{
			vResetRecallTimers(client);
		}

		float flCurrentTime = GetGameTime();
		if (buttons & IN_ATTACK2)
		{
			if (g_esRecallPlayer[client].g_flLastRecall[0] < (flCurrentTime + 5.0))
			{
				float flEyeAngles[3], flOrigin[3], flDirection[3], flTemp[3];
				vRecallBlink(client, buttons, flOrigin, flEyeAngles, flDirection, flTemp);

				int iSpecial = iGetSurvivorAttacker(client);
				if (bIsInfected(iSpecial))
				{
					MT_TeleportPlayerAhead(iSpecial, flOrigin, flEyeAngles, NULL_VECTOR, flDirection, 150.0);
				}

				g_esRecallPlayer[client].g_bBlockFall = true;
				g_esRecallPlayer[client].g_flLastRecall[0] = flCurrentTime + 5.0;

				MT_TeleportPlayerAhead(client, flOrigin, flEyeAngles, NULL_VECTOR, flDirection, 150.0);
				vForceVocalize(client, "PlayerLaugh");

				if (g_iGraphicsLevel > 2)
				{
					vAttachParticle(client, PARTICLE_ELECTRICITY, 0.75, 30.0);
				}
			}
		}
		else if (buttons & IN_RELOAD)
		{
			if (g_esRecallPlayer[client].g_flLastRecall[1] < (flCurrentTime + 5.0))
			{
				vRecallRewind(client, 1.0, 30, 0, 1, true);
			}
		}
#if defined MT_ABILITIES_MAIN2
		return;
#else
		return Plugin_Continue;
#endif
	}

	if (!MT_IsTankSupported(client) || g_esRecallPlayer[client].g_iCooldown == -1)
	{
#if defined MT_ABILITIES_MAIN2
		return;
#else
		return Plugin_Continue;
#endif
	}

	int iTime = GetTime();
	if (g_esRecallPlayer[client].g_iCooldown <= iTime)
	{
		g_esRecallPlayer[client].g_iCount = 0;

		if (g_esRecallCache[client].g_iRecallMessage & MT_MESSAGE_RANGE)
		{
			char sTankName[64];
			MT_GetTankName(client, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Recall3", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Recall3", LANG_SERVER, sTankName);
		}
	}
#if !defined MT_ABILITIES_MAIN2
	return Plugin_Continue;
#endif
}

Action OnRecallTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsHumanSurvivor(victim) && (damagetype & DMG_FALL) && g_esRecallPlayer[victim].g_bBlockFall && damage > 0.0)
	{
		g_esRecallPlayer[victim].g_bBlockFall = false;

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN2
void vRecallPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_RECALL);
}

#if defined MT_ABILITIES_MAIN2
void vRecallAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_RECALL_SECTION);
	list2.PushString(MT_RECALL_SECTION2);
	list3.PushString(MT_RECALL_SECTION3);
	list4.PushString(MT_RECALL_SECTION4);
}

#if defined MT_ABILITIES_MAIN2
void vRecallConfigsLoad(int mode)
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
				g_esRecallAbility[iIndex].g_iAccessFlags = 0;
				g_esRecallAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esRecallAbility[iIndex].g_iHumanAbility = 0;
				g_esRecallAbility[iIndex].g_iHumanAmmo = 5;
				g_esRecallAbility[iIndex].g_iHumanCooldown = 0;
				g_esRecallAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esRecallAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esRecallAbility[iIndex].g_iRequiresHumans = 0;
				g_esRecallAbility[iIndex].g_iRecallAbility = 0;
				g_esRecallAbility[iIndex].g_flRecallBlinkChance = 50.0;
				g_esRecallAbility[iIndex].g_iRecallBlinkCooldown = 0;
				g_esRecallAbility[iIndex].g_iRecallBlinkCount = 5;
				g_esRecallAbility[iIndex].g_flRecallBlinkRange = 150.0;
				g_esRecallAbility[iIndex].g_iRecallMessage = 0;
				g_esRecallAbility[iIndex].g_flRecallRewindChance = 100.0;
				g_esRecallAbility[iIndex].g_iRecallRewindCleanse = 1;
				g_esRecallAbility[iIndex].g_iRecallRewindCooldown = 0;
				g_esRecallAbility[iIndex].g_iRecallRewindLifetime = 30;
				g_esRecallAbility[iIndex].g_iRecallRewindMode = 0;
				g_esRecallAbility[iIndex].g_flRecallRewindThreshold = 0.5;

				g_esRecallSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esRecallSpecial[iIndex].g_iHumanAbility = -1;
				g_esRecallSpecial[iIndex].g_iHumanAmmo = -1;
				g_esRecallSpecial[iIndex].g_iHumanCooldown = -1;
				g_esRecallSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esRecallSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esRecallSpecial[iIndex].g_iRequiresHumans = -1;
				g_esRecallSpecial[iIndex].g_iRecallAbility = -1;
				g_esRecallSpecial[iIndex].g_flRecallBlinkChance = -1.0;
				g_esRecallSpecial[iIndex].g_iRecallBlinkCooldown = -1;
				g_esRecallSpecial[iIndex].g_iRecallBlinkCount = -1;
				g_esRecallSpecial[iIndex].g_flRecallBlinkRange = -1.0;
				g_esRecallSpecial[iIndex].g_iRecallMessage = -1;
				g_esRecallSpecial[iIndex].g_flRecallRewindChance = -1.0;
				g_esRecallSpecial[iIndex].g_iRecallRewindCleanse = -1;
				g_esRecallSpecial[iIndex].g_iRecallRewindCooldown = -1;
				g_esRecallSpecial[iIndex].g_iRecallRewindLifetime = -1;
				g_esRecallSpecial[iIndex].g_iRecallRewindMode = -1;
				g_esRecallSpecial[iIndex].g_flRecallRewindThreshold = -1.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esRecallPlayer[iPlayer].g_iAccessFlags = -1;
				g_esRecallPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRecallPlayer[iPlayer].g_iHumanAbility = -1;
				g_esRecallPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esRecallPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esRecallPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esRecallPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRecallPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esRecallPlayer[iPlayer].g_iRecallAbility = -1;
				g_esRecallPlayer[iPlayer].g_flRecallBlinkChance = -1.0;
				g_esRecallPlayer[iPlayer].g_iRecallBlinkCooldown = -1;
				g_esRecallPlayer[iPlayer].g_iRecallBlinkCount = -1;
				g_esRecallPlayer[iPlayer].g_flRecallBlinkRange = -1.0;
				g_esRecallPlayer[iPlayer].g_iRecallMessage = -1;
				g_esRecallPlayer[iPlayer].g_flRecallRewindChance = -1.0;
				g_esRecallPlayer[iPlayer].g_iRecallRewindCleanse = -1;
				g_esRecallPlayer[iPlayer].g_iRecallRewindCooldown = -1;
				g_esRecallPlayer[iPlayer].g_iRecallRewindLifetime = -1;
				g_esRecallPlayer[iPlayer].g_iRecallRewindMode = -1;
				g_esRecallPlayer[iPlayer].g_flRecallRewindThreshold = -1.0;

				g_esRecallTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esRecallTeammate[iPlayer].g_iHumanAbility = -1;
				g_esRecallTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esRecallTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esRecallTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esRecallTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esRecallTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esRecallTeammate[iPlayer].g_iRecallAbility = -1;
				g_esRecallTeammate[iPlayer].g_flRecallBlinkChance = -1.0;
				g_esRecallTeammate[iPlayer].g_iRecallBlinkCooldown = -1;
				g_esRecallTeammate[iPlayer].g_iRecallBlinkCount = -1;
				g_esRecallTeammate[iPlayer].g_flRecallBlinkRange = -1.0;
				g_esRecallTeammate[iPlayer].g_iRecallMessage = -1;
				g_esRecallTeammate[iPlayer].g_flRecallRewindChance = -1.0;
				g_esRecallTeammate[iPlayer].g_iRecallRewindCleanse = -1;
				g_esRecallTeammate[iPlayer].g_iRecallRewindCooldown = -1;
				g_esRecallTeammate[iPlayer].g_iRecallRewindLifetime = -1;
				g_esRecallTeammate[iPlayer].g_iRecallRewindMode = -1;
				g_esRecallTeammate[iPlayer].g_flRecallRewindThreshold = -1.0;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esRecallTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRecallTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRecallTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRecallTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esRecallTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRecallTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRecallTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRecallTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRecallTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRecallTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRecallTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRecallTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRecallTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRecallTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esRecallTeammate[admin].g_iRecallAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRecallTeammate[admin].g_iRecallAbility, value, -1, 3);
			g_esRecallTeammate[admin].g_flRecallBlinkChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkChance", "Recall Blink Chance", "Recall_Blink_Chance", "blinkchance", g_esRecallTeammate[admin].g_flRecallBlinkChance, value, -1.0, 100.0);
			g_esRecallTeammate[admin].g_iRecallBlinkCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCooldown", "Recall Blink Cooldown", "Recall_Blink_Cooldown", "blinkcooldown", g_esRecallTeammate[admin].g_iRecallBlinkCooldown, value, -1, 99999);
			g_esRecallTeammate[admin].g_iRecallBlinkCount = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCount", "Recall Blink Count", "Recall_Blink_Count", "blinkcount", g_esRecallTeammate[admin].g_iRecallBlinkCount, value, -1, 99999);
			g_esRecallTeammate[admin].g_flRecallBlinkRange = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkRange", "Recall Blink Range", "Recall_Blink_Range", "blinkrange", g_esRecallTeammate[admin].g_flRecallBlinkRange, value, -1.0, 99999.0);
			g_esRecallTeammate[admin].g_iRecallMessage = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRecallTeammate[admin].g_iRecallMessage, value, -1, 1);
			g_esRecallTeammate[admin].g_flRecallRewindChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindChance", "Recall Rewind Chance", "Recall_Rewind_Chance", "rewindchance", g_esRecallTeammate[admin].g_flRecallRewindChance, value, -1.0, 100.0);
			g_esRecallTeammate[admin].g_iRecallRewindCleanse = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCleanse", "Recall Rewind Cleanse", "Recall_Rewind_Cleanse", "rewindcleanse", g_esRecallTeammate[admin].g_iRecallRewindCleanse, value, -1, 1);
			g_esRecallTeammate[admin].g_iRecallRewindCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCooldown", "Recall Rewind Cooldown", "Recall_Rewind_Cooldown", "rewindcooldown", g_esRecallTeammate[admin].g_iRecallRewindCooldown, value, -1, 99999);
			g_esRecallTeammate[admin].g_iRecallRewindLifetime = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindLifetime", "Recall Rewind Lifetime", "Recall_Rewind_Lifetime", "rewindlifetime", g_esRecallTeammate[admin].g_iRecallRewindLifetime, value, -1, 30);
			g_esRecallTeammate[admin].g_iRecallRewindMode = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindMode", "Recall Rewind Mode", "Recall_Rewind_Mode", "rewindmode", g_esRecallTeammate[admin].g_iRecallRewindMode, value, -1, 2);
			g_esRecallTeammate[admin].g_flRecallRewindThreshold = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindThreshold", "Recall Rewind Threshold", "Recall_Rewind_Threshold", "rewindthreshold", g_esRecallTeammate[admin].g_flRecallRewindThreshold, value, -1.0, 1.0);
		}
		else
		{
			g_esRecallPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRecallPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRecallPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRecallPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esRecallPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRecallPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esRecallPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRecallPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esRecallPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRecallPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRecallPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRecallPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRecallPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRecallPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esRecallPlayer[admin].g_iRecallAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRecallPlayer[admin].g_iRecallAbility, value, -1, 3);
			g_esRecallPlayer[admin].g_flRecallBlinkChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkChance", "Recall Blink Chance", "Recall_Blink_Chance", "blinkchance", g_esRecallPlayer[admin].g_flRecallBlinkChance, value, -1.0, 100.0);
			g_esRecallPlayer[admin].g_iRecallBlinkCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCooldown", "Recall Blink Cooldown", "Recall_Blink_Cooldown", "blinkcooldown", g_esRecallPlayer[admin].g_iRecallBlinkCooldown, value, -1, 99999);
			g_esRecallPlayer[admin].g_iRecallBlinkCount = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCount", "Recall Blink Count", "Recall_Blink_Count", "blinkcount", g_esRecallPlayer[admin].g_iRecallBlinkCount, value, -1, 99999);
			g_esRecallPlayer[admin].g_flRecallBlinkRange = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkRange", "Recall Blink Range", "Recall_Blink_Range", "blinkrange", g_esRecallPlayer[admin].g_flRecallBlinkRange, value, -1.0, 99999.0);
			g_esRecallPlayer[admin].g_iRecallMessage = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRecallPlayer[admin].g_iRecallMessage, value, -1, 1);
			g_esRecallPlayer[admin].g_flRecallRewindChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindChance", "Recall Rewind Chance", "Recall_Rewind_Chance", "rewindchance", g_esRecallPlayer[admin].g_flRecallRewindChance, value, -1.0, 100.0);
			g_esRecallPlayer[admin].g_iRecallRewindCleanse = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCleanse", "Recall Rewind Cleanse", "Recall_Rewind_Cleanse", "rewindcleanse", g_esRecallPlayer[admin].g_iRecallRewindCleanse, value, -1, 1);
			g_esRecallPlayer[admin].g_iRecallRewindCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCooldown", "Recall Rewind Cooldown", "Recall_Rewind_Cooldown", "rewindcooldown", g_esRecallPlayer[admin].g_iRecallRewindCooldown, value, -1, 99999);
			g_esRecallPlayer[admin].g_iRecallRewindLifetime = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindLifetime", "Recall Rewind Lifetime", "Recall_Rewind_Lifetime", "rewindlifetime", g_esRecallPlayer[admin].g_iRecallRewindLifetime, value, -1, 30);
			g_esRecallPlayer[admin].g_iRecallRewindMode = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindMode", "Recall Rewind Mode", "Recall_Rewind_Mode", "rewindmode", g_esRecallPlayer[admin].g_iRecallRewindMode, value, -1, 2);
			g_esRecallPlayer[admin].g_flRecallRewindThreshold = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindThreshold", "Recall Rewind Threshold", "Recall_Rewind_Threshold", "rewindthreshold", g_esRecallPlayer[admin].g_flRecallRewindThreshold, value, -1.0, 1.0);
			g_esRecallPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esRecallSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRecallSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRecallSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRecallSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esRecallSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRecallSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esRecallSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRecallSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esRecallSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRecallSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRecallSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRecallSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRecallSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRecallSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esRecallSpecial[type].g_iRecallAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRecallSpecial[type].g_iRecallAbility, value, -1, 3);
			g_esRecallSpecial[type].g_flRecallBlinkChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkChance", "Recall Blink Chance", "Recall_Blink_Chance", "blinkchance", g_esRecallSpecial[type].g_flRecallBlinkChance, value, -1.0, 100.0);
			g_esRecallSpecial[type].g_iRecallBlinkCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCooldown", "Recall Blink Cooldown", "Recall_Blink_Cooldown", "blinkcooldown", g_esRecallSpecial[type].g_iRecallBlinkCooldown, value, -1, 99999);
			g_esRecallSpecial[type].g_iRecallBlinkCount = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCount", "Recall Blink Count", "Recall_Blink_Count", "blinkcount", g_esRecallSpecial[type].g_iRecallBlinkCount, value, -1, 99999);
			g_esRecallSpecial[type].g_flRecallBlinkRange = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkRange", "Recall Blink Range", "Recall_Blink_Range", "blinkrange", g_esRecallSpecial[type].g_flRecallBlinkRange, value, -1.0, 99999.0);
			g_esRecallSpecial[type].g_iRecallMessage = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRecallSpecial[type].g_iRecallMessage, value, -1, 1);
			g_esRecallSpecial[type].g_flRecallRewindChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindChance", "Recall Rewind Chance", "Recall_Rewind_Chance", "rewindchance", g_esRecallSpecial[type].g_flRecallRewindChance, value, -1.0, 100.0);
			g_esRecallSpecial[type].g_iRecallRewindCleanse = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCleanse", "Recall Rewind Cleanse", "Recall_Rewind_Cleanse", "rewindcleanse", g_esRecallSpecial[type].g_iRecallRewindCleanse, value, -1, 1);
			g_esRecallSpecial[type].g_iRecallRewindCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCooldown", "Recall Rewind Cooldown", "Recall_Rewind_Cooldown", "rewindcooldown", g_esRecallSpecial[type].g_iRecallRewindCooldown, value, -1, 99999);
			g_esRecallSpecial[type].g_iRecallRewindLifetime = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindLifetime", "Recall Rewind Lifetime", "Recall_Rewind_Lifetime", "rewindlifetime", g_esRecallSpecial[type].g_iRecallRewindLifetime, value, -1, 30);
			g_esRecallSpecial[type].g_iRecallRewindMode = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindMode", "Recall Rewind Mode", "Recall_Rewind_Mode", "rewindmode", g_esRecallSpecial[type].g_iRecallRewindMode, value, -1, 2);
			g_esRecallSpecial[type].g_flRecallRewindThreshold = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindThreshold", "Recall Rewind Threshold", "Recall_Rewind_Threshold", "rewindthreshold", g_esRecallSpecial[type].g_flRecallRewindThreshold, value, -1.0, 1.0);
		}
		else
		{
			g_esRecallAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esRecallAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esRecallAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esRecallAbility[type].g_iHumanAbility, value, -1, 2);
			g_esRecallAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esRecallAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esRecallAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esRecallAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esRecallAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esRecallAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esRecallAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esRecallAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esRecallAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esRecallAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esRecallAbility[type].g_iRecallAbility = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esRecallAbility[type].g_iRecallAbility, value, -1, 3);
			g_esRecallAbility[type].g_flRecallBlinkChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkChance", "Recall Blink Chance", "Recall_Blink_Chance", "blinkchance", g_esRecallAbility[type].g_flRecallBlinkChance, value, -1.0, 100.0);
			g_esRecallAbility[type].g_iRecallBlinkCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCooldown", "Recall Blink Cooldown", "Recall_Blink_Cooldown", "blinkcooldown", g_esRecallAbility[type].g_iRecallBlinkCooldown, value, -1, 99999);
			g_esRecallAbility[type].g_iRecallBlinkCount = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkCount", "Recall Blink Count", "Recall_Blink_Count", "blinkcount", g_esRecallAbility[type].g_iRecallBlinkCount, value, -1, 99999);
			g_esRecallAbility[type].g_flRecallBlinkRange = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallBlinkRange", "Recall Blink Range", "Recall_Blink_Range", "blinkrange", g_esRecallAbility[type].g_flRecallBlinkRange, value, -1.0, 99999.0);
			g_esRecallAbility[type].g_iRecallMessage = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esRecallAbility[type].g_iRecallMessage, value, -1, 1);
			g_esRecallAbility[type].g_flRecallRewindChance = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindChance", "Recall Rewind Chance", "Recall_Rewind_Chance", "rewindchance", g_esRecallAbility[type].g_flRecallRewindChance, value, -1.0, 100.0);
			g_esRecallAbility[type].g_iRecallRewindCleanse = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCleanse", "Recall Rewind Cleanse", "Recall_Rewind_Cleanse", "rewindcleanse", g_esRecallAbility[type].g_iRecallRewindCleanse, value, -1, 1);
			g_esRecallAbility[type].g_iRecallRewindCooldown = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindCooldown", "Recall Rewind Cooldown", "Recall_Rewind_Cooldown", "rewindcooldown", g_esRecallAbility[type].g_iRecallRewindCooldown, value, -1, 99999);
			g_esRecallAbility[type].g_iRecallRewindLifetime = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindLifetime", "Recall Rewind Lifetime", "Recall_Rewind_Lifetime", "rewindlifetime", g_esRecallAbility[type].g_iRecallRewindLifetime, value, -1, 30);
			g_esRecallAbility[type].g_iRecallRewindMode = iGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindMode", "Recall Rewind Mode", "Recall_Rewind_Mode", "rewindmode", g_esRecallAbility[type].g_iRecallRewindMode, value, -1, 2);
			g_esRecallAbility[type].g_flRecallRewindThreshold = flGetKeyValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "RecallRewindThreshold", "Recall Rewind Threshold", "Recall_Rewind_Threshold", "rewindthreshold", g_esRecallAbility[type].g_flRecallRewindThreshold, value, -1.0, 1.0);
			g_esRecallAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_RECALL_SECTION, MT_RECALL_SECTION2, MT_RECALL_SECTION3, MT_RECALL_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esRecallPlayer[tank].g_iInfectedType = iGetInfectedType(tank);
	g_esRecallPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esRecallPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esRecallPlayer[tank].g_iTankTypeRecorded;
#if !defined MT_ABILITIES_MAIN2
	g_iGraphicsLevel = MT_GetGraphicsLevel();
#endif
	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esRecallCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_flCloseAreasOnly, g_esRecallPlayer[tank].g_flCloseAreasOnly, g_esRecallSpecial[iType].g_flCloseAreasOnly, g_esRecallAbility[iType].g_flCloseAreasOnly, 1);
		g_esRecallCache[tank].g_flRecallBlinkChance = flGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_flRecallBlinkChance, g_esRecallPlayer[tank].g_flRecallBlinkChance, g_esRecallSpecial[iType].g_flRecallBlinkChance, g_esRecallAbility[iType].g_flRecallBlinkChance, 1);
		g_esRecallCache[tank].g_flRecallBlinkRange = flGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_flRecallBlinkRange, g_esRecallPlayer[tank].g_flRecallBlinkRange, g_esRecallSpecial[iType].g_flRecallBlinkRange, g_esRecallAbility[iType].g_flRecallBlinkRange, 1);
		g_esRecallCache[tank].g_flRecallRewindChance = flGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_flRecallRewindChance, g_esRecallPlayer[tank].g_flRecallRewindChance, g_esRecallSpecial[iType].g_flRecallRewindChance, g_esRecallAbility[iType].g_flRecallRewindChance, 1);
		g_esRecallCache[tank].g_flRecallRewindThreshold = flGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_flRecallRewindThreshold, g_esRecallPlayer[tank].g_flRecallRewindThreshold, g_esRecallSpecial[iType].g_flRecallRewindThreshold, g_esRecallAbility[iType].g_flRecallRewindThreshold, 1);
		g_esRecallCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iHumanAbility, g_esRecallPlayer[tank].g_iHumanAbility, g_esRecallSpecial[iType].g_iHumanAbility, g_esRecallAbility[iType].g_iHumanAbility, 1);
		g_esRecallCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iHumanAmmo, g_esRecallPlayer[tank].g_iHumanAmmo, g_esRecallSpecial[iType].g_iHumanAmmo, g_esRecallAbility[iType].g_iHumanAmmo, 1);
		g_esRecallCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iHumanCooldown, g_esRecallPlayer[tank].g_iHumanCooldown, g_esRecallSpecial[iType].g_iHumanCooldown, g_esRecallAbility[iType].g_iHumanCooldown, 1);
		g_esRecallCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iHumanRangeCooldown, g_esRecallPlayer[tank].g_iHumanRangeCooldown, g_esRecallSpecial[iType].g_iHumanRangeCooldown, g_esRecallAbility[iType].g_iHumanRangeCooldown, 1);
		g_esRecallCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_flOpenAreasOnly, g_esRecallPlayer[tank].g_flOpenAreasOnly, g_esRecallSpecial[iType].g_flOpenAreasOnly, g_esRecallAbility[iType].g_flOpenAreasOnly, 1);
		g_esRecallCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRequiresHumans, g_esRecallPlayer[tank].g_iRequiresHumans, g_esRecallSpecial[iType].g_iRequiresHumans, g_esRecallAbility[iType].g_iRequiresHumans, 1);
		g_esRecallCache[tank].g_iRecallAbility = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallAbility, g_esRecallPlayer[tank].g_iRecallAbility, g_esRecallSpecial[iType].g_iRecallAbility, g_esRecallAbility[iType].g_iRecallAbility, 1);
		g_esRecallCache[tank].g_iRecallBlinkCooldown = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallBlinkCooldown, g_esRecallPlayer[tank].g_iRecallBlinkCooldown, g_esRecallSpecial[iType].g_iRecallBlinkCooldown, g_esRecallAbility[iType].g_iRecallBlinkCooldown, 1);
		g_esRecallCache[tank].g_iRecallBlinkCount = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallBlinkCount, g_esRecallPlayer[tank].g_iRecallBlinkCount, g_esRecallSpecial[iType].g_iRecallBlinkCount, g_esRecallAbility[iType].g_iRecallBlinkCount, 1);
		g_esRecallCache[tank].g_iRecallRewindCleanse = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallRewindCleanse, g_esRecallPlayer[tank].g_iRecallRewindCleanse, g_esRecallSpecial[iType].g_iRecallRewindCleanse, g_esRecallAbility[iType].g_iRecallRewindCleanse, 1);
		g_esRecallCache[tank].g_iRecallRewindCooldown = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallRewindCooldown, g_esRecallPlayer[tank].g_iRecallRewindCooldown, g_esRecallSpecial[iType].g_iRecallRewindCooldown, g_esRecallAbility[iType].g_iRecallRewindCooldown, 1);
		g_esRecallCache[tank].g_iRecallRewindLifetime = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallRewindLifetime, g_esRecallPlayer[tank].g_iRecallRewindLifetime, g_esRecallSpecial[iType].g_iRecallRewindLifetime, g_esRecallAbility[iType].g_iRecallRewindLifetime, 1);
		g_esRecallCache[tank].g_iRecallRewindMode = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallRewindMode, g_esRecallPlayer[tank].g_iRecallRewindMode, g_esRecallSpecial[iType].g_iRecallRewindMode, g_esRecallAbility[iType].g_iRecallRewindMode, 1);
		g_esRecallCache[tank].g_iRecallMessage = iGetSubSettingValue(apply, bHuman, g_esRecallTeammate[tank].g_iRecallMessage, g_esRecallPlayer[tank].g_iRecallMessage, g_esRecallSpecial[iType].g_iRecallMessage, g_esRecallAbility[iType].g_iRecallMessage, 1);
	}
	else
	{
		g_esRecallCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_flCloseAreasOnly, g_esRecallAbility[iType].g_flCloseAreasOnly, 1);
		g_esRecallCache[tank].g_flRecallBlinkChance = flGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_flRecallBlinkChance, g_esRecallAbility[iType].g_flRecallBlinkChance, 1);
		g_esRecallCache[tank].g_flRecallBlinkRange = flGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_flRecallBlinkRange, g_esRecallAbility[iType].g_flRecallBlinkRange, 1);
		g_esRecallCache[tank].g_flRecallRewindChance = flGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_flRecallRewindChance, g_esRecallAbility[iType].g_flRecallRewindChance, 1);
		g_esRecallCache[tank].g_flRecallRewindThreshold = flGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_flRecallRewindThreshold, g_esRecallAbility[iType].g_flRecallRewindThreshold, 1);
		g_esRecallCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iHumanAbility, g_esRecallAbility[iType].g_iHumanAbility, 1);
		g_esRecallCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iHumanAmmo, g_esRecallAbility[iType].g_iHumanAmmo, 1);
		g_esRecallCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iHumanCooldown, g_esRecallAbility[iType].g_iHumanCooldown, 1);
		g_esRecallCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iHumanRangeCooldown, g_esRecallAbility[iType].g_iHumanRangeCooldown, 1);
		g_esRecallCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_flOpenAreasOnly, g_esRecallAbility[iType].g_flOpenAreasOnly, 1);
		g_esRecallCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRequiresHumans, g_esRecallAbility[iType].g_iRequiresHumans, 1);
		g_esRecallCache[tank].g_iRecallAbility = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallAbility, g_esRecallAbility[iType].g_iRecallAbility, 1);
		g_esRecallCache[tank].g_iRecallBlinkCooldown = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallBlinkCooldown, g_esRecallAbility[iType].g_iRecallBlinkCooldown, 1);
		g_esRecallCache[tank].g_iRecallBlinkCount = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallBlinkCount, g_esRecallAbility[iType].g_iRecallBlinkCount, 1);
		g_esRecallCache[tank].g_iRecallRewindCleanse = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallRewindCleanse, g_esRecallAbility[iType].g_iRecallRewindCleanse, 1);
		g_esRecallCache[tank].g_iRecallRewindCooldown = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallRewindCooldown, g_esRecallAbility[iType].g_iRecallRewindCooldown, 1);
		g_esRecallCache[tank].g_iRecallRewindLifetime = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallRewindLifetime, g_esRecallAbility[iType].g_iRecallRewindLifetime, 1);
		g_esRecallCache[tank].g_iRecallRewindMode = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallRewindMode, g_esRecallAbility[iType].g_iRecallRewindMode, 1);
		g_esRecallCache[tank].g_iRecallMessage = iGetSettingValue(apply, bHuman, g_esRecallPlayer[tank].g_iRecallMessage, g_esRecallAbility[iType].g_iRecallMessage, 1);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vRecallCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveRecall(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN2
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN2
void vRecallEventFired(Event event, const char[] name)
#else
public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
#endif
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iPlayerId = event.GetInt("player"), iPlayer = GetClientOfUserId(iPlayerId);
		if (bIsValidClient(iBot))
		{
			if (bIsInfected(iPlayer))
			{
				vRecallCopyStats2(iBot, iPlayer);
				vRemoveRecall(iBot);
			}
			else if (bIsSurvivor(iPlayer))
			{
				vResetRecallTimers(iBot, false);
				vResetRecallTimers(iPlayer, MT_DoesSurvivorHaveRewardType(iPlayer, MT_REWARD_DEVELOPER4));
			}
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vRecallReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iPlayerId = event.GetInt("player"), iPlayer = GetClientOfUserId(iPlayerId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iPlayer))
		{
			if (bIsInfected(iBot))
			{
				vRecallCopyStats2(iPlayer, iBot);
				vRemoveRecall(iPlayer);
			}
			else if (bIsSurvivor(iBot))
			{
				vResetRecallTimers(iPlayer, false);
				vResetRecallTimers(iBot, MT_DoesSurvivorHaveRewardType(iBot, MT_REWARD_DEVELOPER4));
			}
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveRecall(iPlayer);
		}
		else if (bIsSurvivor(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vResetRecallTimers(iPlayer, (StrContains(name, "spawn") != -1 && MT_DoesSurvivorHaveRewardType(iPlayer, MT_REWARD_DEVELOPER4)));
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallFatalFalling(int survivor)
#else
public Action MT_OnFatalFalling(int survivor)
#endif
{
	if (bIsSurvivor(survivor) && g_esRecallPlayer[survivor].g_bBlockFall)
	{
		g_esRecallPlayer[survivor].g_bBlockFall = false;
	}
#if !defined MT_ABILITIES_MAIN2
	return Plugin_Continue;
#endif
}

#if defined MT_ABILITIES_MAIN2
void vRecallPlayerEventKilled(int victim)
#else
public void MT_OnPlayerEventKilled(int victim, int attacker)
#endif
{
	if (MT_IsTankSupported(victim, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		bool bTeleport = false;
		float flOrigin[3], flAngles[3];
		int iTeammate = 0;
		for (iTeammate = 1; iTeammate <= MaxClients; iTeammate++)
		{
			if (bIsSurvivor(iTeammate, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bIsSurvivorDisabled(iTeammate) && !g_esRecallPlayer[iTeammate].g_bAffected)
			{
				bTeleport = true;

				GetClientAbsOrigin(iTeammate, flOrigin);
				GetClientEyeAngles(iTeammate, flAngles);

				break;
			}
		}

		if (bTeleport)
		{
			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esRecallPlayer[iSurvivor].g_bAffected && g_esRecallPlayer[iSurvivor].g_iOwner == victim && iSurvivor != iTeammate)
				{
					g_esRecallPlayer[iSurvivor].g_bAffected = false;
					g_esRecallPlayer[iSurvivor].g_iOwner = -1;

					TeleportEntity(iSurvivor, flOrigin, flAngles);
					vFixPlayerPosition(iSurvivor);
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallRewardSurvivor(int survivor, int &type, bool apply)
#else
public Action MT_OnRewardSurvivor(int survivor, int tank, int &type, int priority, float &duration, bool apply)
#endif
{
	if (bIsHumanSurvivor(survivor) && (type & MT_REWARD_DEVELOPER4))
	{
		switch (apply)
		{
			case true: vResetRecallTimers(survivor);
			case false: vResetRecallTimers(survivor, false);
		}
	}
#if !defined MT_ABILITIES_MAIN2
	return Plugin_Continue;
#endif
}

#if defined MT_ABILITIES_MAIN2
void vRecallAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if ((MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRecallAbility[g_esRecallPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRecallPlayer[tank].g_iAccessFlags)) || g_esRecallCache[tank].g_iHumanAbility == 0)) || bIsPlayerIncapacitated(tank))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esRecallCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esRecallCache[tank].g_iRecallAbility > 0)
	{
		vRecallAbility(tank, false);
		vRecallAbility(tank, true);
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esRecallCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRecallCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRecallPlayer[tank].g_iTankType, tank) || (g_esRecallCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRecallCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRecallAbility[g_esRecallPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRecallPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		int iTime = GetTime();
		if ((button & MT_MAIN_KEY) && (g_esRecallCache[tank].g_iRecallAbility == 1 || g_esRecallCache[tank].g_iRecallAbility == 3) && g_esRecallCache[tank].g_iHumanAbility == 1)
		{
			switch (g_esRecallPlayer[tank].g_iCooldown2 == -1 || g_esRecallPlayer[tank].g_iCooldown2 <= iTime)
			{
				case true: vRecallAbility(tank, true);
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallHuman6", (g_esRecallPlayer[tank].g_iCooldown2 - iTime));
			}
		}

		if ((button & MT_SUB_KEY) && (g_esRecallCache[tank].g_iRecallAbility == 2 || g_esRecallCache[tank].g_iRecallAbility == 3) && g_esRecallCache[tank].g_iHumanAbility == 1)
		{
			switch (g_esRecallPlayer[tank].g_iCooldown == -1 || g_esRecallPlayer[tank].g_iCooldown <= iTime)
			{
				case true: vRecallAbility(tank, false);
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallHuman5", (g_esRecallPlayer[tank].g_iCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN2
void vRecallChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveRecall(tank);
}

#if defined MT_ABILITIES_MAIN2
void vRecallPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		vResetRecallTimers(tank);
	}
}

void vClearHealthValueList(int tank)
{
	if (g_esRecallPlayer[tank].g_alHealthVals != null)
	{
		g_esRecallPlayer[tank].g_alHealthVals.Clear();

		delete g_esRecallPlayer[tank].g_alHealthVals;
	}
}

void vClearPreviousLocationList(int tank)
{
	if (g_esRecallPlayer[tank].g_alPrevLocations != null)
	{
		g_esRecallPlayer[tank].g_alPrevLocations.Clear();

		delete g_esRecallPlayer[tank].g_alPrevLocations;
	}
}

void vRecallAbility(int tank, bool main)
{
	if (bIsAreaNarrow(tank, g_esRecallCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esRecallCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esRecallPlayer[tank].g_iTankType, tank) || (g_esRecallCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esRecallCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esRecallAbility[g_esRecallPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esRecallPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			int iTime = GetTime();
			if (g_esRecallPlayer[tank].g_iCooldown2 != -1 && g_esRecallPlayer[tank].g_iCooldown2 >= iTime)
			{
				return;
			}

			if (g_esRecallCache[tank].g_iRecallAbility == 1 || g_esRecallCache[tank].g_iRecallAbility == 3)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esRecallPlayer[tank].g_iAmmoCount2 < g_esRecallCache[tank].g_iHumanAmmo && g_esRecallCache[tank].g_iHumanAmmo > 0))
				{
					if (GetRandomFloat(0.1, 100.0) <= g_esRecallCache[tank].g_flRecallRewindChance)
					{
						vRecallRewind(tank, g_esRecallCache[tank].g_flRecallRewindThreshold, g_esRecallCache[tank].g_iRecallRewindLifetime, g_esRecallCache[tank].g_iRecallRewindMode, g_esRecallCache[tank].g_iRecallRewindCleanse);
					}
					else if (g_esRecallPlayer[tank].g_iCooldown2 == -1 || g_esRecallPlayer[tank].g_iCooldown2 <= iTime)
					{
						if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRecallCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallHuman4");
						}
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRecallCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallAmmo2");
				}
			}
		}
		case false:
		{
			int iTime = GetTime();
			if (g_esRecallPlayer[tank].g_iCooldown != -1 && g_esRecallPlayer[tank].g_iCooldown >= iTime)
			{
				return;
			}

			if (g_esRecallCache[tank].g_iRecallAbility == 2 || g_esRecallCache[tank].g_iRecallAbility == 3)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esRecallPlayer[tank].g_iAmmoCount < g_esRecallCache[tank].g_iHumanAmmo && g_esRecallCache[tank].g_iHumanAmmo > 0))
				{
					if (g_esRecallPlayer[tank].g_iCount < g_esRecallCache[tank].g_iRecallBlinkCount)
					{
						if (GetRandomFloat(0.1, 100.0) <= g_esRecallCache[tank].g_flRecallBlinkChance)
						{
							g_esRecallPlayer[tank].g_iCount++;

							float flEyeAngles[3], flOrigin[3], flDirection[3], flTemp[3];
							if (bIsInfected(tank, MT_CHECK_FAKECLIENT))
							{
								vRecallBlink(tank, GetClientButtons(tank), flOrigin, flEyeAngles, flDirection, flTemp);
							}
							else
							{
								GetClientEyeAngles(tank, flEyeAngles);
								GetClientAbsOrigin(tank, flOrigin);
								flOrigin[2] += 20.0;

								switch (MT_GetRandomInt(1, 2))
								{
									case 1:
									{
										GetAngleVectors(flEyeAngles, flDirection, NULL_VECTOR, NULL_VECTOR);
										NormalizeVector(flDirection, flDirection);
										AddVectors(flTemp, flDirection, flTemp);
										vCopyVector(flTemp, flDirection);
									}
									case 2:
									{
										GetAngleVectors(flEyeAngles, flDirection, NULL_VECTOR, NULL_VECTOR);
										NormalizeVector(flDirection, flDirection);
										SubtractVectors(flTemp, flDirection, flTemp);
										vCopyVector(flTemp, flDirection);
									}
								}

								switch (MT_GetRandomInt(1, 2))
								{
									case 1:
									{
										GetAngleVectors(flEyeAngles, NULL_VECTOR, flDirection, NULL_VECTOR);
										NormalizeVector(flDirection, flDirection);
										AddVectors(flTemp, flDirection, flTemp);
										vCopyVector(flTemp, flDirection);
									}
									case 2:
									{
										GetAngleVectors(flEyeAngles, NULL_VECTOR, flDirection, NULL_VECTOR);
										NormalizeVector(flDirection, flDirection);
										SubtractVectors(flTemp, flDirection, flTemp);
										vCopyVector(flTemp, flDirection);
									}
								}
							}

							int iVictim = iGetInfectedVictim(tank, g_esRecallPlayer[tank].g_iInfectedType);
							iVictim = (iVictim <= 0) ? tank : iVictim;
							if (bIsSurvivor(iVictim))
							{
								g_esRecallPlayer[iVictim].g_bAffected = true;
								g_esRecallPlayer[iVictim].g_iOwner = tank;

								MT_TeleportPlayerAhead(iVictim, flOrigin, flEyeAngles, NULL_VECTOR, flDirection, g_esRecallCache[tank].g_flRecallBlinkRange);
							}

							MT_TeleportPlayerAhead(tank, flOrigin, flEyeAngles, NULL_VECTOR, flDirection, g_esRecallCache[tank].g_flRecallBlinkRange);

							if (g_iGraphicsLevel > 2)
							{
								vAttachParticle(iVictim, PARTICLE_ELECTRICITY, 0.75, 30.0);
							}

							if (bIsPlayerStuck(tank))
							{
								g_esRecallPlayer[tank].g_iCount--;
							}
							else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRecallCache[tank].g_iHumanAbility == 1)
							{
								g_esRecallPlayer[tank].g_iAmmoCount++;

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallHuman", g_esRecallPlayer[tank].g_iAmmoCount, g_esRecallCache[tank].g_iHumanAmmo);
							}

							if (g_esRecallCache[tank].g_iRecallMessage & MT_MESSAGE_RANGE)
							{
								char sTankName[64];
								MT_GetTankName(tank, sTankName);
								MT_PrintToChatAll("%s %t", MT_TAG2, "Recall", sTankName);
								MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Recall", LANG_SERVER, sTankName);
							}
						}
						else if (g_esRecallPlayer[tank].g_iCooldown == -1 || g_esRecallPlayer[tank].g_iCooldown <= iTime)
						{
							if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRecallCache[tank].g_iHumanAbility == 1)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallHuman2");
							}
						}
					}
					else
					{
						int iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRecallCache[tank].g_iHumanAbility == 1 && g_esRecallPlayer[tank].g_iAmmoCount < g_esRecallCache[tank].g_iHumanAmmo && g_esRecallCache[tank].g_iHumanAmmo > 0) ? g_esRecallCache[tank].g_iHumanCooldown : g_esRecallCache[tank].g_iRecallBlinkCooldown;
						g_esRecallPlayer[tank].g_iCooldown = (iTime + iCooldown);
						if (g_esRecallPlayer[tank].g_iCooldown != -1 && g_esRecallPlayer[tank].g_iCooldown >= iTime)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallHuman7", (g_esRecallPlayer[tank].g_iCooldown - iTime));
						}
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esRecallCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "RecallAmmo");
				}
			}
		}
	}
}

void vRecallBlink(int tank, int buttons, float origin[3], float angles[3], float direction[3], float temp[3])
{
	GetClientEyeAngles(tank, angles);
	GetClientAbsOrigin(tank, origin);
	origin[2] += 20.0;

	if (buttons & IN_FORWARD)
	{
		GetAngleVectors(angles, direction, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(direction, direction);
		AddVectors(temp, direction, temp);
		vCopyVector(temp, direction);
	}
	else if (buttons & IN_BACK)
	{
		GetAngleVectors(angles, direction, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(direction, direction);
		SubtractVectors(temp, direction, temp);
		vCopyVector(temp, direction);
	}

	if (buttons & IN_MOVELEFT)
	{
		GetAngleVectors(angles, NULL_VECTOR, direction, NULL_VECTOR);
		NormalizeVector(direction, direction);
		SubtractVectors(temp, direction, temp);
		vCopyVector(temp, direction);
	}
	else if (buttons & IN_MOVERIGHT)
	{
		GetAngleVectors(angles, NULL_VECTOR, direction, NULL_VECTOR);
		NormalizeVector(direction, direction);
		AddVectors(temp, direction, temp);
		vCopyVector(temp, direction);
	}
}

void vRecallRewind(int player, float threshold, int lifetime, int mode, int cleanse, bool override = false)
{
	bool bInfected = bIsInfected(player);
	int iHealth = GetEntProp(player, Prop_Data, "m_iHealth"), iMaxHealth = bInfected ? MT_TankMaxHealth(player, 1) : GetEntProp(player, Prop_Data, "m_iMaxHealth");
	float flThreshold = (iMaxHealth * threshold);
	if (iHealth < flThreshold || override)
	{
		if (mode != 2 && g_esRecallPlayer[player].g_alHealthVals != null)
		{
			int iSize = g_esRecallPlayer[player].g_alHealthVals.Length, iIndex = (0 < iSize <= lifetime) ? iSize : (iSize - lifetime);
			if (iIndex > 0)
			{
				int iNewHealth = g_esRecallPlayer[player].g_alHealthVals.Get(iIndex - 1);
				if (0 < iHealth < iNewHealth)
				{
					switch (iNewHealth <= iMaxHealth)
					{
						case true: SetEntProp(player, Prop_Data, "m_iHealth", iNewHealth);
						case false: SetEntProp(player, Prop_Data, "m_iHealth", iMaxHealth);
					}
				}
			}
		}

		if (mode != 1 && g_esRecallPlayer[player].g_alPrevLocations != null)
		{
			int iSize = g_esRecallPlayer[player].g_alPrevLocations.Length, iIndex = (0 < iSize <= lifetime) ? iSize : (iSize - lifetime);
			if (iIndex > 0)
			{
				float flNewPos[3], flEyeAngles[3];
				GetClientEyeAngles(player, flEyeAngles);
				g_esRecallPlayer[player].g_alPrevLocations.GetArray((iIndex - 1), flNewPos, sizeof flNewPos);

				int iVictim = 0;
				if (bInfected)
				{
					iVictim = iGetInfectedVictim(player, g_esRecallPlayer[player].g_iInfectedType);
					iVictim = (iVictim <= 0) ? player : iVictim;
					if (bIsSurvivor(iVictim))
					{
						g_esRecallPlayer[iVictim].g_bAffected = true;
						g_esRecallPlayer[iVictim].g_iOwner = player;

						TeleportEntity(iVictim, flNewPos, flEyeAngles);
						vFixPlayerPosition(iVictim);
					}
				}
				else
				{
					iVictim = iGetSurvivorAttacker(player);
					if (bIsInfected(iVictim))
					{
						TeleportEntity(iVictim, flNewPos, flEyeAngles);
						vFixPlayerPosition(iVictim);
						vForceVocalize(player, "PlayerDeath");
					}
				}

				bool bSurvivor = bIsSurvivor(player);
				g_esRecallPlayer[player].g_bBlockFall = bSurvivor;
				g_esRecallPlayer[player].g_flLastRecall[1] = bSurvivor ? (GetGameTime() + 5.0) : 0.0;

				TeleportEntity(player, flNewPos, flEyeAngles);
				vFixPlayerPosition(player);

				if (g_iGraphicsLevel > 2)
				{
					vAttachParticle(iVictim, PARTICLE_ELECTRICITY, 0.75, 30.0);
				}

				if (cleanse == 1)
				{
					MT_UnvomitPlayer(player);
					ExtinguishEntity(player);
				}
			}
		}

		if (bInfected)
		{
			bool bHuman = bIsInfected(player, MT_CHECK_FAKECLIENT);
			if (bHuman && g_esRecallCache[player].g_iHumanAbility == 1)
			{
				g_esRecallPlayer[player].g_iAmmoCount2++;

				MT_PrintToChat(player, "%s %t", MT_TAG3, "RecallHuman3", g_esRecallPlayer[player].g_iAmmoCount2, g_esRecallCache[player].g_iHumanAmmo);
			}

			int iTime = GetTime(), iCooldown = (bHuman && g_esRecallCache[player].g_iHumanAbility == 1 && g_esRecallPlayer[player].g_iAmmoCount2 < g_esRecallCache[player].g_iHumanAmmo && g_esRecallCache[player].g_iHumanAmmo > 0) ? g_esRecallCache[player].g_iHumanRangeCooldown : g_esRecallCache[player].g_iRecallRewindCooldown;
			g_esRecallPlayer[player].g_iCooldown2 = (iTime + iCooldown);
			if (g_esRecallPlayer[player].g_iCooldown2 != -1 && g_esRecallPlayer[player].g_iCooldown2 >= iTime)
			{
				MT_PrintToChat(player, "%s %t", MT_TAG3, "RecallHuman8", (g_esRecallPlayer[player].g_iCooldown2 - iTime));
			}

			if (g_esRecallCache[player].g_iRecallMessage & MT_MESSAGE_MELEE)
			{
				char sTankName[64];
				MT_GetTankName(player, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Recall2", sTankName, lifetime);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Recall2", LANG_SERVER, sTankName, lifetime);
			}
		}
	}
}

void vRecallCopyStats2(int oldTank, int newTank)
{
	g_esRecallPlayer[newTank].g_iAmmoCount = g_esRecallPlayer[oldTank].g_iAmmoCount;
	g_esRecallPlayer[newTank].g_iAmmoCount2 = g_esRecallPlayer[oldTank].g_iAmmoCount2;
	g_esRecallPlayer[newTank].g_iCooldown = g_esRecallPlayer[oldTank].g_iCooldown;
	g_esRecallPlayer[newTank].g_iCooldown2 = g_esRecallPlayer[oldTank].g_iCooldown2;
	g_esRecallPlayer[newTank].g_iCount = g_esRecallPlayer[oldTank].g_iCount;
}

void vRemoveRecall(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esRecallPlayer[iSurvivor].g_bAffected && g_esRecallPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esRecallPlayer[iSurvivor].g_bAffected = false;
			g_esRecallPlayer[iSurvivor].g_iOwner = -1;
		}
	}

	g_esRecallPlayer[tank].g_bAffected = false;
	g_esRecallPlayer[tank].g_bBlockFall = false;
	g_esRecallPlayer[tank].g_flLastRecall[0] = 0.0;
	g_esRecallPlayer[tank].g_flLastRecall[1] = 0.0;
	g_esRecallPlayer[tank].g_iAmmoCount = 0;
	g_esRecallPlayer[tank].g_iAmmoCount2 = 0;
	g_esRecallPlayer[tank].g_iCooldown = -1;
	g_esRecallPlayer[tank].g_iCooldown2 = -1;
	g_esRecallPlayer[tank].g_iCount = 0;

	vClearHealthValueList(tank);
	vClearPreviousLocationList(tank);
}

void vRecallReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveRecall(iPlayer);
		}
	}
}

void vResetRecallTimers(int player, bool restart = true)
{
	vClearHealthValueList(player);
	vClearPreviousLocationList(player);

	if (restart)
	{
		g_esRecallPlayer[player].g_alHealthVals = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
		g_esRecallPlayer[player].g_alPrevLocations = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

		CreateTimer(1.0, tTimerStoreRecall, GetClientUserId(player), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

Action tTimerStoreRecall(Handle timer, int userid)
{
	int iPlayer = GetClientOfUserId(userid);
	bool bCancel = !MT_IsCorePluginEnabled() || !MT_IsTankSupported(iPlayer) || (!MT_HasAdminAccess(iPlayer) && !bHasAdminAccess(iPlayer, g_esRecallAbility[g_esRecallPlayer[iPlayer].g_iTankTypeRecorded].g_iAccessFlags, g_esRecallPlayer[iPlayer].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esRecallPlayer[iPlayer].g_iTankType, iPlayer) || !MT_IsCustomTankSupported(iPlayer) || g_esRecallCache[iPlayer].g_iRecallAbility == 0,
		bCancel2 = !MT_IsCorePluginEnabled() || !bIsHumanSurvivor(iPlayer) || !MT_DoesSurvivorHaveRewardType(iPlayer, MT_REWARD_DEVELOPER4);
	if (bCancel && bCancel2)
	{
		vClearHealthValueList(iPlayer);
		vClearPreviousLocationList(iPlayer);

		return Plugin_Stop;
	}

	int iLimit = bIsInfected(iPlayer) ? g_esRecallCache[iPlayer].g_iRecallRewindLifetime : 5;
	if (g_esRecallPlayer[iPlayer].g_alHealthVals != null)
	{
		int iHealth = GetEntProp(iPlayer, Prop_Data, "m_iHealth");
		g_esRecallPlayer[iPlayer].g_alHealthVals.Push(iHealth);

		int iSize = g_esRecallPlayer[iPlayer].g_alHealthVals.Length;
		if (iSize > iLimit)
		{
			for (int iPos = 0; iPos < (iSize - iLimit); iPos++)
			{
				g_esRecallPlayer[iPlayer].g_alHealthVals.Erase(0);
			}
		}
	}

	if (g_esRecallPlayer[iPlayer].g_alPrevLocations != null)
	{
		float flTankPos[3];
		GetClientAbsOrigin(iPlayer, flTankPos);
		g_esRecallPlayer[iPlayer].g_alPrevLocations.PushArray(flTankPos, sizeof flTankPos);

		int iSize = g_esRecallPlayer[iPlayer].g_alPrevLocations.Length;
		if (iSize > iLimit)
		{
			for (int iPos = 0; iPos < (iSize - iLimit); iPos++)
			{
				g_esRecallPlayer[iPlayer].g_alPrevLocations.Erase(0);
			}
		}
	}

	return Plugin_Continue;
}