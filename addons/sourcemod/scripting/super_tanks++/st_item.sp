// Super Tanks++: Item Ability
#include <sourcemod>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Item Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gives survivors items upon death.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];

char g_sItemLoadout[ST_MAXTYPES + 1][325], g_sItemLoadout2[ST_MAXTYPES + 1][325];

float g_flItemChance[ST_MAXTYPES + 1], g_flItemChance2[ST_MAXTYPES + 1];

int g_iItemAbility[ST_MAXTYPES + 1], g_iItemAbility2[ST_MAXTYPES + 1], g_iItemMessage[ST_MAXTYPES + 1], g_iItemMessage2[ST_MAXTYPES + 1], g_iItemMode[ST_MAXTYPES + 1], g_iItemMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Item Ability only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

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
	LoadTranslations("super_tanks++.phrases");
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iItemAbility[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Enabled", 0);
				g_iItemAbility[iIndex] = iClamp(g_iItemAbility[iIndex], 0, 1);
				g_iItemMessage[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Message", 0);
				g_iItemMessage[iIndex] = iClamp(g_iItemMessage[iIndex], 0, 1);
				g_flItemChance[iIndex] = kvSuperTanks.GetFloat("Item Ability/Item Chance", 33.3);
				g_flItemChance[iIndex] = flClamp(g_flItemChance[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Item Ability/Item Loadout", g_sItemLoadout[iIndex], sizeof(g_sItemLoadout[]), "rifle,pistol,first_aid_kit,pain_pills");
				g_iItemMode[iIndex] = kvSuperTanks.GetNum("Item Ability/Item Mode", 0);
				g_iItemMode[iIndex] = iClamp(g_iItemMode[iIndex], 0, 1);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iItemAbility2[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Enabled", g_iItemAbility[iIndex]);
				g_iItemAbility2[iIndex] = iClamp(g_iItemAbility2[iIndex], 0, 1);
				g_iItemMessage2[iIndex] = kvSuperTanks.GetNum("Item Ability/Ability Message", g_iItemMessage[iIndex]);
				g_iItemMessage2[iIndex] = iClamp(g_iItemMessage2[iIndex], 0, 1);
				g_flItemChance2[iIndex] = kvSuperTanks.GetFloat("Item Ability/Item Chance", g_flItemChance[iIndex]);
				g_flItemChance2[iIndex] = flClamp(g_flItemChance2[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Item Ability/Item Loadout", g_sItemLoadout2[iIndex], sizeof(g_sItemLoadout2[]), g_sItemLoadout[iIndex]);
				g_iItemMode2[iIndex] = kvSuperTanks.GetNum("Item Ability/Item Mode", g_iItemMode[iIndex]);
				g_iItemMode2[iIndex] = iClamp(g_iItemMode2[iIndex], 0, 1);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
			iItemAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iItemAbility[ST_TankType(iTank)] : g_iItemAbility2[ST_TankType(iTank)],
			iItemMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_iItemMessage[ST_TankType(iTank)] : g_iItemMessage2[ST_TankType(iTank)],
			iItemMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iItemMode[ST_TankType(iTank)] : g_iItemMode2[ST_TankType(iTank)];

		float flItemChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flItemChance[ST_TankType(iTank)] : g_flItemChance2[ST_TankType(iTank)];

		if (iItemAbility == 1 && GetRandomFloat(0.1, 100.0) <= flItemChance && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			char sItems[5][64], sItemLoadout[325];
			sItemLoadout = !g_bTankConfig[ST_TankType(iTank)] ? g_sItemLoadout[ST_TankType(iTank)] : g_sItemLoadout2[ST_TankType(iTank)];
			TrimString(sItemLoadout);
			ExplodeString(sItemLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));

			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor))
				{
					switch (iItemMode)
					{
						case 0:
						{
							switch (GetRandomInt(1, 5))
							{
								case 1: vCheatCommand(iSurvivor, "give", sItems[0]);
								case 2: vCheatCommand(iSurvivor, "give", sItems[1]);
								case 3: vCheatCommand(iSurvivor, "give", sItems[2]);
								case 4: vCheatCommand(iSurvivor, "give", sItems[3]);
								case 5: vCheatCommand(iSurvivor, "give", sItems[4]);
							}
						}
						case 1:
						{
							for (int iItem = 0; iItem < sizeof(sItems); iItem++)
							{
								if (StrContains(sItemLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
								{
									vCheatCommand(iSurvivor, "give", sItems[iItem]);
								}
							}
						}
					}
				}
			}

			if (iItemMessage == 1)
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(iTank, sTankName);
				PrintToChatAll("%s %t", ST_TAG2, "Item", sTankName);
			}
		}
	}
}