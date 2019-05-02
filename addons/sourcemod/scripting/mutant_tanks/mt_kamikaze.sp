/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Kamikaze Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank kills itself along with a survivor victim.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Kamikaze Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

#define MT_MENU_KAMIKAZE "Kamikaze Ability"

bool g_bCloneInstalled, g_bKamikaze[MAXPLAYERS + 1];

float g_flKamikazeChance[MT_MAXTYPES + 1], g_flKamikazeRange[MT_MAXTYPES + 1], g_flKamikazeRangeChance[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iKamikazeAbility[MT_MAXTYPES + 1], g_iKamikazeEffect[MT_MAXTYPES + 1], g_iKamikazeHit[MT_MAXTYPES + 1], g_iKamikazeHitMode[MT_MAXTYPES + 1], g_iKamikazeMessage[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_kamikaze", cmdKamikazeInfo, "View information about the Kamikaze ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vPrecacheParticle(PARTICLE_BLOOD);

	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveKamikaze(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdKamikazeInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vKamikazeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vKamikazeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iKamikazeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Kamikaze Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iKamikazeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iKamikazeAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "KamikazeDetails");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vKamikazeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "KamikazeMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];
			switch (param2)
			{
				case 0:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_KAMIKAZE, MT_MENU_KAMIKAZE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_KAMIKAZE, false))
	{
		vKamikazeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iKamikazeHitMode[MT_GetTankType(attacker)] == 0 || g_iKamikazeHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vKamikazeHit(victim, attacker, g_flKamikazeChance[MT_GetTankType(attacker)], g_iKamikazeHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iKamikazeHitMode[MT_GetTankType(victim)] == 0 || g_iKamikazeHitMode[MT_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vKamikazeHit(attacker, victim, g_flKamikazeChance[MT_GetTankType(victim)], g_iKamikazeHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
			g_iImmunityFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iImmunityFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iKamikazeAbility[iIndex] = 0;
		g_iKamikazeEffect[iIndex] = 0;
		g_iKamikazeMessage[iIndex] = 0;
		g_flKamikazeChance[iIndex] = 33.3;
		g_iKamikazeHit[iIndex] = 0;
		g_iKamikazeHitMode[iIndex] = 0;
		g_flKamikazeRange[iIndex] = 150.0;
		g_flKamikazeRangeChance[iIndex] = 15.0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "kamikazeability", false) || StrEqual(subsection, "kamikaze ability", false) || StrEqual(subsection, "kamikaze_ability", false) || StrEqual(subsection, "kamikaze", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		g_iHumanAbility[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iKamikazeAbility[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iKamikazeAbility[type], value, 0, 1);
		g_iKamikazeEffect[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iKamikazeEffect[type], value, 0, 7);
		g_iKamikazeMessage[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iKamikazeMessage[type], value, 0, 3);
		g_flKamikazeChance[type] = flGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", g_flKamikazeChance[type], value, 0.0, 100.0);
		g_iKamikazeHit[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", g_iKamikazeHit[type], value, 0, 1);
		g_iKamikazeHitMode[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", g_iKamikazeHitMode[type], value, 0, 2);
		g_flKamikazeRange[type] = flGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", g_flKamikazeRange[type], value, 1.0, 9999999999.0);
		g_flKamikazeRangeChance[type] = flGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", g_flKamikazeRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "kamikazeability", false) || StrEqual(subsection, "kamikaze ability", false) || StrEqual(subsection, "kamikaze_ability", false) || StrEqual(subsection, "kamikaze", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags[type];
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iKamikazeAbility[MT_GetTankType(iTank)] == 1)
			{
				if (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank))
				{
					vKamikaze(iTank, iTank);
				}
			}

			vRemoveKamikaze(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iKamikazeAbility[MT_GetTankType(tank)] == 1)
	{
		vKamikazeAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if (g_iKamikazeAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				vKamikazeAbility(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveKamikaze(tank);
}

static void vKamikaze(int survivor, int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	EmitSoundToAll(SOUND_SMASH, survivor);
	EmitSoundToAll(SOUND_GROWL, tank);
	vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
}

static void vKamikazeAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	g_bKamikaze[tank] = false;

	float flTankPos[3];
	GetClientAbsOrigin(tank, flTankPos);

	int iSurvivorCount;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);

			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= g_flKamikazeRange[MT_GetTankType(tank)])
			{
				vKamikazeHit(iSurvivor, tank, g_flKamikazeRangeChance[MT_GetTankType(tank)], g_iKamikazeAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

				iSurvivorCount++;
			}
		}
	}

	if (iSurvivorCount == 0)
	{
		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman3");
		}
	}
}

static void vKamikazeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (GetRandomFloat(0.1, 100.0) <= chance)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE))
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman");
			}

			EmitSoundToAll(SOUND_SMASH, survivor);
			vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
			ForcePlayerSuicide(survivor);

			EmitSoundToAll(SOUND_GROWL, tank);
			vAttachParticle(tank, PARTICLE_BLOOD, 0.1, 0.0);
			ForcePlayerSuicide(tank);

			vEffect(survivor, tank, g_iKamikazeEffect[MT_GetTankType(tank)], flags);

			if (g_iKamikazeMessage[MT_GetTankType(tank)] & messages)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Kamikaze", sTankName, survivor);
			}
		}
		else if ((flags & MT_ATTACK_RANGE))
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bKamikaze[tank])
			{
				g_bKamikaze[tank] = true;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "KamikazeHuman2");
			}
		}
	}
}

static void vRemoveKamikaze(int tank)
{
	g_bKamikaze[tank] = false;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveKamikaze(iPlayer);
		}
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[MT_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iAbilityFlags)) ? false : true;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iTypeFlags)) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iGlobalFlags)) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_iImmunityFlags[MT_GetTankType(survivor)];
	if (iAbilityFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iAbilityFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(survivor));
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
		{
			return ((iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
		{
			return ((iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return ((GetUserFlagBits(tank) & iAbilityFlags) && GetUserFlagBits(survivor) <= GetUserFlagBits(tank)) ? false : true;
	}

	return false;
}