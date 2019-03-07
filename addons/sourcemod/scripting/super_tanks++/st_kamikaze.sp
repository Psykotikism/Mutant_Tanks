/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
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
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Kamikaze Ability",
	author = ST_AUTHOR,
	description = "The Super Tank kills itself along with a survivor victim.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Kamikaze Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

#define ST_MENU_KAMIKAZE "Kamikaze Ability"

bool g_bCloneInstalled, g_bKamikaze[MAXPLAYERS + 1];

float g_flKamikazeChance[ST_MAXTYPES + 1], g_flKamikazeRange[ST_MAXTYPES + 1], g_flKamikazeRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iKamikazeAbility[ST_MAXTYPES + 1], g_iKamikazeEffect[ST_MAXTYPES + 1], g_iKamikazeHit[ST_MAXTYPES + 1], g_iKamikazeHitMode[ST_MAXTYPES + 1], g_iKamikazeMessage[ST_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_kamikaze", cmdKamikazeInfo, "View information about the Kamikaze ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iKamikazeAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "KamikazeDetails");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_KAMIKAZE, ST_MENU_KAMIKAZE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_KAMIKAZE, false))
	{
		vKamikazeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iKamikazeHitMode[ST_GetTankType(attacker)] == 0 || g_iKamikazeHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vKamikazeHit(victim, attacker, g_flKamikazeChance[ST_GetTankType(attacker)], g_iKamikazeHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iKamikazeHitMode[ST_GetTankType(victim)] == 0 || g_iKamikazeHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vKamikazeHit(attacker, victim, g_flKamikazeChance[ST_GetTankType(victim)], g_iKamikazeHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
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

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 32, bHasAbilities(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze"));
	g_iHumanAbility[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iKamikazeAbility[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iKamikazeAbility[type], value, 0, 0, 1);
	g_iKamikazeEffect[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iKamikazeEffect[type], value, 0, 0, 7);
	g_iKamikazeMessage[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iKamikazeMessage[type], value, 0, 0, 3);
	g_flKamikazeChance[type] = flGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeChance", "Kamikaze Chance", "Kamikaze_Chance", "chance", main, g_flKamikazeChance[type], value, 33.3, 0.0, 100.0);
	g_iKamikazeHit[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeHit", "Kamikaze Hit", "Kamikaze_Hit", "hit", main, g_iKamikazeHit[type], value, 0, 0, 1);
	g_iKamikazeHitMode[type] = iGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeHitMode", "Kamikaze Hit Mode", "Kamikaze_Hit_Mode", "hitmode", main, g_iKamikazeHitMode[type], value, 0, 0, 2);
	g_flKamikazeRange[type] = flGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeRange", "Kamikaze Range", "Kamikaze_Range", "range", main, g_flKamikazeRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flKamikazeRangeChance[type] = flGetValue(subsection, "kamikazeability", "kamikaze ability", "kamikaze_ability", "kamikaze", key, "KamikazeRangeChance", "Kamikaze Range Chance", "Kamikaze_Range_Chance", "rangechance", main, g_flKamikazeRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iKamikazeAbility[ST_GetTankType(iTank)] == 1)
			{
				vKamikaze(iTank, iTank);
			}

			vRemoveKamikaze(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iKamikazeAbility[ST_GetTankType(tank)] == 1)
	{
		vKamikazeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iKamikazeAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				vKamikazeAbility(tank);
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveKamikaze(tank);
}

static void vKamikaze(int survivor, int tank)
{
	EmitSoundToAll(SOUND_SMASH, survivor);
	EmitSoundToAll(SOUND_GROWL, tank);
	vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
}

static void vKamikazeAbility(int tank)
{
	g_bKamikaze[tank] = false;

	float flTankPos[3];
	GetClientAbsOrigin(tank, flTankPos);

	int iSurvivorCount;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);

			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= g_flKamikazeRange[ST_GetTankType(tank)])
			{
				vKamikazeHit(iSurvivor, tank, g_flKamikazeRangeChance[ST_GetTankType(tank)], g_iKamikazeAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

				iSurvivorCount++;
			}
		}
	}

	if (iSurvivorCount == 0)
	{
		if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeHuman3");
		}
	}
}

static void vKamikazeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (GetRandomFloat(0.1, 100.0) <= chance)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE))
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeHuman");
			}

			EmitSoundToAll(SOUND_SMASH, survivor);
			vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
			ForcePlayerSuicide(survivor);

			EmitSoundToAll(SOUND_GROWL, tank);
			vAttachParticle(tank, PARTICLE_BLOOD, 0.1, 0.0);
			ForcePlayerSuicide(tank);

			vEffect(survivor, tank, g_iKamikazeEffect[ST_GetTankType(tank)], flags);

			if (g_iKamikazeMessage[ST_GetTankType(tank)] & messages)
			{
				char sTankName[33];
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Kamikaze", sTankName, survivor);
			}
		}
		else if ((flags & ST_ATTACK_RANGE))
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bKamikaze[tank])
			{
				g_bKamikaze[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeHuman2");
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveKamikaze(iPlayer);
		}
	}
}