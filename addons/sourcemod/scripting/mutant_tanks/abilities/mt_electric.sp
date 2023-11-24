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

#define MT_ELECTRIC_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_ELECTRIC_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Electric Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank electrocutes survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLaggedMovementInstalled, g_bLateLoad;

/**
 * Third-party natives
 **/

// [L4D & L4D2] Lagged Movement - Plugin Conflict Resolver: https://forums.alliedmods.net/showthread.php?t=340345
native any L4D_LaggedMovement(int client, float value, bool force = false);

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Electric Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "LaggedMovement"))
	{
		g_bLaggedMovementInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "LaggedMovement"))
	{
		g_bLaggedMovementInstalled = false;
	}
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_ELECTRICITY2 "electrical_arc_01_parent"
#else
	#if MT_ELECTRIC_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_ELECTRIC_SECTION "electricability"
#define MT_ELECTRIC_SECTION2 "electric ability"
#define MT_ELECTRIC_SECTION3 "electric_ability"
#define MT_ELECTRIC_SECTION4 "electric"

#define MT_MENU_ELECTRIC "Electric Ability"

char g_sElectricSounds[8][26] =
{
	"ambient/energy/zap1.wav",
	"ambient/energy/zap2.wav",
	"ambient/energy/zap3.wav",
	"ambient/energy/zap5.wav",
	"ambient/energy/zap6.wav",
	"ambient/energy/zap7.wav",
	"ambient/energy/zap8.wav",
	"ambient/energy/zap9.wav"
};

enum struct esElectricPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flCloseAreasOnly;
	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;
	float g_flElectricStunSpeed;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iElectricAbility;
	int g_iElectricCooldown;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
	int g_iElectricRangeCooldown;
	int g_iElectricSight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esElectricPlayer g_esElectricPlayer[MAXPLAYERS + 1];

enum struct esElectricTeammate
{
	float g_flCloseAreasOnly;
	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;
	float g_flElectricStunSpeed;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iElectricAbility;
	int g_iElectricCooldown;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
	int g_iElectricRangeCooldown;
	int g_iElectricSight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esElectricTeammate g_esElectricTeammate[MAXPLAYERS + 1];

enum struct esElectricAbility
{
	float g_flCloseAreasOnly;
	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;
	float g_flElectricStunSpeed;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iElectricAbility;
	int g_iElectricCooldown;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
	int g_iElectricRangeCooldown;
	int g_iElectricSight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esElectricAbility g_esElectricAbility[MT_MAXTYPES + 1];

enum struct esElectricSpecial
{
	float g_flCloseAreasOnly;
	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;
	float g_flElectricStunSpeed;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iElectricAbility;
	int g_iElectricCooldown;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
	int g_iElectricRangeCooldown;
	int g_iElectricSight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esElectricSpecial g_esElectricSpecial[MT_MAXTYPES + 1];

enum struct esElectricCache
{
	float g_flCloseAreasOnly;
	float g_flElectricChance;
	float g_flElectricDamage;
	float g_flElectricInterval;
	float g_flElectricRange;
	float g_flElectricRangeChance;
	float g_flElectricStunSpeed;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iElectricAbility;
	int g_iElectricCooldown;
	int g_iElectricDuration;
	int g_iElectricEffect;
	int g_iElectricHit;
	int g_iElectricHitMode;
	int g_iElectricMessage;
	int g_iElectricRangeCooldown;
	int g_iElectricSight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esElectricCache g_esElectricCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_electric", cmdElectricInfo, "View information about the Electric ability.");

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

#if defined MT_ABILITIES_MAIN
void vElectricMapStart()
#else
public void OnMapStart()
#endif
{
	iPrecacheParticle(PARTICLE_ELECTRICITY2);

	for (int iPos = 0; iPos < (sizeof g_sElectricSounds); iPos++)
	{
		PrecacheSound(g_sElectricSounds[iPos], true);
	}

	vElectricReset();
}

#if defined MT_ABILITIES_MAIN
void vElectricClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnElectricTakeDamage);
	vElectricReset3(client);
}

#if defined MT_ABILITIES_MAIN
void vElectricClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vElectricReset3(client);
}

#if defined MT_ABILITIES_MAIN
void vElectricMapEnd()
#else
public void OnMapEnd()
#endif
{
	vElectricReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdElectricInfo(int client, int args)
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
		case false: vElectricMenu(client, MT_ELECTRIC_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vElectricMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_ELECTRIC_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iElectricMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Electric Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iElectricMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esElectricCache[param1].g_iElectricAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esElectricCache[param1].g_iHumanAmmo - g_esElectricPlayer[param1].g_iAmmoCount), g_esElectricCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esElectricCache[param1].g_iHumanAbility == 1) ? g_esElectricCache[param1].g_iHumanCooldown : g_esElectricCache[param1].g_iElectricCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ElectricDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esElectricCache[param1].g_iElectricDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esElectricCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esElectricCache[param1].g_iHumanAbility == 1) ? g_esElectricCache[param1].g_iHumanRangeCooldown : g_esElectricCache[param1].g_iElectricRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vElectricMenu(param1, MT_ELECTRIC_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pElectric = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "ElectricMenu", param1);
			pElectric.SetTitle(sMenuTitle);
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
					case 5: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "Duration", param1);
					case 6: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "HumanSupport", param1);
					case 7: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RangeCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN
void vElectricDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_ELECTRIC, MT_MENU_ELECTRIC);
}

#if defined MT_ABILITIES_MAIN
void vElectricMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_ELECTRIC, false))
	{
		vElectricMenu(client, MT_ELECTRIC_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_ELECTRIC, false))
	{
		FormatEx(buffer, size, "%T", "ElectricMenu2", client);
	}
}

Action OnElectricTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esElectricCache[attacker].g_iElectricHitMode == 0 || g_esElectricCache[attacker].g_iElectricHitMode == 1) && bIsSurvivor(victim) && g_esElectricCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esElectricAbility[g_esElectricPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esElectricPlayer[attacker].g_iTankType, g_esElectricAbility[g_esElectricPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esElectricPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vElectricHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esElectricCache[attacker].g_flElectricChance, g_esElectricCache[attacker].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esElectricCache[victim].g_iElectricHitMode == 0 || g_esElectricCache[victim].g_iElectricHitMode == 2) && bIsSurvivor(attacker) && g_esElectricCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esElectricAbility[g_esElectricPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esElectricPlayer[victim].g_iTankType, g_esElectricAbility[g_esElectricPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esElectricPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vElectricHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esElectricCache[victim].g_flElectricChance, g_esElectricCache[victim].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vElectricPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_ELECTRIC);
}

#if defined MT_ABILITIES_MAIN
void vElectricAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_ELECTRIC_SECTION);
	list2.PushString(MT_ELECTRIC_SECTION2);
	list3.PushString(MT_ELECTRIC_SECTION3);
	list4.PushString(MT_ELECTRIC_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vElectricCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_ELECTRIC_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_ELECTRIC_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_ELECTRIC_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_ELECTRIC_SECTION4);
	if (g_esElectricCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_ELECTRIC_SECTION, false) || StrEqual(sSubset[iPos], MT_ELECTRIC_SECTION2, false) || StrEqual(sSubset[iPos], MT_ELECTRIC_SECTION3, false) || StrEqual(sSubset[iPos], MT_ELECTRIC_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esElectricCache[tank].g_iElectricAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vElectricAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerElectricCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esElectricCache[tank].g_iElectricHitMode == 0 || g_esElectricCache[tank].g_iElectricHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vElectricHit(survivor, tank, random, flChance, g_esElectricCache[tank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esElectricCache[tank].g_iElectricHitMode == 0 || g_esElectricCache[tank].g_iElectricHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vElectricHit(survivor, tank, random, flChance, g_esElectricCache[tank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerElectricCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteCell(iPos);
								dpCombo.WriteString(classname);
							}
						}
					}
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricConfigsLoad(int mode)
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
				g_esElectricAbility[iIndex].g_iAccessFlags = 0;
				g_esElectricAbility[iIndex].g_iImmunityFlags = 0;
				g_esElectricAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esElectricAbility[iIndex].g_iComboAbility = 0;
				g_esElectricAbility[iIndex].g_iHumanAbility = 0;
				g_esElectricAbility[iIndex].g_iHumanAmmo = 5;
				g_esElectricAbility[iIndex].g_iHumanCooldown = 0;
				g_esElectricAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esElectricAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esElectricAbility[iIndex].g_iRequiresHumans = 0;
				g_esElectricAbility[iIndex].g_iElectricAbility = 0;
				g_esElectricAbility[iIndex].g_iElectricEffect = 0;
				g_esElectricAbility[iIndex].g_iElectricMessage = 0;
				g_esElectricAbility[iIndex].g_flElectricChance = 33.3;
				g_esElectricAbility[iIndex].g_iElectricCooldown = 0;
				g_esElectricAbility[iIndex].g_flElectricDamage = 1.0;
				g_esElectricAbility[iIndex].g_iElectricDuration = 5;
				g_esElectricAbility[iIndex].g_iElectricHit = 0;
				g_esElectricAbility[iIndex].g_iElectricHitMode = 0;
				g_esElectricAbility[iIndex].g_flElectricInterval = 1.0;
				g_esElectricAbility[iIndex].g_flElectricRange = 150.0;
				g_esElectricAbility[iIndex].g_flElectricRangeChance = 15.0;
				g_esElectricAbility[iIndex].g_iElectricRangeCooldown = 0;
				g_esElectricAbility[iIndex].g_iElectricSight = 0;
				g_esElectricAbility[iIndex].g_flElectricStunSpeed = 0.25;

				g_esElectricSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esElectricSpecial[iIndex].g_iComboAbility = -1;
				g_esElectricSpecial[iIndex].g_iHumanAbility = -1;
				g_esElectricSpecial[iIndex].g_iHumanAmmo = -1;
				g_esElectricSpecial[iIndex].g_iHumanCooldown = -1;
				g_esElectricSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esElectricSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esElectricSpecial[iIndex].g_iRequiresHumans = -1;
				g_esElectricSpecial[iIndex].g_iElectricAbility = -1;
				g_esElectricSpecial[iIndex].g_iElectricEffect = -1;
				g_esElectricSpecial[iIndex].g_iElectricMessage = -1;
				g_esElectricSpecial[iIndex].g_flElectricChance = -1.0;
				g_esElectricSpecial[iIndex].g_iElectricCooldown = -1;
				g_esElectricSpecial[iIndex].g_flElectricDamage = -1.0;
				g_esElectricSpecial[iIndex].g_iElectricDuration = -1;
				g_esElectricSpecial[iIndex].g_iElectricHit = -1;
				g_esElectricSpecial[iIndex].g_iElectricHitMode = -1;
				g_esElectricSpecial[iIndex].g_flElectricInterval = -1.0;
				g_esElectricSpecial[iIndex].g_flElectricRange = -1.0;
				g_esElectricSpecial[iIndex].g_flElectricRangeChance = -1.0;
				g_esElectricSpecial[iIndex].g_iElectricRangeCooldown = -1;
				g_esElectricSpecial[iIndex].g_iElectricSight = -1;
				g_esElectricSpecial[iIndex].g_flElectricStunSpeed = -1.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esElectricPlayer[iPlayer].g_iAccessFlags = -1;
				g_esElectricPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esElectricPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esElectricPlayer[iPlayer].g_iComboAbility = -1;
				g_esElectricPlayer[iPlayer].g_iHumanAbility = -1;
				g_esElectricPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esElectricPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esElectricPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esElectricPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esElectricPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esElectricPlayer[iPlayer].g_iElectricAbility = -1;
				g_esElectricPlayer[iPlayer].g_iElectricEffect = -1;
				g_esElectricPlayer[iPlayer].g_iElectricMessage = -1;
				g_esElectricPlayer[iPlayer].g_flElectricChance = -1.0;
				g_esElectricPlayer[iPlayer].g_iElectricCooldown = -1;
				g_esElectricPlayer[iPlayer].g_flElectricDamage = -1.0;
				g_esElectricPlayer[iPlayer].g_iElectricDuration = -1;
				g_esElectricPlayer[iPlayer].g_iElectricHit = -1;
				g_esElectricPlayer[iPlayer].g_iElectricHitMode = -1;
				g_esElectricPlayer[iPlayer].g_flElectricInterval = -1.0;
				g_esElectricPlayer[iPlayer].g_flElectricRange = -1.0;
				g_esElectricPlayer[iPlayer].g_flElectricRangeChance = -1.0;
				g_esElectricPlayer[iPlayer].g_iElectricRangeCooldown = -1;
				g_esElectricPlayer[iPlayer].g_iElectricSight = -1;
				g_esElectricPlayer[iPlayer].g_flElectricStunSpeed = -1.0;

				g_esElectricTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esElectricTeammate[iPlayer].g_iComboAbility = -1;
				g_esElectricTeammate[iPlayer].g_iHumanAbility = -1;
				g_esElectricTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esElectricTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esElectricTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esElectricTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esElectricTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esElectricTeammate[iPlayer].g_iElectricAbility = -1;
				g_esElectricTeammate[iPlayer].g_iElectricEffect = -1;
				g_esElectricTeammate[iPlayer].g_iElectricMessage = -1;
				g_esElectricTeammate[iPlayer].g_flElectricChance = -1.0;
				g_esElectricTeammate[iPlayer].g_iElectricCooldown = -1;
				g_esElectricTeammate[iPlayer].g_flElectricDamage = -1.0;
				g_esElectricTeammate[iPlayer].g_iElectricDuration = -1;
				g_esElectricTeammate[iPlayer].g_iElectricHit = -1;
				g_esElectricTeammate[iPlayer].g_iElectricHitMode = -1;
				g_esElectricTeammate[iPlayer].g_flElectricInterval = -1.0;
				g_esElectricTeammate[iPlayer].g_flElectricRange = -1.0;
				g_esElectricTeammate[iPlayer].g_flElectricRangeChance = -1.0;
				g_esElectricTeammate[iPlayer].g_iElectricRangeCooldown = -1;
				g_esElectricTeammate[iPlayer].g_iElectricSight = -1;
				g_esElectricTeammate[iPlayer].g_flElectricStunSpeed = -1.0;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esElectricTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esElectricTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esElectricTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esElectricTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esElectricTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esElectricTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esElectricTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esElectricTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esElectricTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esElectricTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esElectricTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esElectricTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esElectricTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esElectricTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esElectricTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esElectricTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esElectricTeammate[admin].g_iElectricAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esElectricTeammate[admin].g_iElectricAbility, value, -1, 1);
			g_esElectricTeammate[admin].g_iElectricEffect = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esElectricTeammate[admin].g_iElectricEffect, value, -1, 7);
			g_esElectricTeammate[admin].g_iElectricMessage = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esElectricTeammate[admin].g_iElectricMessage, value, -1, 3);
			g_esElectricTeammate[admin].g_iElectricSight = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esElectricTeammate[admin].g_iElectricSight, value, -1, 5);
			g_esElectricTeammate[admin].g_flElectricChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", g_esElectricTeammate[admin].g_flElectricChance, value, -1.0, 100.0);
			g_esElectricTeammate[admin].g_iElectricCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricCooldown", "Electric Cooldown", "Electric_Cooldown", "cooldown", g_esElectricTeammate[admin].g_iElectricCooldown, value, -1, 99999);
			g_esElectricTeammate[admin].g_flElectricDamage = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", g_esElectricTeammate[admin].g_flElectricDamage, value, -1.0, 99999.0);
			g_esElectricTeammate[admin].g_iElectricDuration = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", g_esElectricTeammate[admin].g_iElectricDuration, value, -1, 99999);
			g_esElectricTeammate[admin].g_iElectricHit = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", g_esElectricTeammate[admin].g_iElectricHit, value, -1, 1);
			g_esElectricTeammate[admin].g_iElectricHitMode = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", g_esElectricTeammate[admin].g_iElectricHitMode, value, -1, 2);
			g_esElectricTeammate[admin].g_flElectricInterval = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", g_esElectricTeammate[admin].g_flElectricInterval, value, -1.0, 99999.0);
			g_esElectricTeammate[admin].g_flElectricRange = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRange", "Electric Range", "Electric_Range", "range", g_esElectricTeammate[admin].g_flElectricRange, value, -1.0, 99999.0);
			g_esElectricTeammate[admin].g_flElectricRangeChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", g_esElectricTeammate[admin].g_flElectricRangeChance, value, -1.0, 100.0);
			g_esElectricTeammate[admin].g_iElectricRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeCooldown", "Electric Range Cooldown", "Electric_Range_Cooldown", "rangecooldown", g_esElectricTeammate[admin].g_iElectricRangeCooldown, value, -1, 99999);
			g_esElectricTeammate[admin].g_flElectricStunSpeed = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricStunSpeed", "Electric Stun Speed", "Electric_Stun_Speed", "stunspeed", g_esElectricTeammate[admin].g_flElectricStunSpeed, value, -1.0, 0.99);
		}
		else
		{
			g_esElectricPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esElectricPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esElectricPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esElectricPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esElectricPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esElectricPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esElectricPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esElectricPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esElectricPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esElectricPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esElectricPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esElectricPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esElectricPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esElectricPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esElectricPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esElectricPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esElectricPlayer[admin].g_iElectricAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esElectricPlayer[admin].g_iElectricAbility, value, -1, 1);
			g_esElectricPlayer[admin].g_iElectricEffect = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esElectricPlayer[admin].g_iElectricEffect, value, -1, 7);
			g_esElectricPlayer[admin].g_iElectricMessage = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esElectricPlayer[admin].g_iElectricMessage, value, -1, 3);
			g_esElectricPlayer[admin].g_iElectricSight = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esElectricPlayer[admin].g_iElectricSight, value, -1, 5);
			g_esElectricPlayer[admin].g_flElectricChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", g_esElectricPlayer[admin].g_flElectricChance, value, -1.0, 100.0);
			g_esElectricPlayer[admin].g_iElectricCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricCooldown", "Electric Cooldown", "Electric_Cooldown", "cooldown", g_esElectricPlayer[admin].g_iElectricCooldown, value, -1, 99999);
			g_esElectricPlayer[admin].g_flElectricDamage = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", g_esElectricPlayer[admin].g_flElectricDamage, value, -1.0, 99999.0);
			g_esElectricPlayer[admin].g_iElectricDuration = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", g_esElectricPlayer[admin].g_iElectricDuration, value, -1, 99999);
			g_esElectricPlayer[admin].g_iElectricHit = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", g_esElectricPlayer[admin].g_iElectricHit, value, -1, 1);
			g_esElectricPlayer[admin].g_iElectricHitMode = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", g_esElectricPlayer[admin].g_iElectricHitMode, value, -1, 2);
			g_esElectricPlayer[admin].g_flElectricInterval = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", g_esElectricPlayer[admin].g_flElectricInterval, value, -1.0, 99999.0);
			g_esElectricPlayer[admin].g_flElectricRange = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRange", "Electric Range", "Electric_Range", "range", g_esElectricPlayer[admin].g_flElectricRange, value, -1.0, 99999.0);
			g_esElectricPlayer[admin].g_flElectricRangeChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", g_esElectricPlayer[admin].g_flElectricRangeChance, value, -1.0, 100.0);
			g_esElectricPlayer[admin].g_iElectricRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeCooldown", "Electric Range Cooldown", "Electric_Range_Cooldown", "rangecooldown", g_esElectricPlayer[admin].g_iElectricRangeCooldown, value, -1, 99999);
			g_esElectricPlayer[admin].g_flElectricStunSpeed = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricStunSpeed", "Electric Stun Speed", "Electric_Stun_Speed", "stunspeed", g_esElectricPlayer[admin].g_flElectricStunSpeed, value, -1.0, 0.99);
			g_esElectricPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esElectricPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esElectricSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esElectricSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esElectricSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esElectricSpecial[type].g_iComboAbility, value, -1, 1);
			g_esElectricSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esElectricSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esElectricSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esElectricSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esElectricSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esElectricSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esElectricSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esElectricSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esElectricSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esElectricSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esElectricSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esElectricSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esElectricSpecial[type].g_iElectricAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esElectricSpecial[type].g_iElectricAbility, value, -1, 1);
			g_esElectricSpecial[type].g_iElectricEffect = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esElectricSpecial[type].g_iElectricEffect, value, -1, 7);
			g_esElectricSpecial[type].g_iElectricMessage = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esElectricSpecial[type].g_iElectricMessage, value, -1, 3);
			g_esElectricSpecial[type].g_iElectricSight = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esElectricSpecial[type].g_iElectricSight, value, -1, 5);
			g_esElectricSpecial[type].g_flElectricChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", g_esElectricSpecial[type].g_flElectricChance, value, -1.0, 100.0);
			g_esElectricSpecial[type].g_iElectricCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricCooldown", "Electric Cooldown", "Electric_Cooldown", "cooldown", g_esElectricSpecial[type].g_iElectricCooldown, value, -1, 99999);
			g_esElectricSpecial[type].g_flElectricDamage = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", g_esElectricSpecial[type].g_flElectricDamage, value, -1.0, 99999.0);
			g_esElectricSpecial[type].g_iElectricDuration = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", g_esElectricSpecial[type].g_iElectricDuration, value, -1, 99999);
			g_esElectricSpecial[type].g_iElectricHit = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", g_esElectricSpecial[type].g_iElectricHit, value, -1, 1);
			g_esElectricSpecial[type].g_iElectricHitMode = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", g_esElectricSpecial[type].g_iElectricHitMode, value, -1, 2);
			g_esElectricSpecial[type].g_flElectricInterval = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", g_esElectricSpecial[type].g_flElectricInterval, value, -1.0, 99999.0);
			g_esElectricSpecial[type].g_flElectricRange = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRange", "Electric Range", "Electric_Range", "range", g_esElectricSpecial[type].g_flElectricRange, value, -1.0, 99999.0);
			g_esElectricSpecial[type].g_flElectricRangeChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", g_esElectricSpecial[type].g_flElectricRangeChance, value, -1.0, 100.0);
			g_esElectricSpecial[type].g_iElectricRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeCooldown", "Electric Range Cooldown", "Electric_Range_Cooldown", "rangecooldown", g_esElectricSpecial[type].g_iElectricRangeCooldown, value, -1, 99999);
			g_esElectricSpecial[type].g_flElectricStunSpeed = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricStunSpeed", "Electric Stun Speed", "Electric_Stun_Speed", "stunspeed", g_esElectricSpecial[type].g_flElectricStunSpeed, value, -1.0, 0.99);
		}
		else
		{
			g_esElectricAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esElectricAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esElectricAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esElectricAbility[type].g_iComboAbility, value, -1, 1);
			g_esElectricAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esElectricAbility[type].g_iHumanAbility, value, -1, 2);
			g_esElectricAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esElectricAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esElectricAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esElectricAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esElectricAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esElectricAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esElectricAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esElectricAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esElectricAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esElectricAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esElectricAbility[type].g_iElectricAbility = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esElectricAbility[type].g_iElectricAbility, value, -1, 1);
			g_esElectricAbility[type].g_iElectricEffect = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esElectricAbility[type].g_iElectricEffect, value, -1, 7);
			g_esElectricAbility[type].g_iElectricMessage = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esElectricAbility[type].g_iElectricMessage, value, -1, 3);
			g_esElectricAbility[type].g_iElectricSight = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esElectricAbility[type].g_iElectricSight, value, -1, 5);
			g_esElectricAbility[type].g_flElectricChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", g_esElectricAbility[type].g_flElectricChance, value, -1.0, 100.0);
			g_esElectricAbility[type].g_iElectricCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricCooldown", "Electric Cooldown", "Electric_Cooldown", "cooldown", g_esElectricAbility[type].g_iElectricCooldown, value, -1, 99999);
			g_esElectricAbility[type].g_flElectricDamage = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", g_esElectricAbility[type].g_flElectricDamage, value, -1.0, 99999.0);
			g_esElectricAbility[type].g_iElectricDuration = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", g_esElectricAbility[type].g_iElectricDuration, value, -1, 99999);
			g_esElectricAbility[type].g_iElectricHit = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", g_esElectricAbility[type].g_iElectricHit, value, -1, 1);
			g_esElectricAbility[type].g_iElectricHitMode = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", g_esElectricAbility[type].g_iElectricHitMode, value, -1, 2);
			g_esElectricAbility[type].g_flElectricInterval = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", g_esElectricAbility[type].g_flElectricInterval, value, -1.0, 99999.0);
			g_esElectricAbility[type].g_flElectricRange = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRange", "Electric Range", "Electric_Range", "range", g_esElectricAbility[type].g_flElectricRange, value, -1.0, 99999.0);
			g_esElectricAbility[type].g_flElectricRangeChance = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", g_esElectricAbility[type].g_flElectricRangeChance, value, -1.0, 100.0);
			g_esElectricAbility[type].g_iElectricRangeCooldown = iGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricRangeCooldown", "Electric Range Cooldown", "Electric_Range_Cooldown", "rangecooldown", g_esElectricAbility[type].g_iElectricRangeCooldown, value, -1, 99999);
			g_esElectricAbility[type].g_flElectricStunSpeed = flGetKeyValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ElectricStunSpeed", "Electric Stun Speed", "Electric_Stun_Speed", "stunspeed", g_esElectricAbility[type].g_flElectricStunSpeed, value, -1.0, 0.99);
			g_esElectricAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esElectricAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_ELECTRIC_SECTION, MT_ELECTRIC_SECTION2, MT_ELECTRIC_SECTION3, MT_ELECTRIC_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esElectricPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esElectricPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esElectricPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esElectricCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flCloseAreasOnly, g_esElectricPlayer[tank].g_flCloseAreasOnly, g_esElectricSpecial[iType].g_flCloseAreasOnly, g_esElectricAbility[iType].g_flCloseAreasOnly, 1);
		g_esElectricCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iComboAbility, g_esElectricPlayer[tank].g_iComboAbility, g_esElectricSpecial[iType].g_iComboAbility, g_esElectricAbility[iType].g_iComboAbility, 1);
		g_esElectricCache[tank].g_flElectricChance = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flElectricChance, g_esElectricPlayer[tank].g_flElectricChance, g_esElectricSpecial[iType].g_flElectricChance, g_esElectricAbility[iType].g_flElectricChance, 1);
		g_esElectricCache[tank].g_flElectricDamage = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flElectricDamage, g_esElectricPlayer[tank].g_flElectricDamage, g_esElectricSpecial[iType].g_flElectricDamage, g_esElectricAbility[iType].g_flElectricDamage, 1);
		g_esElectricCache[tank].g_iElectricDuration = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricDuration, g_esElectricPlayer[tank].g_iElectricDuration, g_esElectricSpecial[iType].g_iElectricDuration, g_esElectricAbility[iType].g_iElectricDuration, 1);
		g_esElectricCache[tank].g_flElectricInterval = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flElectricInterval, g_esElectricPlayer[tank].g_flElectricInterval, g_esElectricSpecial[iType].g_flElectricInterval, g_esElectricAbility[iType].g_flElectricInterval, 1);
		g_esElectricCache[tank].g_flElectricRange = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flElectricRange, g_esElectricPlayer[tank].g_flElectricRange, g_esElectricSpecial[iType].g_flElectricRange, g_esElectricAbility[iType].g_flElectricRange, 1);
		g_esElectricCache[tank].g_flElectricRangeChance = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flElectricRangeChance, g_esElectricPlayer[tank].g_flElectricRangeChance, g_esElectricSpecial[iType].g_flElectricRangeChance, g_esElectricAbility[iType].g_flElectricRangeChance, 1);
		g_esElectricCache[tank].g_flElectricStunSpeed = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flElectricStunSpeed, g_esElectricPlayer[tank].g_flElectricStunSpeed, g_esElectricSpecial[iType].g_flElectricStunSpeed, g_esElectricAbility[iType].g_flElectricStunSpeed, 1);
		g_esElectricCache[tank].g_iElectricAbility = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricAbility, g_esElectricPlayer[tank].g_iElectricAbility, g_esElectricSpecial[iType].g_iElectricAbility, g_esElectricAbility[iType].g_iElectricAbility, 1);
		g_esElectricCache[tank].g_iElectricCooldown = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricCooldown, g_esElectricPlayer[tank].g_iElectricCooldown, g_esElectricSpecial[iType].g_iElectricCooldown, g_esElectricAbility[iType].g_iElectricCooldown, 1);
		g_esElectricCache[tank].g_iElectricEffect = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricEffect, g_esElectricPlayer[tank].g_iElectricEffect, g_esElectricSpecial[iType].g_iElectricEffect, g_esElectricAbility[iType].g_iElectricEffect, 1);
		g_esElectricCache[tank].g_iElectricHit = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricHit, g_esElectricPlayer[tank].g_iElectricHit, g_esElectricSpecial[iType].g_iElectricHit, g_esElectricAbility[iType].g_iElectricHit, 1);
		g_esElectricCache[tank].g_iElectricHitMode = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricHitMode, g_esElectricPlayer[tank].g_iElectricHitMode, g_esElectricSpecial[iType].g_iElectricHitMode, g_esElectricAbility[iType].g_iElectricHitMode, 1);
		g_esElectricCache[tank].g_iElectricMessage = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricMessage, g_esElectricPlayer[tank].g_iElectricMessage, g_esElectricSpecial[iType].g_iElectricMessage, g_esElectricAbility[iType].g_iElectricMessage, 1);
		g_esElectricCache[tank].g_iElectricRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricRangeCooldown, g_esElectricPlayer[tank].g_iElectricRangeCooldown, g_esElectricSpecial[iType].g_iElectricRangeCooldown, g_esElectricAbility[iType].g_iElectricRangeCooldown, 1);
		g_esElectricCache[tank].g_iElectricSight = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iElectricSight, g_esElectricPlayer[tank].g_iElectricSight, g_esElectricSpecial[iType].g_iElectricSight, g_esElectricAbility[iType].g_iElectricSight, 1);
		g_esElectricCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iHumanAbility, g_esElectricPlayer[tank].g_iHumanAbility, g_esElectricSpecial[iType].g_iHumanAbility, g_esElectricAbility[iType].g_iHumanAbility, 1);
		g_esElectricCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iHumanAmmo, g_esElectricPlayer[tank].g_iHumanAmmo, g_esElectricSpecial[iType].g_iHumanAmmo, g_esElectricAbility[iType].g_iHumanAmmo, 1);
		g_esElectricCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iHumanCooldown, g_esElectricPlayer[tank].g_iHumanCooldown, g_esElectricSpecial[iType].g_iHumanCooldown, g_esElectricAbility[iType].g_iHumanCooldown, 1);
		g_esElectricCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iHumanRangeCooldown, g_esElectricPlayer[tank].g_iHumanRangeCooldown, g_esElectricSpecial[iType].g_iHumanRangeCooldown, g_esElectricAbility[iType].g_iHumanRangeCooldown, 1);
		g_esElectricCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_flOpenAreasOnly, g_esElectricPlayer[tank].g_flOpenAreasOnly, g_esElectricSpecial[iType].g_flOpenAreasOnly, g_esElectricAbility[iType].g_flOpenAreasOnly, 1);
		g_esElectricCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esElectricTeammate[tank].g_iRequiresHumans, g_esElectricPlayer[tank].g_iRequiresHumans, g_esElectricSpecial[iType].g_iRequiresHumans, g_esElectricAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esElectricCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flCloseAreasOnly, g_esElectricAbility[iType].g_flCloseAreasOnly, 1);
		g_esElectricCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iComboAbility, g_esElectricAbility[iType].g_iComboAbility, 1);
		g_esElectricCache[tank].g_flElectricChance = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flElectricChance, g_esElectricAbility[iType].g_flElectricChance, 1);
		g_esElectricCache[tank].g_flElectricDamage = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flElectricDamage, g_esElectricAbility[iType].g_flElectricDamage, 1);
		g_esElectricCache[tank].g_iElectricDuration = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricDuration, g_esElectricAbility[iType].g_iElectricDuration, 1);
		g_esElectricCache[tank].g_flElectricInterval = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flElectricInterval, g_esElectricAbility[iType].g_flElectricInterval, 1);
		g_esElectricCache[tank].g_flElectricRange = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flElectricRange, g_esElectricAbility[iType].g_flElectricRange, 1);
		g_esElectricCache[tank].g_flElectricRangeChance = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flElectricRangeChance, g_esElectricAbility[iType].g_flElectricRangeChance, 1);
		g_esElectricCache[tank].g_flElectricStunSpeed = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flElectricStunSpeed, g_esElectricAbility[iType].g_flElectricStunSpeed, 1);
		g_esElectricCache[tank].g_iElectricAbility = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricAbility, g_esElectricAbility[iType].g_iElectricAbility, 1);
		g_esElectricCache[tank].g_iElectricCooldown = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricCooldown, g_esElectricAbility[iType].g_iElectricCooldown, 1);
		g_esElectricCache[tank].g_iElectricEffect = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricEffect, g_esElectricAbility[iType].g_iElectricEffect, 1);
		g_esElectricCache[tank].g_iElectricHit = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricHit, g_esElectricAbility[iType].g_iElectricHit, 1);
		g_esElectricCache[tank].g_iElectricHitMode = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricHitMode, g_esElectricAbility[iType].g_iElectricHitMode, 1);
		g_esElectricCache[tank].g_iElectricMessage = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricMessage, g_esElectricAbility[iType].g_iElectricMessage, 1);
		g_esElectricCache[tank].g_iElectricRangeCooldown = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricRangeCooldown, g_esElectricAbility[iType].g_iElectricRangeCooldown, 1);
		g_esElectricCache[tank].g_iElectricSight = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iElectricSight, g_esElectricAbility[iType].g_iElectricSight, 1);
		g_esElectricCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iHumanAbility, g_esElectricAbility[iType].g_iHumanAbility, 1);
		g_esElectricCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iHumanAmmo, g_esElectricAbility[iType].g_iHumanAmmo, 1);
		g_esElectricCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iHumanCooldown, g_esElectricAbility[iType].g_iHumanCooldown, 1);
		g_esElectricCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iHumanRangeCooldown, g_esElectricAbility[iType].g_iHumanRangeCooldown, 1);
		g_esElectricCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_flOpenAreasOnly, g_esElectricAbility[iType].g_flOpenAreasOnly, 1);
		g_esElectricCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esElectricPlayer[tank].g_iRequiresHumans, g_esElectricAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vElectricCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveElectric(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vElectricEventFired(Event event, const char[] name)
#else
public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
#endif
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsInfected(iTank))
		{
			vElectricCopyStats2(iBot, iTank);
			vRemoveElectric(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vElectricReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vElectricCopyStats2(iTank, iBot);
			vRemoveElectric(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vElectricRange(iTank);
			vRemoveElectric(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vElectricHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esElectricCache[iBoomer].g_flElectricChance, g_esElectricCache[iBoomer].g_iElectricHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esElectricAbility[g_esElectricPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[tank].g_iAccessFlags)) || g_esElectricCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esElectricCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esElectricCache[tank].g_iElectricAbility == 1 && g_esElectricCache[tank].g_iComboAbility == 0)
	{
		vElectricAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esElectricCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esElectricCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esElectricPlayer[tank].g_iTankType, tank) || (g_esElectricCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esElectricCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esElectricAbility[g_esElectricPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esElectricCache[tank].g_iElectricAbility == 1 && g_esElectricCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esElectricPlayer[tank].g_iRangeCooldown == -1 || g_esElectricPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vElectricAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman3", (g_esElectricPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vElectricChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveElectric(tank);
}

#if defined MT_ABILITIES_MAIN
void vElectricPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vElectricRange(tank);
}

void vElectric(int survivor, int tank, bool main, int pos = -1)
{
	vAttachParticle(survivor, PARTICLE_ELECTRICITY, 2.0, 30.0);
	EmitSoundToAll(g_sElectricSounds[MT_GetRandomInt(0, (sizeof g_sElectricSounds - 1))], survivor);

	float flDamage = (pos != -1) ? MT_GetCombinationSetting(tank, 3, pos) : g_esElectricCache[tank].g_flElectricDamage;
	if (flDamage > 0.0)
	{
		vDamagePlayer(survivor, tank, MT_GetScaledDamage(flDamage), "1024");

		float flSpeed = (pos != -1) ? MT_GetCombinationSetting(tank, 16, pos) : g_esElectricCache[tank].g_flElectricStunSpeed;
		if (main && flSpeed > 0.0)
		{
			SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(survivor, flSpeed) : flSpeed));
		}
	}
}

void vElectricAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esElectricCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esElectricCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esElectricPlayer[tank].g_iTankType, tank) || (g_esElectricCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esElectricCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esElectricAbility[g_esElectricPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esElectricPlayer[tank].g_iAmmoCount < g_esElectricCache[tank].g_iHumanAmmo && g_esElectricCache[tank].g_iHumanAmmo > 0))
	{
		g_esElectricPlayer[tank].g_bFailed = false;
		g_esElectricPlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esElectricCache[tank].g_flElectricRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esElectricCache[tank].g_flElectricRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esElectricPlayer[tank].g_iTankType, g_esElectricAbility[g_esElectricPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esElectricPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esElectricCache[tank].g_iElectricSight, .range = flRange))
				{
					vElectricHit(iSurvivor, tank, random, flChance, g_esElectricCache[tank].g_iElectricAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricAmmo");
	}
}

void vElectricHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esElectricCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esElectricCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esElectricPlayer[tank].g_iTankType, tank) || (g_esElectricCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esElectricCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esElectricAbility[g_esElectricPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esElectricPlayer[tank].g_iTankType, g_esElectricAbility[g_esElectricPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esElectricPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esElectricPlayer[tank].g_iRangeCooldown != -1 && g_esElectricPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esElectricPlayer[tank].g_iCooldown != -1 && g_esElectricPlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esElectricPlayer[tank].g_iAmmoCount < g_esElectricCache[tank].g_iHumanAmmo && g_esElectricCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance && !g_esElectricPlayer[survivor].g_bAffected)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esElectricCache[tank].g_iElectricSight, .range = 100.0))
				{
					return;
				}

				g_esElectricPlayer[survivor].g_bAffected = true;
				g_esElectricPlayer[survivor].g_iOwner = tank;

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esElectricPlayer[tank].g_iRangeCooldown == -1 || g_esElectricPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility == 1)
					{
						g_esElectricPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman", g_esElectricPlayer[tank].g_iAmmoCount, g_esElectricCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esElectricCache[tank].g_iElectricRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility == 1 && g_esElectricPlayer[tank].g_iAmmoCount < g_esElectricCache[tank].g_iHumanAmmo && g_esElectricCache[tank].g_iHumanAmmo > 0) ? g_esElectricCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esElectricPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esElectricPlayer[tank].g_iRangeCooldown != -1 && g_esElectricPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman5", (g_esElectricPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esElectricPlayer[tank].g_iCooldown == -1 || g_esElectricPlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esElectricCache[tank].g_iElectricCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility == 1) ? g_esElectricCache[tank].g_iHumanCooldown : iCooldown;
					g_esElectricPlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esElectricPlayer[tank].g_iCooldown != -1 && g_esElectricPlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman5", (g_esElectricPlayer[tank].g_iCooldown - iTime));
					}
				}

				float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esElectricCache[tank].g_flElectricInterval;
				if (flInterval > 0.0)
				{
					DataPack dpElectric;
					CreateDataTimer(flInterval, tTimerElectric, dpElectric, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					dpElectric.WriteCell(GetClientUserId(survivor));
					dpElectric.WriteCell(GetClientUserId(tank));
					dpElectric.WriteCell(g_esElectricPlayer[tank].g_iTankType);
					dpElectric.WriteCell(messages);
					dpElectric.WriteCell(enabled);
					dpElectric.WriteCell(pos);
					dpElectric.WriteCell(iTime);
				}

				vAttachParticle(survivor, PARTICLE_ELECTRICITY2, 2.0, 30.0);
				vScreenEffect(survivor, tank, g_esElectricCache[tank].g_iElectricEffect, flags);

				if (g_esElectricCache[tank].g_iElectricMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Electric", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Electric", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esElectricPlayer[tank].g_iRangeCooldown == -1 || g_esElectricPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility == 1 && !g_esElectricPlayer[tank].g_bFailed)
				{
					g_esElectricPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esElectricCache[tank].g_iHumanAbility == 1 && !g_esElectricPlayer[tank].g_bNoAmmo)
		{
			g_esElectricPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "ElectricAmmo");
		}
	}
}

void vElectricRange(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(tank) && g_esElectricCache[tank].g_iElectricAbility == 1)
	{
		if (bIsAreaNarrow(tank, g_esElectricCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esElectricCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esElectricPlayer[tank].g_iTankType, tank) || (g_esElectricCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esElectricCache[tank].g_iRequiresHumans) || (bIsInfected(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esElectricAbility[g_esElectricPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[tank].g_iAccessFlags)) || g_esElectricCache[tank].g_iHumanAbility == 0)))
		{
			return;
		}

		vAttachParticle(tank, PARTICLE_ELECTRICITY2, 2.0, 30.0);
	}
}

void vElectricCopyStats2(int oldTank, int newTank)
{
	g_esElectricPlayer[newTank].g_iAmmoCount = g_esElectricPlayer[oldTank].g_iAmmoCount;
	g_esElectricPlayer[newTank].g_iCooldown = g_esElectricPlayer[oldTank].g_iCooldown;
	g_esElectricPlayer[newTank].g_iRangeCooldown = g_esElectricPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveElectric(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esElectricPlayer[iSurvivor].g_bAffected && g_esElectricPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esElectricPlayer[iSurvivor].g_bAffected = false;
			g_esElectricPlayer[iSurvivor].g_iOwner = -1;
		}
	}

	vElectricReset3(tank);
}

void vElectricReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vElectricReset3(iPlayer);

			g_esElectricPlayer[iPlayer].g_iOwner = -1;
		}
	}
}

void vElectricReset2(int survivor, int tank, int messages)
{
	g_esElectricPlayer[survivor].g_bAffected = false;
	g_esElectricPlayer[survivor].g_iOwner = -1;

	SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", (g_bLaggedMovementInstalled ? L4D_LaggedMovement(survivor, 1.0, true) : 1.0));

	if (g_esElectricCache[tank].g_iElectricMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Electric2", survivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Electric2", LANG_SERVER, survivor);
	}
}

void vElectricReset3(int tank)
{
	g_esElectricPlayer[tank].g_bAffected = false;
	g_esElectricPlayer[tank].g_bFailed = false;
	g_esElectricPlayer[tank].g_bNoAmmo = false;
	g_esElectricPlayer[tank].g_iAmmoCount = 0;
	g_esElectricPlayer[tank].g_iCooldown = -1;
	g_esElectricPlayer[tank].g_iRangeCooldown = -1;
}

void tTimerElectricCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esElectricAbility[g_esElectricPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esElectricPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esElectricCache[iTank].g_iElectricAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vElectricAbility(iTank, flRandom, iPos);
}

void tTimerElectricCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esElectricPlayer[iSurvivor].g_bAffected)
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esElectricAbility[g_esElectricPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esElectricPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esElectricCache[iTank].g_iElectricHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esElectricCache[iTank].g_iElectricHitMode == 0 || g_esElectricCache[iTank].g_iElectricHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vElectricHit(iSurvivor, iTank, flRandom, flChance, g_esElectricCache[iTank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esElectricCache[iTank].g_iElectricHitMode == 0 || g_esElectricCache[iTank].g_iElectricHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vElectricHit(iSurvivor, iTank, flRandom, flChance, g_esElectricCache[iTank].g_iElectricHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}

Action tTimerElectric(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esElectricPlayer[iSurvivor].g_bAffected = false;
		g_esElectricPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esElectricCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esElectricCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esElectricPlayer[iTank].g_iTankType, iTank) || (g_esElectricCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esElectricCache[iTank].g_iRequiresHumans) || !MT_HasAdminAccess(iTank) || !bHasAdminAccess(iTank, g_esElectricAbility[g_esElectricPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esElectricPlayer[iTank].g_iAccessFlags) || !MT_IsTypeEnabled(g_esElectricPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esElectricPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esElectricPlayer[iTank].g_iTankType, g_esElectricAbility[g_esElectricPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esElectricPlayer[iSurvivor].g_iImmunityFlags) || !g_esElectricPlayer[iSurvivor].g_bAffected)
	{
		vElectricReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iElectricEnabled = pack.ReadCell(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esElectricCache[iTank].g_iElectricDuration,
		iTime = pack.ReadCell();
	if (iElectricEnabled == 0 || (iTime + iDuration) <= GetTime())
	{
		vElectricReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	if (!bIsVisibleToPlayer(iSurvivor, iTank, g_esElectricCache[iTank].g_iElectricSight))
	{
		return Plugin_Continue;
	}

	vElectric(iSurvivor, iTank, true, iPos);

	float flSurvivorPos[3], flPlayerPos[3];
	GetClientAbsOrigin(iSurvivor, flSurvivorPos);
	float flRange = (iPos != -1) ? MT_GetCombinationSetting(iTank, 9, iPos) : g_esElectricCache[iTank].g_flElectricRange;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSurvivor(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iPlayer, iTank) && !bIsAdminImmune(iPlayer, g_esElectricPlayer[iTank].g_iTankType, g_esElectricAbility[g_esElectricPlayer[iTank].g_iTankTypeRecorded].g_iImmunityFlags, g_esElectricPlayer[iPlayer].g_iImmunityFlags) && !g_esElectricPlayer[iPlayer].g_bAffected)
		{
			GetClientAbsOrigin(iPlayer, flPlayerPos);
			if (GetVectorDistance(flSurvivorPos, flPlayerPos) <= (flRange / 2.0) && bIsVisibleToPlayer(iSurvivor, iPlayer, 1, .range = (flRange / 2.0)))
			{
				vElectric(iPlayer, iTank, false, iPos);
			}
		}
	}

	return Plugin_Continue;
}