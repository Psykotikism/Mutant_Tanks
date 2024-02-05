/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2024  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_HYPNO_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_HYPNO_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Hypno Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank hypnotizes survivors to damage themselves or their teammates.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Hypno Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"

#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"
#else
	#if MT_HYPNO_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_HYPNO_SECTION "hypnoability"
#define MT_HYPNO_SECTION2 "hypno ability"
#define MT_HYPNO_SECTION3 "hypno_ability"
#define MT_HYPNO_SECTION4 "hypno"

#define MT_MENU_HYPNO "Hypno Ability"

enum struct esHypnoPlayer
{
	bool g_bActivated;
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;
	bool g_bRainbowColor;

	char g_sHypnoColor[16];

	float g_flCloseAreasOnly;
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoHittableDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHypnoAbility;
	int g_iHypnoColor[4];
	int g_iHypnoCooldown;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iHypnoRangeCooldown;
	int g_iHypnoSight;
	int g_iHypnoView;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iShield;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esHypnoPlayer g_esHypnoPlayer[MAXPLAYERS + 1];

enum struct esHypnoTeammate
{
	char g_sHypnoColor[16];

	float g_flCloseAreasOnly;
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoHittableDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHypnoAbility;
	int g_iHypnoColor[4];
	int g_iHypnoCooldown;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iHypnoRangeCooldown;
	int g_iHypnoSight;
	int g_iHypnoView;
	int g_iRequiresHumans;
}

esHypnoTeammate g_esHypnoTeammate[MAXPLAYERS + 1];

enum struct esHypnoAbility
{
	char g_sHypnoColor[16];

	float g_flCloseAreasOnly;
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoHittableDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHypnoAbility;
	int g_iHypnoColor[4];
	int g_iHypnoCooldown;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iHypnoRangeCooldown;
	int g_iHypnoSight;
	int g_iHypnoView;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esHypnoAbility g_esHypnoAbility[MT_MAXTYPES + 1];

enum struct esHypnoSpecial
{
	char g_sHypnoColor[16];

	float g_flCloseAreasOnly;
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoHittableDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHypnoAbility;
	int g_iHypnoColor[4];
	int g_iHypnoCooldown;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iHypnoRangeCooldown;
	int g_iHypnoSight;
	int g_iHypnoView;
	int g_iRequiresHumans;
}

esHypnoSpecial g_esHypnoSpecial[MT_MAXTYPES + 1];

enum struct esHypnoCache
{
	char g_sHypnoColor[16];

	float g_flCloseAreasOnly;
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoHittableDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHypnoAbility;
	int g_iHypnoColor[4];
	int g_iHypnoCooldown;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iHypnoRangeCooldown;
	int g_iHypnoSight;
	int g_iHypnoView;
	int g_iRequiresHumans;
}

esHypnoCache g_esHypnoCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_hypno", cmdHypnoInfo, "View information about the Hypno ability.");

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
void vHypnoMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheModel(MODEL_SHIELD, true);

	vHypnoReset();
}

#if defined MT_ABILITIES_MAIN
void vHypnoClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnHypnoTakeDamage);
	vHypnoReset2(client);
}

#if defined MT_ABILITIES_MAIN
void vHypnoClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vHypnoReset2(client);
}

#if defined MT_ABILITIES_MAIN
void vHypnoMapEnd()
#else
public void OnMapEnd()
#endif
{
	vHypnoReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdHypnoInfo(int client, int args)
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
		case false: vHypnoMenu(client, MT_HYPNO_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vHypnoMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_HYPNO_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iHypnoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hypno Ability Information");
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

int iHypnoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esHypnoCache[param1].g_iHypnoAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esHypnoCache[param1].g_iHumanAmmo - g_esHypnoPlayer[param1].g_iAmmoCount), g_esHypnoCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esHypnoCache[param1].g_iHumanAbility == 1) ? g_esHypnoCache[param1].g_iHumanCooldown : g_esHypnoCache[param1].g_iHypnoCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HypnoDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esHypnoCache[param1].g_flHypnoDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esHypnoCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esHypnoCache[param1].g_iHumanAbility == 1) ? g_esHypnoCache[param1].g_iHumanRangeCooldown : g_esHypnoCache[param1].g_iHypnoRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vHypnoMenu(param1, MT_HYPNO_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pHypno = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "HypnoMenu", param1);
			pHypno.SetTitle(sMenuTitle);
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
void vHypnoDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_HYPNO, MT_MENU_HYPNO);
}

#if defined MT_ABILITIES_MAIN
void vHypnoMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_HYPNO, false))
	{
		vHypnoMenu(client, MT_HYPNO_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_HYPNO, false))
	{
		FormatEx(buffer, size, "%T", "HypnoMenu2", client);
	}
}

Action OnHypnoTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esHypnoCache[attacker].g_iHypnoHitMode == 0 || g_esHypnoCache[attacker].g_iHypnoHitMode == 1) && bIsSurvivor(victim) && g_esHypnoCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esHypnoAbility[g_esHypnoPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esHypnoPlayer[attacker].g_iTankType, g_esHypnoAbility[g_esHypnoPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esHypnoPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHypnoHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esHypnoCache[attacker].g_flHypnoChance, g_esHypnoCache[attacker].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && bIsSurvivor(attacker))
		{
			if ((g_esHypnoCache[victim].g_iHypnoHitMode == 0 || g_esHypnoCache[victim].g_iHypnoHitMode == 2) && StrEqual(sClassname[7], "melee") && g_esHypnoCache[victim].g_iComboAbility == 0)
			{
				if ((MT_HasAdminAccess(victim) || bHasAdminAccess(victim, g_esHypnoAbility[g_esHypnoPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[victim].g_iAccessFlags)) && !MT_IsAdminImmune(attacker, victim) && !bIsAdminImmune(attacker, g_esHypnoPlayer[victim].g_iTankType, g_esHypnoAbility[g_esHypnoPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esHypnoPlayer[attacker].g_iImmunityFlags))
				{
					vHypnoHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esHypnoCache[victim].g_flHypnoChance, g_esHypnoCache[victim].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
				}
			}

			if (!bIsPlayerIncapacitated(victim) && g_esHypnoPlayer[attacker].g_bAffected && g_esHypnoPlayer[attacker].g_iOwner == victim)
			{
				bool bChanged = false;
				if (g_esHypnoCache[victim].g_flHypnoBulletDivisor > 1.0 && (damagetype & DMG_BULLET))
				{
					bChanged = true;
					damage /= g_esHypnoCache[victim].g_flHypnoBulletDivisor;
				}
				else if (g_esHypnoCache[victim].g_flHypnoExplosiveDivisor > 1.0 && ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA)))
				{
					bChanged = true;
					damage /= g_esHypnoCache[victim].g_flHypnoExplosiveDivisor;
				}
				else if (g_esHypnoCache[victim].g_flHypnoFireDivisor > 1.0 && ((damagetype & DMG_BURN) || (damagetype & DMG_DIRECT)))
				{
					bChanged = true;
					damage /= g_esHypnoCache[victim].g_flHypnoFireDivisor;
				}
				else if (g_esHypnoCache[victim].g_flHypnoHittableDivisor > 1.0 && (damagetype & DMG_CRUSH) && bIsValidEntity(inflictor) && HasEntProp(inflictor, Prop_Send, "m_isCarryable"))
				{
					bChanged = true;
					damage /= g_esHypnoCache[victim].g_flHypnoHittableDivisor;
				}
				else if (g_esHypnoCache[victim].g_flHypnoMeleeDivisor > 1.0 && ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB)))
				{
					bChanged = true;
					damage /= g_esHypnoCache[victim].g_flHypnoMeleeDivisor;

					float flTankPos[3];
					GetClientAbsOrigin(victim, flTankPos);

					switch (MT_DoesSurvivorHaveRewardType(attacker, MT_REWARD_GODMODE))
					{
						case true: vPushNearbyEntities(victim, flTankPos, 300.0, 100.0);
						case false: vPushNearbyEntities(victim, flTankPos);
					}
				}

				if (bChanged)
				{
					if (damage < 1.0)
					{
						damage = 1.0;
					}

					int iTarget = (g_esHypnoCache[victim].g_iHypnoMode == 1) ? iGetRandomSurvivor(victim) : attacker;
					if (iTarget > 0)
					{
						char sDamageType[32];
						IntToString(damagetype, sDamageType, sizeof sDamageType);
						vDamagePlayer(iTarget, victim, damage, sDamageType);
						EmitSoundToAll(SOUND_METAL, victim);
					}
				}

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vHypnoPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_HYPNO);
}

#if defined MT_ABILITIES_MAIN
void vHypnoAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_HYPNO_SECTION);
	list2.PushString(MT_HYPNO_SECTION2);
	list3.PushString(MT_HYPNO_SECTION3);
	list4.PushString(MT_HYPNO_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vHypnoCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_HYPNO_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_HYPNO_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_HYPNO_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_HYPNO_SECTION4);
	if (g_esHypnoCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_HYPNO_SECTION, false) || StrEqual(sSubset[iPos], MT_HYPNO_SECTION2, false) || StrEqual(sSubset[iPos], MT_HYPNO_SECTION3, false) || StrEqual(sSubset[iPos], MT_HYPNO_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esHypnoCache[tank].g_iHypnoAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vHypnoAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerHypnoCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esHypnoCache[tank].g_iHypnoHitMode == 0 || g_esHypnoCache[tank].g_iHypnoHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vHypnoHit(survivor, tank, random, flChance, g_esHypnoCache[tank].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esHypnoCache[tank].g_iHypnoHitMode == 0 || g_esHypnoCache[tank].g_iHypnoHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vHypnoHit(survivor, tank, random, flChance, g_esHypnoCache[tank].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerHypnoCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
void vHypnoConfigsLoad(int mode)
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
				g_esHypnoAbility[iIndex].g_sHypnoColor = "255,255,255,255";
				g_esHypnoAbility[iIndex].g_iAccessFlags = 0;
				g_esHypnoAbility[iIndex].g_iImmunityFlags = 0;
				g_esHypnoAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esHypnoAbility[iIndex].g_iComboAbility = 0;
				g_esHypnoAbility[iIndex].g_iHumanAbility = 0;
				g_esHypnoAbility[iIndex].g_iHumanAmmo = 5;
				g_esHypnoAbility[iIndex].g_iHumanCooldown = 0;
				g_esHypnoAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esHypnoAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esHypnoAbility[iIndex].g_iRequiresHumans = 0;
				g_esHypnoAbility[iIndex].g_iHypnoAbility = 0;
				g_esHypnoAbility[iIndex].g_iHypnoEffect = 0;
				g_esHypnoAbility[iIndex].g_iHypnoMessage = 0;
				g_esHypnoAbility[iIndex].g_flHypnoBulletDivisor = 20.0;
				g_esHypnoAbility[iIndex].g_flHypnoChance = 33.3;
				g_esHypnoAbility[iIndex].g_iHypnoCooldown = 0;
				g_esHypnoAbility[iIndex].g_flHypnoDuration = 5.0;
				g_esHypnoAbility[iIndex].g_flHypnoExplosiveDivisor = 20.0;
				g_esHypnoAbility[iIndex].g_flHypnoFireDivisor = 200.0;
				g_esHypnoAbility[iIndex].g_iHypnoHit = 0;
				g_esHypnoAbility[iIndex].g_iHypnoHitMode = 0;
				g_esHypnoAbility[iIndex].g_flHypnoHittableDivisor = 20.0;
				g_esHypnoAbility[iIndex].g_flHypnoMeleeDivisor = 200.0;
				g_esHypnoAbility[iIndex].g_iHypnoMode = 0;
				g_esHypnoAbility[iIndex].g_flHypnoRange = 150.0;
				g_esHypnoAbility[iIndex].g_flHypnoRangeChance = 15.0;
				g_esHypnoAbility[iIndex].g_iHypnoRangeCooldown = 0;
				g_esHypnoAbility[iIndex].g_iHypnoSight = 0;
				g_esHypnoAbility[iIndex].g_iHypnoView = 0;

				for (int iPos = 0; iPos < (sizeof esHypnoAbility::g_iHypnoColor); iPos++)
				{
					g_esHypnoAbility[iIndex].g_iHypnoColor[iPos] = 255;
				}

				g_esHypnoSpecial[iIndex].g_sHypnoColor[0] = '\0';
				g_esHypnoSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esHypnoSpecial[iIndex].g_iComboAbility = -1;
				g_esHypnoSpecial[iIndex].g_iHumanAbility = -1;
				g_esHypnoSpecial[iIndex].g_iHumanAmmo = -1;
				g_esHypnoSpecial[iIndex].g_iHumanCooldown = -1;
				g_esHypnoSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esHypnoSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esHypnoSpecial[iIndex].g_iRequiresHumans = -1;
				g_esHypnoSpecial[iIndex].g_iHypnoAbility = -1;
				g_esHypnoSpecial[iIndex].g_iHypnoEffect = -1;
				g_esHypnoSpecial[iIndex].g_iHypnoMessage = -1;
				g_esHypnoSpecial[iIndex].g_flHypnoBulletDivisor = -1.0;
				g_esHypnoSpecial[iIndex].g_flHypnoChance = -1.0;
				g_esHypnoSpecial[iIndex].g_iHypnoCooldown = -1;
				g_esHypnoSpecial[iIndex].g_flHypnoDuration = -1.0;
				g_esHypnoSpecial[iIndex].g_flHypnoExplosiveDivisor = -1.0;
				g_esHypnoSpecial[iIndex].g_flHypnoFireDivisor = -1.0;
				g_esHypnoSpecial[iIndex].g_iHypnoHit = -1;
				g_esHypnoSpecial[iIndex].g_iHypnoHitMode = -1;
				g_esHypnoSpecial[iIndex].g_flHypnoHittableDivisor = -1.0;
				g_esHypnoSpecial[iIndex].g_flHypnoMeleeDivisor = -1.0;
				g_esHypnoSpecial[iIndex].g_iHypnoMode = -1;
				g_esHypnoSpecial[iIndex].g_flHypnoRange = -1.0;
				g_esHypnoSpecial[iIndex].g_flHypnoRangeChance = -1.0;
				g_esHypnoSpecial[iIndex].g_iHypnoRangeCooldown = -1;
				g_esHypnoSpecial[iIndex].g_iHypnoSight = -1;
				g_esHypnoSpecial[iIndex].g_iHypnoView = -1;

				for (int iPos = 0; iPos < (sizeof esHypnoSpecial::g_iHypnoColor); iPos++)
				{
					g_esHypnoSpecial[iIndex].g_iHypnoColor[iPos] = -1;
				}
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esHypnoPlayer[iPlayer].g_sHypnoColor[0] = '\0';
				g_esHypnoPlayer[iPlayer].g_iAccessFlags = -1;
				g_esHypnoPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esHypnoPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esHypnoPlayer[iPlayer].g_iComboAbility = -1;
				g_esHypnoPlayer[iPlayer].g_iHumanAbility = -1;
				g_esHypnoPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esHypnoPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esHypnoPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esHypnoPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esHypnoPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esHypnoPlayer[iPlayer].g_iHypnoAbility = -1;
				g_esHypnoPlayer[iPlayer].g_iHypnoEffect = -1;
				g_esHypnoPlayer[iPlayer].g_iHypnoMessage = -1;
				g_esHypnoPlayer[iPlayer].g_flHypnoBulletDivisor = -1.0;
				g_esHypnoPlayer[iPlayer].g_flHypnoChance = -1.0;
				g_esHypnoPlayer[iPlayer].g_iHypnoCooldown = -1;
				g_esHypnoPlayer[iPlayer].g_flHypnoDuration = -1.0;
				g_esHypnoPlayer[iPlayer].g_flHypnoExplosiveDivisor = -1.0;
				g_esHypnoPlayer[iPlayer].g_flHypnoFireDivisor = -1.0;
				g_esHypnoPlayer[iPlayer].g_iHypnoHit = -1;
				g_esHypnoPlayer[iPlayer].g_iHypnoHitMode = -1;
				g_esHypnoPlayer[iPlayer].g_flHypnoHittableDivisor = -1.0;
				g_esHypnoPlayer[iPlayer].g_flHypnoMeleeDivisor = -1.0;
				g_esHypnoPlayer[iPlayer].g_iHypnoMode = -1;
				g_esHypnoPlayer[iPlayer].g_flHypnoRange = -1.0;
				g_esHypnoPlayer[iPlayer].g_flHypnoRangeChance = -1.0;
				g_esHypnoPlayer[iPlayer].g_iHypnoRangeCooldown = -1;
				g_esHypnoPlayer[iPlayer].g_iHypnoSight = -1;
				g_esHypnoPlayer[iPlayer].g_iHypnoView = -1;

				for (int iPos = 0; iPos < (sizeof esHypnoPlayer::g_iHypnoColor); iPos++)
				{
					g_esHypnoPlayer[iPlayer].g_iHypnoColor[iPos] = -1;
				}

				g_esHypnoTeammate[iPlayer].g_sHypnoColor[0] = '\0';
				g_esHypnoTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esHypnoTeammate[iPlayer].g_iComboAbility = -1;
				g_esHypnoTeammate[iPlayer].g_iHumanAbility = -1;
				g_esHypnoTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esHypnoTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esHypnoTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esHypnoTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esHypnoTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esHypnoTeammate[iPlayer].g_iHypnoAbility = -1;
				g_esHypnoTeammate[iPlayer].g_iHypnoEffect = -1;
				g_esHypnoTeammate[iPlayer].g_iHypnoMessage = -1;
				g_esHypnoTeammate[iPlayer].g_flHypnoBulletDivisor = -1.0;
				g_esHypnoTeammate[iPlayer].g_flHypnoChance = -1.0;
				g_esHypnoTeammate[iPlayer].g_iHypnoCooldown = -1;
				g_esHypnoTeammate[iPlayer].g_flHypnoDuration = -1.0;
				g_esHypnoTeammate[iPlayer].g_flHypnoExplosiveDivisor = -1.0;
				g_esHypnoTeammate[iPlayer].g_flHypnoFireDivisor = -1.0;
				g_esHypnoTeammate[iPlayer].g_iHypnoHit = -1;
				g_esHypnoTeammate[iPlayer].g_iHypnoHitMode = -1;
				g_esHypnoTeammate[iPlayer].g_flHypnoHittableDivisor = -1.0;
				g_esHypnoTeammate[iPlayer].g_flHypnoMeleeDivisor = -1.0;
				g_esHypnoTeammate[iPlayer].g_iHypnoMode = -1;
				g_esHypnoTeammate[iPlayer].g_flHypnoRange = -1.0;
				g_esHypnoTeammate[iPlayer].g_flHypnoRangeChance = -1.0;
				g_esHypnoTeammate[iPlayer].g_iHypnoRangeCooldown = -1;
				g_esHypnoTeammate[iPlayer].g_iHypnoSight = -1;
				g_esHypnoTeammate[iPlayer].g_iHypnoView = -1;

				for (int iPos = 0; iPos < (sizeof esHypnoTeammate::g_iHypnoColor); iPos++)
				{
					g_esHypnoTeammate[iPlayer].g_iHypnoColor[iPos] = -1;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esHypnoTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHypnoTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHypnoTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esHypnoTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHypnoTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esHypnoTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHypnoTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esHypnoTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHypnoTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esHypnoTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHypnoTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHypnoTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHypnoTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHypnoTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esHypnoTeammate[admin].g_iHypnoAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHypnoTeammate[admin].g_iHypnoAbility, value, -1, 1);
			g_esHypnoTeammate[admin].g_iHypnoEffect = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHypnoTeammate[admin].g_iHypnoEffect, value, -1, 7);
			g_esHypnoTeammate[admin].g_iHypnoMessage = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHypnoTeammate[admin].g_iHypnoMessage, value, -1, 3);
			g_esHypnoTeammate[admin].g_iHypnoSight = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHypnoTeammate[admin].g_iHypnoSight, value, -1, 5);
			g_esHypnoTeammate[admin].g_flHypnoBulletDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_esHypnoTeammate[admin].g_flHypnoBulletDivisor, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_flHypnoChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_esHypnoTeammate[admin].g_flHypnoChance, value, -1.0, 100.0);
			g_esHypnoTeammate[admin].g_iHypnoCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoCooldown", "Hypno Cooldown", "Hypno_Cooldown", "cooldown", g_esHypnoTeammate[admin].g_iHypnoCooldown, value, -1, 99999);
			g_esHypnoTeammate[admin].g_flHypnoDuration = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_esHypnoTeammate[admin].g_flHypnoDuration, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_flHypnoExplosiveDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_esHypnoTeammate[admin].g_flHypnoExplosiveDivisor, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_flHypnoFireDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_esHypnoTeammate[admin].g_flHypnoFireDivisor, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_iHypnoHit = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_esHypnoTeammate[admin].g_iHypnoHit, value, -1, 1);
			g_esHypnoTeammate[admin].g_iHypnoHitMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_esHypnoTeammate[admin].g_iHypnoHitMode, value, -1, 2);
			g_esHypnoTeammate[admin].g_flHypnoHittableDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHittableDivisor", "Hypno Hittable Divisor", "Hypno_Hittable_Divisor", "hittable", g_esHypnoTeammate[admin].g_flHypnoHittableDivisor, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_flHypnoMeleeDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_esHypnoTeammate[admin].g_flHypnoMeleeDivisor, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_iHypnoMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_esHypnoTeammate[admin].g_iHypnoMode, value, -1, 1);
			g_esHypnoTeammate[admin].g_flHypnoRange = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_esHypnoTeammate[admin].g_flHypnoRange, value, -1.0, 99999.0);
			g_esHypnoTeammate[admin].g_flHypnoRangeChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_esHypnoTeammate[admin].g_flHypnoRangeChance, value, -1.0, 100.0);
			g_esHypnoTeammate[admin].g_iHypnoRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeCooldown", "Hypno Range Cooldown", "Hypno_Range_Cooldown", "rangecooldown", g_esHypnoTeammate[admin].g_iHypnoRangeCooldown, value, -1, 99999);
			g_esHypnoTeammate[admin].g_iHypnoView = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoView", "Hypno View", "Hypno_View", "view", g_esHypnoTeammate[admin].g_iHypnoView, value, -1, 1);
		}
		else
		{
			g_esHypnoPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHypnoPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHypnoPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esHypnoPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHypnoPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esHypnoPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHypnoPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esHypnoPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHypnoPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esHypnoPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHypnoPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHypnoPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHypnoPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHypnoPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esHypnoPlayer[admin].g_iHypnoAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHypnoPlayer[admin].g_iHypnoAbility, value, -1, 1);
			g_esHypnoPlayer[admin].g_iHypnoEffect = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHypnoPlayer[admin].g_iHypnoEffect, value, -1, 7);
			g_esHypnoPlayer[admin].g_iHypnoMessage = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHypnoPlayer[admin].g_iHypnoMessage, value, -1, 3);
			g_esHypnoPlayer[admin].g_iHypnoView = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoView", "Hypno View", "Hypno_View", "view", g_esHypnoPlayer[admin].g_iHypnoView, value, -1, 1);
			g_esHypnoPlayer[admin].g_flHypnoBulletDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_esHypnoPlayer[admin].g_flHypnoBulletDivisor, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_flHypnoChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_esHypnoPlayer[admin].g_flHypnoChance, value, -1.0, 100.0);
			g_esHypnoPlayer[admin].g_iHypnoCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoCooldown", "Hypno Cooldown", "Hypno_Cooldown", "cooldown", g_esHypnoPlayer[admin].g_iHypnoCooldown, value, -1, 99999);
			g_esHypnoPlayer[admin].g_flHypnoDuration = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_esHypnoPlayer[admin].g_flHypnoDuration, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_flHypnoExplosiveDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_esHypnoPlayer[admin].g_flHypnoExplosiveDivisor, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_flHypnoFireDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_esHypnoPlayer[admin].g_flHypnoFireDivisor, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_iHypnoHit = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_esHypnoPlayer[admin].g_iHypnoHit, value, -1, 1);
			g_esHypnoPlayer[admin].g_iHypnoHitMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_esHypnoPlayer[admin].g_iHypnoHitMode, value, -1, 2);
			g_esHypnoPlayer[admin].g_flHypnoHittableDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHittableDivisor", "Hypno Hittable Divisor", "Hypno_Hittable_Divisor", "hittable", g_esHypnoPlayer[admin].g_flHypnoHittableDivisor, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_flHypnoMeleeDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_esHypnoPlayer[admin].g_flHypnoMeleeDivisor, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_iHypnoMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_esHypnoPlayer[admin].g_iHypnoMode, value, -1, 1);
			g_esHypnoPlayer[admin].g_flHypnoRange = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_esHypnoPlayer[admin].g_flHypnoRange, value, -1.0, 99999.0);
			g_esHypnoPlayer[admin].g_flHypnoRangeChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_esHypnoPlayer[admin].g_flHypnoRangeChance, value, -1.0, 100.0);
			g_esHypnoPlayer[admin].g_iHypnoRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeCooldown", "Hypno Range Cooldown", "Hypno_Range_Cooldown", "rangecooldown", g_esHypnoPlayer[admin].g_iHypnoRangeCooldown, value, -1, 99999);
			g_esHypnoPlayer[admin].g_iHypnoSight = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHypnoPlayer[admin].g_iHypnoSight, value, -1, 5);
			g_esHypnoPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esHypnoPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}

		if (StrEqual(subsection, MT_HYPNO_SECTION, false) || StrEqual(subsection, MT_HYPNO_SECTION2, false) || StrEqual(subsection, MT_HYPNO_SECTION3, false) || StrEqual(subsection, MT_HYPNO_SECTION4, false))
		{
			if (StrEqual(key, "HypnoColor", false) || StrEqual(key, "Hypno Color", false) || StrEqual(key, "Hypno_Color", false) || StrEqual(key, "color", false))
			{
				char sSet[4][4], sValue[16];
				MT_GetConfigColors(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < (sizeof sSet); iPos++)
				{
					switch (special && specsection[0] != '\0')
					{
						case true: g_esHypnoTeammate[admin].g_iHypnoColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
						case false: g_esHypnoPlayer[admin].g_iHypnoColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
				}

				switch (special && specsection[0] != '\0')
				{
					case true: strcopy(g_esHypnoTeammate[admin].g_sHypnoColor, sizeof esHypnoTeammate::g_sHypnoColor, value);
					case false: strcopy(g_esHypnoPlayer[admin].g_sHypnoColor, sizeof esHypnoPlayer::g_sHypnoColor, value);
				}
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esHypnoSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHypnoSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHypnoSpecial[type].g_iComboAbility, value, -1, 1);
			g_esHypnoSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHypnoSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esHypnoSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHypnoSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esHypnoSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHypnoSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esHypnoSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHypnoSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHypnoSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHypnoSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHypnoSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esHypnoSpecial[type].g_iHypnoAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHypnoSpecial[type].g_iHypnoAbility, value, -1, 1);
			g_esHypnoSpecial[type].g_iHypnoEffect = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHypnoSpecial[type].g_iHypnoEffect, value, -1, 7);
			g_esHypnoSpecial[type].g_iHypnoMessage = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHypnoSpecial[type].g_iHypnoMessage, value, -1, 3);
			g_esHypnoSpecial[type].g_iHypnoSight = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHypnoSpecial[type].g_iHypnoSight, value, -1, 5);
			g_esHypnoSpecial[type].g_flHypnoBulletDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_esHypnoSpecial[type].g_flHypnoBulletDivisor, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_flHypnoChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_esHypnoSpecial[type].g_flHypnoChance, value, -1.0, 100.0);
			g_esHypnoSpecial[type].g_iHypnoCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoCooldown", "Hypno Cooldown", "Hypno_Cooldown", "cooldown", g_esHypnoSpecial[type].g_iHypnoCooldown, value, -1, 99999);
			g_esHypnoSpecial[type].g_flHypnoDuration = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_esHypnoSpecial[type].g_flHypnoDuration, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_flHypnoExplosiveDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_esHypnoSpecial[type].g_flHypnoExplosiveDivisor, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_flHypnoFireDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_esHypnoSpecial[type].g_flHypnoFireDivisor, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_iHypnoHit = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_esHypnoSpecial[type].g_iHypnoHit, value, -1, 1);
			g_esHypnoSpecial[type].g_iHypnoHitMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_esHypnoSpecial[type].g_iHypnoHitMode, value, -1, 2);
			g_esHypnoSpecial[type].g_flHypnoHittableDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHittableDivisor", "Hypno Hittable Divisor", "Hypno_Hittable_Divisor", "hittable", g_esHypnoSpecial[type].g_flHypnoHittableDivisor, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_flHypnoMeleeDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_esHypnoSpecial[type].g_flHypnoMeleeDivisor, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_iHypnoMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_esHypnoSpecial[type].g_iHypnoMode, value, -1, 1);
			g_esHypnoSpecial[type].g_flHypnoRange = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_esHypnoSpecial[type].g_flHypnoRange, value, -1.0, 99999.0);
			g_esHypnoSpecial[type].g_flHypnoRangeChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_esHypnoSpecial[type].g_flHypnoRangeChance, value, -1.0, 100.0);
			g_esHypnoSpecial[type].g_iHypnoRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeCooldown", "Hypno Range Cooldown", "Hypno_Range_Cooldown", "rangecooldown", g_esHypnoSpecial[type].g_iHypnoRangeCooldown, value, -1, 99999);
			g_esHypnoSpecial[type].g_iHypnoView = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoView", "Hypno View", "Hypno_View", "view", g_esHypnoSpecial[type].g_iHypnoView, value, -1, 1);
		}
		else
		{
			g_esHypnoAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHypnoAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHypnoAbility[type].g_iComboAbility, value, -1, 1);
			g_esHypnoAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHypnoAbility[type].g_iHumanAbility, value, -1, 2);
			g_esHypnoAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHypnoAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esHypnoAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHypnoAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esHypnoAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHypnoAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHypnoAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHypnoAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHypnoAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esHypnoAbility[type].g_iHypnoAbility = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHypnoAbility[type].g_iHypnoAbility, value, -1, 1);
			g_esHypnoAbility[type].g_iHypnoEffect = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHypnoAbility[type].g_iHypnoEffect, value, -1, 7);
			g_esHypnoAbility[type].g_iHypnoMessage = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHypnoAbility[type].g_iHypnoMessage, value, -1, 3);
			g_esHypnoAbility[type].g_iHypnoSight = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHypnoAbility[type].g_iHypnoSight, value, -1, 5);
			g_esHypnoAbility[type].g_flHypnoBulletDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_esHypnoAbility[type].g_flHypnoBulletDivisor, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_flHypnoChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_esHypnoAbility[type].g_flHypnoChance, value, -1.0, 100.0);
			g_esHypnoAbility[type].g_iHypnoCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoCooldown", "Hypno Cooldown", "Hypno_Cooldown", "cooldown", g_esHypnoAbility[type].g_iHypnoCooldown, value, -1, 99999);
			g_esHypnoAbility[type].g_flHypnoDuration = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_esHypnoAbility[type].g_flHypnoDuration, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_flHypnoExplosiveDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_esHypnoAbility[type].g_flHypnoExplosiveDivisor, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_flHypnoFireDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_esHypnoAbility[type].g_flHypnoFireDivisor, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_iHypnoHit = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_esHypnoAbility[type].g_iHypnoHit, value, -1, 1);
			g_esHypnoAbility[type].g_iHypnoHitMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_esHypnoAbility[type].g_iHypnoHitMode, value, -1, 2);
			g_esHypnoAbility[type].g_flHypnoHittableDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoHittableDivisor", "Hypno Hittable Divisor", "Hypno_Hittable_Divisor", "hittable", g_esHypnoAbility[type].g_flHypnoHittableDivisor, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_flHypnoMeleeDivisor = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_esHypnoAbility[type].g_flHypnoMeleeDivisor, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_iHypnoMode = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_esHypnoAbility[type].g_iHypnoMode, value, -1, 1);
			g_esHypnoAbility[type].g_flHypnoRange = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_esHypnoAbility[type].g_flHypnoRange, value, -1.0, 99999.0);
			g_esHypnoAbility[type].g_flHypnoRangeChance = flGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_esHypnoAbility[type].g_flHypnoRangeChance, value, -1.0, 100.0);
			g_esHypnoAbility[type].g_iHypnoRangeCooldown = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoRangeCooldown", "Hypno Range Cooldown", "Hypno_Range_Cooldown", "rangecooldown", g_esHypnoAbility[type].g_iHypnoRangeCooldown, value, -1, 99999);
			g_esHypnoAbility[type].g_iHypnoView = iGetKeyValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "HypnoView", "Hypno View", "Hypno_View", "view", g_esHypnoAbility[type].g_iHypnoView, value, -1, 1);
			g_esHypnoAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esHypnoAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_HYPNO_SECTION, MT_HYPNO_SECTION2, MT_HYPNO_SECTION3, MT_HYPNO_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}

		if (StrEqual(subsection, MT_HYPNO_SECTION, false) || StrEqual(subsection, MT_HYPNO_SECTION2, false) || StrEqual(subsection, MT_HYPNO_SECTION3, false) || StrEqual(subsection, MT_HYPNO_SECTION4, false))
		{
			if (StrEqual(key, "HypnoColor", false) || StrEqual(key, "Hypno Color", false) || StrEqual(key, "Hypno_Color", false) || StrEqual(key, "color", false))
			{
				char sSet[4][4], sValue[16];
				MT_GetConfigColors(sValue, sizeof sValue, value);
				ReplaceString(sValue, sizeof sValue, " ", "");
				ExplodeString(sValue, ",", sSet, sizeof sSet, sizeof sSet[]);
				for (int iPos = 0; iPos < (sizeof sSet); iPos++)
				{
					switch (special && specsection[0] != '\0')
					{
						case true: g_esHypnoSpecial[type].g_iHypnoColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
						case false: g_esHypnoAbility[type].g_iHypnoColor[iPos] = (sSet[iPos][0] != '\0' && StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : -1;
					}
				}

				switch (special && specsection[0] != '\0')
				{
					case true: strcopy(g_esHypnoSpecial[type].g_sHypnoColor, sizeof esHypnoSpecial::g_sHypnoColor, value);
					case false: strcopy(g_esHypnoAbility[type].g_sHypnoColor, sizeof esHypnoAbility::g_sHypnoColor, value);
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT), bInfected = bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME);
	g_esHypnoPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esHypnoPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esHypnoPlayer[tank].g_iTankTypeRecorded;

	if (bInfected)
	{
		g_esHypnoCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flCloseAreasOnly, g_esHypnoPlayer[tank].g_flCloseAreasOnly, g_esHypnoSpecial[iType].g_flCloseAreasOnly, g_esHypnoAbility[iType].g_flCloseAreasOnly, 1);
		g_esHypnoCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iComboAbility, g_esHypnoPlayer[tank].g_iComboAbility, g_esHypnoSpecial[iType].g_iComboAbility, g_esHypnoAbility[iType].g_iComboAbility, 1);
		g_esHypnoCache[tank].g_flHypnoBulletDivisor = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoBulletDivisor, g_esHypnoPlayer[tank].g_flHypnoBulletDivisor, g_esHypnoSpecial[iType].g_flHypnoBulletDivisor, g_esHypnoAbility[iType].g_flHypnoBulletDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoChance = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoChance, g_esHypnoPlayer[tank].g_flHypnoChance, g_esHypnoSpecial[iType].g_flHypnoChance, g_esHypnoAbility[iType].g_flHypnoChance, 1);
		g_esHypnoCache[tank].g_iHypnoCooldown = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoCooldown, g_esHypnoPlayer[tank].g_iHypnoCooldown, g_esHypnoSpecial[iType].g_iHypnoCooldown, g_esHypnoAbility[iType].g_iHypnoCooldown, 1);
		g_esHypnoCache[tank].g_flHypnoDuration = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoDuration, g_esHypnoPlayer[tank].g_flHypnoDuration, g_esHypnoSpecial[iType].g_flHypnoDuration, g_esHypnoAbility[iType].g_flHypnoDuration, 1);
		g_esHypnoCache[tank].g_flHypnoExplosiveDivisor = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoExplosiveDivisor, g_esHypnoPlayer[tank].g_flHypnoExplosiveDivisor, g_esHypnoSpecial[iType].g_flHypnoExplosiveDivisor, g_esHypnoAbility[iType].g_flHypnoExplosiveDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoFireDivisor = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoFireDivisor, g_esHypnoPlayer[tank].g_flHypnoFireDivisor, g_esHypnoSpecial[iType].g_flHypnoFireDivisor, g_esHypnoAbility[iType].g_flHypnoFireDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoHittableDivisor = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoHittableDivisor, g_esHypnoPlayer[tank].g_flHypnoHittableDivisor, g_esHypnoSpecial[iType].g_flHypnoHittableDivisor, g_esHypnoAbility[iType].g_flHypnoHittableDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoMeleeDivisor = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoMeleeDivisor, g_esHypnoPlayer[tank].g_flHypnoMeleeDivisor, g_esHypnoSpecial[iType].g_flHypnoMeleeDivisor, g_esHypnoAbility[iType].g_flHypnoMeleeDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoRange = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoRange, g_esHypnoPlayer[tank].g_flHypnoRange, g_esHypnoSpecial[iType].g_flHypnoRange, g_esHypnoAbility[iType].g_flHypnoRange, 1);
		g_esHypnoCache[tank].g_flHypnoRangeChance = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flHypnoRangeChance, g_esHypnoPlayer[tank].g_flHypnoRangeChance, g_esHypnoSpecial[iType].g_flHypnoRangeChance, g_esHypnoAbility[iType].g_flHypnoRangeChance, 1);
		g_esHypnoCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHumanAbility, g_esHypnoPlayer[tank].g_iHumanAbility, g_esHypnoSpecial[iType].g_iHumanAbility, g_esHypnoAbility[iType].g_iHumanAbility, 1);
		g_esHypnoCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHumanAmmo, g_esHypnoPlayer[tank].g_iHumanAmmo, g_esHypnoSpecial[iType].g_iHumanAmmo, g_esHypnoAbility[iType].g_iHumanAmmo, 1);
		g_esHypnoCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHumanCooldown, g_esHypnoPlayer[tank].g_iHumanCooldown, g_esHypnoSpecial[iType].g_iHumanCooldown, g_esHypnoAbility[iType].g_iHumanCooldown, 1);
		g_esHypnoCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHumanRangeCooldown, g_esHypnoPlayer[tank].g_iHumanRangeCooldown, g_esHypnoSpecial[iType].g_iHumanRangeCooldown, g_esHypnoAbility[iType].g_iHumanRangeCooldown, 1);
		g_esHypnoCache[tank].g_iHypnoAbility = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoAbility, g_esHypnoPlayer[tank].g_iHypnoAbility, g_esHypnoSpecial[iType].g_iHypnoAbility, g_esHypnoAbility[iType].g_iHypnoAbility, 1);
		g_esHypnoCache[tank].g_iHypnoEffect = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoEffect, g_esHypnoPlayer[tank].g_iHypnoEffect, g_esHypnoSpecial[iType].g_iHypnoEffect, g_esHypnoAbility[iType].g_iHypnoEffect, 1);
		g_esHypnoCache[tank].g_iHypnoHit = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoHit, g_esHypnoPlayer[tank].g_iHypnoHit, g_esHypnoSpecial[iType].g_iHypnoHit, g_esHypnoAbility[iType].g_iHypnoHit, 1);
		g_esHypnoCache[tank].g_iHypnoHitMode = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoHitMode, g_esHypnoPlayer[tank].g_iHypnoHitMode, g_esHypnoSpecial[iType].g_iHypnoHitMode, g_esHypnoAbility[iType].g_iHypnoHitMode, 1);
		g_esHypnoCache[tank].g_iHypnoMessage = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoMessage, g_esHypnoPlayer[tank].g_iHypnoMessage, g_esHypnoSpecial[iType].g_iHypnoMessage, g_esHypnoAbility[iType].g_iHypnoMessage, 1);
		g_esHypnoCache[tank].g_iHypnoMode = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoMode, g_esHypnoPlayer[tank].g_iHypnoMode, g_esHypnoSpecial[iType].g_iHypnoMode, g_esHypnoAbility[iType].g_iHypnoMode, 1);
		g_esHypnoCache[tank].g_iHypnoRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoRangeCooldown, g_esHypnoPlayer[tank].g_iHypnoRangeCooldown, g_esHypnoSpecial[iType].g_iHypnoRangeCooldown, g_esHypnoAbility[iType].g_iHypnoRangeCooldown, 1);
		g_esHypnoCache[tank].g_iHypnoSight = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoSight, g_esHypnoPlayer[tank].g_iHypnoSight, g_esHypnoSpecial[iType].g_iHypnoSight, g_esHypnoAbility[iType].g_iHypnoSight, 1);
		g_esHypnoCache[tank].g_iHypnoView = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoView, g_esHypnoPlayer[tank].g_iHypnoView, g_esHypnoSpecial[iType].g_iHypnoView, g_esHypnoAbility[iType].g_iHypnoView, 1);
		g_esHypnoCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_flOpenAreasOnly, g_esHypnoPlayer[tank].g_flOpenAreasOnly, g_esHypnoSpecial[iType].g_flOpenAreasOnly, g_esHypnoAbility[iType].g_flOpenAreasOnly, 1);
		g_esHypnoCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iRequiresHumans, g_esHypnoPlayer[tank].g_iRequiresHumans, g_esHypnoSpecial[iType].g_iRequiresHumans, g_esHypnoAbility[iType].g_iRequiresHumans, 1);

		vGetSubSettingValue(apply, bHuman, g_esHypnoCache[tank].g_sHypnoColor, sizeof esHypnoCache::g_sHypnoColor, g_esHypnoTeammate[tank].g_sHypnoColor, g_esHypnoPlayer[tank].g_sHypnoColor, g_esHypnoSpecial[iType].g_sHypnoColor, g_esHypnoAbility[iType].g_sHypnoColor);
	}
	else
	{
		g_esHypnoCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flCloseAreasOnly, g_esHypnoAbility[iType].g_flCloseAreasOnly, 1);
		g_esHypnoCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iComboAbility, g_esHypnoAbility[iType].g_iComboAbility, 1);
		g_esHypnoCache[tank].g_flHypnoBulletDivisor = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoBulletDivisor, g_esHypnoAbility[iType].g_flHypnoBulletDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoChance = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoChance, g_esHypnoAbility[iType].g_flHypnoChance, 1);
		g_esHypnoCache[tank].g_iHypnoCooldown = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoCooldown, g_esHypnoAbility[iType].g_iHypnoCooldown, 1);
		g_esHypnoCache[tank].g_flHypnoDuration = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoDuration, g_esHypnoAbility[iType].g_flHypnoDuration, 1);
		g_esHypnoCache[tank].g_flHypnoExplosiveDivisor = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoExplosiveDivisor, g_esHypnoAbility[iType].g_flHypnoExplosiveDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoFireDivisor = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoFireDivisor, g_esHypnoAbility[iType].g_flHypnoFireDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoHittableDivisor = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoHittableDivisor, g_esHypnoAbility[iType].g_flHypnoHittableDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoMeleeDivisor = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoMeleeDivisor, g_esHypnoAbility[iType].g_flHypnoMeleeDivisor, 1);
		g_esHypnoCache[tank].g_flHypnoRange = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoRange, g_esHypnoAbility[iType].g_flHypnoRange, 1);
		g_esHypnoCache[tank].g_flHypnoRangeChance = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flHypnoRangeChance, g_esHypnoAbility[iType].g_flHypnoRangeChance, 1);
		g_esHypnoCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHumanAbility, g_esHypnoAbility[iType].g_iHumanAbility, 1);
		g_esHypnoCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHumanAmmo, g_esHypnoAbility[iType].g_iHumanAmmo, 1);
		g_esHypnoCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHumanCooldown, g_esHypnoAbility[iType].g_iHumanCooldown, 1);
		g_esHypnoCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHumanRangeCooldown, g_esHypnoAbility[iType].g_iHumanRangeCooldown, 1);
		g_esHypnoCache[tank].g_iHypnoAbility = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoAbility, g_esHypnoAbility[iType].g_iHypnoAbility, 1);
		g_esHypnoCache[tank].g_iHypnoEffect = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoEffect, g_esHypnoAbility[iType].g_iHypnoEffect, 1);
		g_esHypnoCache[tank].g_iHypnoHit = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoHit, g_esHypnoAbility[iType].g_iHypnoHit, 1);
		g_esHypnoCache[tank].g_iHypnoHitMode = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoHitMode, g_esHypnoAbility[iType].g_iHypnoHitMode, 1);
		g_esHypnoCache[tank].g_iHypnoMessage = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoMessage, g_esHypnoAbility[iType].g_iHypnoMessage, 1);
		g_esHypnoCache[tank].g_iHypnoMode = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoMode, g_esHypnoAbility[iType].g_iHypnoMode, 1);
		g_esHypnoCache[tank].g_iHypnoRangeCooldown = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoRangeCooldown, g_esHypnoAbility[iType].g_iHypnoRangeCooldown, 1);
		g_esHypnoCache[tank].g_iHypnoSight = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoSight, g_esHypnoAbility[iType].g_iHypnoSight, 1);
		g_esHypnoCache[tank].g_iHypnoView = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoView, g_esHypnoAbility[iType].g_iHypnoView, 1);
		g_esHypnoCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_flOpenAreasOnly, g_esHypnoAbility[iType].g_flOpenAreasOnly, 1);
		g_esHypnoCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iRequiresHumans, g_esHypnoAbility[iType].g_iRequiresHumans, 1);

		vGetSettingValue(apply, bHuman, g_esHypnoCache[tank].g_sHypnoColor, sizeof esHypnoCache::g_sHypnoColor, g_esHypnoPlayer[tank].g_sHypnoColor, g_esHypnoAbility[iType].g_sHypnoColor);
	}

	for (int iPos = 0; iPos < (sizeof esHypnoCache::g_iHypnoColor); iPos++)
	{
		switch (bInfected)
		{
			case true: g_esHypnoCache[tank].g_iHypnoColor[iPos] = iGetSubSettingValue(apply, bHuman, g_esHypnoTeammate[tank].g_iHypnoColor[iPos], g_esHypnoPlayer[tank].g_iHypnoColor[iPos], g_esHypnoSpecial[iType].g_iHypnoColor[iPos], g_esHypnoAbility[iType].g_iHypnoColor[iPos], 1);
			case false: g_esHypnoCache[tank].g_iHypnoColor[iPos] = iGetSettingValue(apply, bHuman, g_esHypnoPlayer[tank].g_iHypnoColor[iPos], g_esHypnoAbility[iType].g_iHypnoColor[iPos], 1);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vHypnoCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveHypno(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vHypnoPluginEnd()
#else
public void MT_OnPluginEnd()
#endif
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsInfected(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esHypnoPlayer[iTank].g_bActivated)
		{
			vRemoveHypno(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoEventFired(Event event, const char[] name)
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
			vHypnoCopyStats2(iBot, iTank);
			vRemoveHypno(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vHypnoReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vHypnoCopyStats2(iTank, iBot);
			vRemoveHypno(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveHypno(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vHypnoHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esHypnoCache[iBoomer].g_flHypnoChance, g_esHypnoCache[iBoomer].g_iHypnoHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHypnoAbility[g_esHypnoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[tank].g_iAccessFlags)) || g_esHypnoCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esHypnoCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esHypnoCache[tank].g_iHypnoAbility == 1 && g_esHypnoCache[tank].g_iComboAbility == 0)
	{
		vHypnoAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esHypnoCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHypnoCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHypnoPlayer[tank].g_iTankType, tank) || (g_esHypnoCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHypnoCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHypnoAbility[g_esHypnoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esHypnoCache[tank].g_iHypnoAbility == 1 && g_esHypnoCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esHypnoPlayer[tank].g_iRangeCooldown == -1 || g_esHypnoPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vHypnoAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman3", (g_esHypnoPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHypnoChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveHypno(tank);
}

#if defined MT_ABILITIES_MAIN
void vHypnoPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	vHypno(tank);
}

void vHypno(int tank)
{
	if (g_esHypnoCache[tank].g_iHypnoView == 1 && !g_esHypnoPlayer[tank].g_bActivated)
	{
		g_esHypnoPlayer[tank].g_bActivated = true;

		g_esHypnoPlayer[tank].g_iShield = CreateEntityByName("prop_dynamic");
		if (bIsValidEntity(g_esHypnoPlayer[tank].g_iShield))
		{
			float flOrigin[3];
			GetClientAbsOrigin(tank, flOrigin);
			flOrigin[2] -= 120.0;

			SetEntityModel(g_esHypnoPlayer[tank].g_iShield, MODEL_SHIELD);
			DispatchKeyValueVector(g_esHypnoPlayer[tank].g_iShield, "origin", flOrigin);
			DispatchSpawn(g_esHypnoPlayer[tank].g_iShield);
			vSetEntityParent(g_esHypnoPlayer[tank].g_iShield, tank, true);

			switch (StrEqual(g_esHypnoPlayer[tank].g_sHypnoColor, "rainbow", false))
			{
				case true:
				{
					if (!g_esHypnoPlayer[tank].g_bRainbowColor)
					{
						g_esHypnoPlayer[tank].g_bRainbowColor = SDKHookEx(tank, SDKHook_PreThinkPost, OnHypnoPreThinkPost);
					}
				}
				case false:
				{
					SetEntityRenderMode(g_esHypnoPlayer[tank].g_iShield, RENDER_TRANSTEXTURE);
					SetEntityRenderColor(g_esHypnoPlayer[tank].g_iShield, iGetRandomColor(g_esHypnoCache[tank].g_iHypnoColor[0]), iGetRandomColor(g_esHypnoCache[tank].g_iHypnoColor[1]), iGetRandomColor(g_esHypnoCache[tank].g_iHypnoColor[2]), iGetRandomColor(g_esHypnoCache[tank].g_iHypnoColor[3]));
				}
			}

			SetEntProp(g_esHypnoPlayer[tank].g_iShield, Prop_Send, "m_CollisionGroup", 1);
			MT_HideEntity(g_esHypnoPlayer[tank].g_iShield, true);
			SDKHook(g_esHypnoPlayer[tank].g_iShield, SDKHook_SetTransmit, OnHypnoSetTransmit);
			g_esHypnoPlayer[tank].g_iShield = EntIndexToEntRef(g_esHypnoPlayer[tank].g_iShield);
		}
	}
}

void vHypnoAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esHypnoCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHypnoCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHypnoPlayer[tank].g_iTankType, tank) || (g_esHypnoCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHypnoCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHypnoAbility[g_esHypnoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esHypnoPlayer[tank].g_iAmmoCount < g_esHypnoCache[tank].g_iHumanAmmo && g_esHypnoCache[tank].g_iHumanAmmo > 0))
	{
		g_esHypnoPlayer[tank].g_bFailed = false;
		g_esHypnoPlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esHypnoCache[tank].g_flHypnoRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esHypnoCache[tank].g_flHypnoRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esHypnoPlayer[tank].g_iTankType, g_esHypnoAbility[g_esHypnoPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esHypnoPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esHypnoCache[tank].g_iHypnoSight, .range = flRange))
				{
					vHypnoHit(iSurvivor, tank, random, flChance, g_esHypnoCache[tank].g_iHypnoAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoAmmo");
	}
}

void vHypnoHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esHypnoCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHypnoCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHypnoPlayer[tank].g_iTankType, tank) || (g_esHypnoCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHypnoCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHypnoAbility[g_esHypnoPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esHypnoPlayer[tank].g_iTankType, g_esHypnoAbility[g_esHypnoPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esHypnoPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esHypnoPlayer[tank].g_iRangeCooldown != -1 && g_esHypnoPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esHypnoPlayer[tank].g_iCooldown != -1 && g_esHypnoPlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor) && !bIsSurvivorDisabled(survivor))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esHypnoPlayer[tank].g_iAmmoCount < g_esHypnoCache[tank].g_iHumanAmmo && g_esHypnoCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance && !g_esHypnoPlayer[survivor].g_bAffected)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esHypnoCache[tank].g_iHypnoSight, .range = 100.0))
				{
					return;
				}

				g_esHypnoPlayer[survivor].g_bAffected = true;
				g_esHypnoPlayer[survivor].g_iOwner = tank;

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esHypnoPlayer[tank].g_iRangeCooldown == -1 || g_esHypnoPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility == 1)
					{
						g_esHypnoPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman", g_esHypnoPlayer[tank].g_iAmmoCount, g_esHypnoCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esHypnoCache[tank].g_iHypnoRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility == 1 && g_esHypnoPlayer[tank].g_iAmmoCount < g_esHypnoCache[tank].g_iHumanAmmo && g_esHypnoCache[tank].g_iHumanAmmo > 0) ? g_esHypnoCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esHypnoPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esHypnoPlayer[tank].g_iRangeCooldown != -1 && g_esHypnoPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman5", (g_esHypnoPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esHypnoPlayer[tank].g_iCooldown == -1 || g_esHypnoPlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esHypnoCache[tank].g_iHypnoCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility == 1) ? g_esHypnoCache[tank].g_iHumanCooldown : iCooldown;
					g_esHypnoPlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esHypnoPlayer[tank].g_iCooldown != -1 && g_esHypnoPlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman5", (g_esHypnoPlayer[tank].g_iCooldown - iTime));
					}
				}

				float flDuration = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esHypnoCache[tank].g_flHypnoDuration;
				if (flDuration > 0.0)
				{
					DataPack dpStopHypno;
					CreateDataTimer(flDuration, tTimerStopHypno, dpStopHypno, TIMER_FLAG_NO_MAPCHANGE);
					dpStopHypno.WriteCell(GetClientUserId(survivor));
					dpStopHypno.WriteCell(GetClientUserId(tank));
					dpStopHypno.WriteCell(messages);
				}

				vScreenEffect(survivor, tank, g_esHypnoCache[tank].g_iHypnoEffect, flags);

				if (g_esHypnoCache[tank].g_iHypnoMessage & messages)
				{
					char sTankName[64];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Hypno", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esHypnoPlayer[tank].g_iRangeCooldown == -1 || g_esHypnoPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility == 1 && !g_esHypnoPlayer[tank].g_bFailed)
				{
					g_esHypnoPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHypnoCache[tank].g_iHumanAbility == 1 && !g_esHypnoPlayer[tank].g_bNoAmmo)
		{
			g_esHypnoPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoAmmo");
		}
	}
}

void OnHypnoPreThinkPost(int tank)
{
	if (!MT_IsTankSupported(tank) || !MT_IsCustomTankSupported(tank) || !g_esHypnoPlayer[tank].g_bRainbowColor)
	{
		g_esHypnoPlayer[tank].g_bRainbowColor = false;

		SDKUnhook(tank, SDKHook_PreThinkPost, OnHypnoPreThinkPost);

		return;
	}

	int iShield = EntRefToEntIndex(g_esHypnoPlayer[tank].g_iShield);
	if (iShield == INVALID_ENT_REFERENCE || !bIsValidEntity(iShield))
	{
		g_esHypnoPlayer[tank].g_bRainbowColor = false;

		SDKUnhook(tank, SDKHook_PreThinkPost, OnHypnoPreThinkPost);

		return;
	}

	bool bHook = false;
	float flCurrentTime = GetGameTime();
	int iColor[4];
	iColor[0] = RoundToNearest((Cosine((flCurrentTime * 1.0) + tank) * 127.5) + 127.5);
	iColor[1] = RoundToNearest((Cosine((flCurrentTime * 1.0) + tank + 2) * 127.5) + 127.5);
	iColor[2] = RoundToNearest((Cosine((flCurrentTime * 1.0) + tank + 4) * 127.5) + 127.5);
	iColor[3] = iGetRandomColor(g_esHypnoCache[tank].g_iHypnoColor[3]);

	if (StrEqual(g_esHypnoCache[tank].g_sHypnoColor, "rainbow", false))
	{
		bHook = true;

		SetEntityRenderMode(iShield, RENDER_TRANSTEXTURE);
		SetEntityRenderColor(iShield, iColor[0], iColor[1], iColor[2], iColor[3]);
	}

	if (!bHook)
	{
		g_esHypnoPlayer[tank].g_bRainbowColor = false;

		SDKUnhook(tank, SDKHook_PreThinkPost, OnHypnoPreThinkPost);
	}
}

Action OnHypnoSetTransmit(int entity, int client)
{
	if (bIsSurvivor(client) && g_esHypnoPlayer[client].g_bAffected)
	{
		return Plugin_Continue;
	}

	return Plugin_Handled;
}

void vHypnoCopyStats2(int oldTank, int newTank)
{
	g_esHypnoPlayer[newTank].g_iAmmoCount = g_esHypnoPlayer[oldTank].g_iAmmoCount;
	g_esHypnoPlayer[newTank].g_iCooldown = g_esHypnoPlayer[oldTank].g_iCooldown;
	g_esHypnoPlayer[newTank].g_iRangeCooldown = g_esHypnoPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveHypno(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME) && g_esHypnoPlayer[iSurvivor].g_bAffected && g_esHypnoPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esHypnoPlayer[iSurvivor].g_bAffected = false;
			g_esHypnoPlayer[iSurvivor].g_iOwner = -1;
		}
	}

	vHypnoReset2(tank);

	if (bIsValidEntRef(g_esHypnoPlayer[tank].g_iShield))
	{
		g_esHypnoPlayer[tank].g_iShield = EntRefToEntIndex(g_esHypnoPlayer[tank].g_iShield);
		if (bIsValidEntity(g_esHypnoPlayer[tank].g_iShield))
		{
			MT_HideEntity(g_esHypnoPlayer[tank].g_iShield, false);
			SDKUnhook(g_esHypnoPlayer[tank].g_iShield, SDKHook_SetTransmit, OnHypnoSetTransmit);
			RemoveEntity(g_esHypnoPlayer[tank].g_iShield);
		}
	}

	g_esHypnoPlayer[tank].g_bActivated = false;
	g_esHypnoPlayer[tank].g_bRainbowColor = false;
	g_esHypnoPlayer[tank].g_iShield = INVALID_ENT_REFERENCE;
}

void vHypnoReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vHypnoReset2(iPlayer);

			g_esHypnoPlayer[iPlayer].g_iOwner = -1;
		}
	}
}

void vHypnoReset2(int tank)
{
	g_esHypnoPlayer[tank].g_bAffected = false;
	g_esHypnoPlayer[tank].g_bFailed = false;
	g_esHypnoPlayer[tank].g_bNoAmmo = false;
	g_esHypnoPlayer[tank].g_iAmmoCount = 0;
	g_esHypnoPlayer[tank].g_iCooldown = -1;
	g_esHypnoPlayer[tank].g_iRangeCooldown = -1;
}

void tTimerHypnoCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHypnoAbility[g_esHypnoPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHypnoPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esHypnoCache[iTank].g_iHypnoAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vHypnoAbility(iTank, flRandom, iPos);
}

void tTimerHypnoCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esHypnoPlayer[iSurvivor].g_bAffected)
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHypnoAbility[g_esHypnoPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esHypnoPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHypnoPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esHypnoCache[iTank].g_iHypnoHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esHypnoCache[iTank].g_iHypnoHitMode == 0 || g_esHypnoCache[iTank].g_iHypnoHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vHypnoHit(iSurvivor, iTank, flRandom, flChance, g_esHypnoCache[iTank].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esHypnoCache[iTank].g_iHypnoHitMode == 0 || g_esHypnoCache[iTank].g_iHypnoHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vHypnoHit(iSurvivor, iTank, flRandom, flChance, g_esHypnoCache[iTank].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}

void tTimerStopHypno(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_esHypnoPlayer[iSurvivor].g_bAffected)
	{
		g_esHypnoPlayer[iSurvivor].g_bAffected = false;
		g_esHypnoPlayer[iSurvivor].g_iOwner = -1;

		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !MT_IsCustomTankSupported(iTank))
	{
		g_esHypnoPlayer[iSurvivor].g_bAffected = false;
		g_esHypnoPlayer[iSurvivor].g_iOwner = -1;

		return;
	}

	g_esHypnoPlayer[iSurvivor].g_bAffected = false;
	g_esHypnoPlayer[iSurvivor].g_iOwner = -1;

	int iMessage = pack.ReadCell();
	if (g_esHypnoCache[iTank].g_iHypnoMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno2", iSurvivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Hypno2", LANG_SERVER, iSurvivor);
	}
}