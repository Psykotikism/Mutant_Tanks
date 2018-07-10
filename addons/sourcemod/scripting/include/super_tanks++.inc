// Super Tanks++
#if defined _supertanks_included
	#endinput
#endif
#define _supertanks_included
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <adminmenu>
#define ST_PREFIX "[ST++]"
#define ST_NAME "Super Tanks++"
#define ST_AUTHOR "Psyk0tik (Crasher_3637)"
#define ST_DESCRIPTION "Super Tanks++ makes fighting Tanks great again!"
#define ST_VERSION "8.19"
#define ST_URL "https://forums.alliedmods.net/showthread.php?t=302140"
#define MAXTYPES 1000
#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define SPRITE_FIRE "sprites/sprite_fire01.vmt"
#define SPRITE_GLOW "sprites/glow.vmt"
#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_ICE "steam_manhole"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile"
#define SOUND_INFECTED "npc/infected/action/die/male/death_42.wav"
#define SOUND_INFECTED2 "npc/infected/action/die/male/death_43.wav"
#define SOUND_EXPLOSION "ambient/explosions/exp2.wav"
#define SOUND_LAUNCH "npc/env_headcrabcanister/launch.wav"
#define SOUND_FIRE "weapons/rpg/rocketfire1.wav"
#define SOUND_EXPLOSION2 "ambient/explosions/explode_1.wav"
#define SOUND_EXPLOSION3 "ambient/explosions/explode_2.wav"
#define SOUND_EXPLOSION4 "ambient/explosions/explode_3.wav"
#define SOUND_DEBRIS "animation/van_inside_debris.wav"
#define SOUND_BULLET "physics/glass/glass_impact_bullet4.wav"

int g_iCurrentMode;

// Checks
public bool bBoomerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsBoomer(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bChargerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsCharger(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

stock bool bHasIdlePlayer(int client)
{
	int iIdler = GetClientOfUserId(GetEntData(client, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
	if (iIdler)
	{
		if (IsClientInGame(iIdler) && !IsFakeClient(iIdler) && (GetClientTeam(iIdler) != 2))
		{
			return true;
		}
	}
	return false;
}

public bool bHunterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsHunter(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

stock bool bIsBoomer(int client, bool alive = true)
{
	if (bIsInfected(client, alive))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 2)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsBotIdle(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && IsFakeClient(client) && bHasIdlePlayer(client);
}

stock bool bIsBotIdleSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && IsFakeClient(client) && !bHasIdlePlayer(client);
}

stock bool bIsBotInfected(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && IsFakeClient(client);
}

stock bool bIsBotSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && IsFakeClient(client);
}

stock bool bIsCharger(int client, bool alive = true)
{
	if (bIsInfected(client, alive))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 6)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsFinaleMap()
{
	return FindEntityByClassname(-1, "trigger_finale") != -1;
}

stock bool bIsHumanSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && !IsFakeClient(client) && !bHasIdlePlayer(client) && !bIsPlayerIdle(client);
}

stock bool bIsHunter(int client, bool alive = true)
{
	if (bIsInfected(client, alive))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 3)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsIdlePlayer(int bot, int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(bot) == 2;
}

stock bool bIsInfected(int client, bool alive = true)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3 && (!alive || (alive && IsPlayerAlive(client))) && !IsClientInKickQueue(client);
}

stock bool bIsJockey(int client, bool alive = true)
{
	if (bIsInfected(client, alive))
	{
		if (bIsL4D2Game() && GetEntProp(client, Prop_Send, "m_zombieClass") == 5)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsL4D2Game()
{
	return GetEngineVersion() == Engine_Left4Dead2;
}

stock bool bIsPlayerBurning(int client)
{
	if (GetEntPropFloat(client, Prop_Send, "m_burnPercent") > 0)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerFired(int client)
{
	if (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerGhost(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost", 1))
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerGrounded(int client)
{
	if (GetEntProp(client, Prop_Send, "m_fFlags") & FL_ONGROUND)
	{
		return true;
	}
	return false;
}

stock bool bIsPlayerIdle(int client)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!IsClientInGame(iPlayer) || GetClientTeam(iPlayer) != 2 || !IsFakeClient(iPlayer) || !bHasIdlePlayer(iPlayer))
		{
			continue;
		}
		int iIdler = GetClientOfUserId(GetEntData(iPlayer, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
		if (iIdler == client)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsPlayerIncapacitated(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
	{
		return true;
	}
	return false;
}

stock bool bIsPluginEnabled(ConVar convar, int mode, char[] enabled, char[] disabled)
{
	if (convar == null)
	{
		return false;
	}
	if (mode != 0)
	{
		g_iCurrentMode = 0;
		int iGameMode = CreateEntityByName("info_gamemode");
		DispatchSpawn(iGameMode);
		HookSingleEntityOutput(iGameMode, "OnCoop", vGamemode, true);
		HookSingleEntityOutput(iGameMode, "OnSurvival", vGamemode, true);
		HookSingleEntityOutput(iGameMode, "OnVersus", vGamemode, true);
		HookSingleEntityOutput(iGameMode, "OnScavenge", vGamemode, true);
		ActivateEntity(iGameMode);
		AcceptEntityInput(iGameMode, "PostSpawnActivate");
		AcceptEntityInput(iGameMode, "Kill");
		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}
	char sGameMode[64];
	char sGameModes[64];
	convar.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);
	if (strcmp(enabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", enabled);
		if (StrContains(sGameModes, sGameMode, false) == -1)
		{
			return false;
		}
	}
	if (strcmp(disabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", disabled);
		if (StrContains(sGameModes, sGameMode, false) != -1)
		{
			return false;
		}
	}
	return true;
}

stock bool bIsSmoker(int client, bool alive = true)
{
	if (bIsInfected(client, alive))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 1)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsSpecialInfected(int client)
{
	if (bIsInfected(client))
	{
		int iClass = GetEntProp(client, Prop_Send, "m_zombieClass");
		if (iClass == 1 || iClass == 2 || iClass == 3 || iClass == 4 || (bIsL4D2Game() && iClass == 5) || iClass == 6)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsSpitter(int client, bool alive = true)
{
	if (bIsInfected(client, alive))
	{
		if (GetEntProp(client, Prop_Send, "m_zombieClass") == 4)
		{
			return true;
		}
	}
	return false;
}

stock bool bIsSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client);
}

stock bool bIsTank(int client, bool alive = true)
{
	if (bIsInfected(client, alive))
	{
		int iClass = GetEntProp(client, Prop_Send, "m_zombieClass");
		if ((bIsL4D2Game() && iClass == 8) || (!bIsL4D2Game() && iClass == 5))
		{
			return true;
		}
	}
	return false;
}

stock bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

stock bool bIsValidHumanClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client) && !IsFakeClient(client);
}

stock bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

stock bool bIsWitch(int client)
{
	if (IsValidEntity(client))
	{
		char sClassname[32];
		GetEntityClassname(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "witch") == 0)
		{
			return true;
		}
	}
	return false;
}

public bool bJockeyFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsJockey(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSmokerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSmoker(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSpitterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpitter(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bTankFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bTraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data) 
	{
		return false; 
	}
	else if (entity > 0 && entity <= MaxClients)
	{
		if (IsClientInGame(entity))
		{
			return false;
		}
	}
	return true;
}

// Functions
public float flGetGroundUnits(int entity)
{
	if (!(GetEntityFlags(entity) & FL_ONGROUND))
	{ 
		Handle hTrace;
		float flOrigin[3];
		float flPosition[3];
		float flDown[3] = {90.0, 0.0, 0.0};
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);
		hTrace = TR_TraceRayFilterEx(flOrigin, flDown, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, bTraceRayDontHitSelf, entity);
		if (TR_DidHit(hTrace))
		{
			float flUnits;
			TR_GetEndPosition(flPosition, hTrace);
			flUnits = flOrigin[2] - flPosition[2];
			delete hTrace;
			return flUnits;
		}
		delete hTrace;
	}
	return 0.0;
}

stock float flSetFloatLimit(float value, float min, float max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

stock int iGetBotSurvivor()
{
	for (int iBot = MaxClients; iBot >= 1; iBot--)
	{
		if (bIsBotSurvivor(iBot))
		{
			return iBot;
		}
	}
	return -1;
}

stock int iGetHumanCount()
{
	int iHumanCount;
	for (int iHuman = 1; iHuman <= MaxClients; iHuman++)
	{
		if (bIsHumanSurvivor(iHuman))
		{
			iHumanCount++;
		}
	}
	return iHumanCount;
}

stock int iGetIdleBot(int client)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == client)
		{
			return iBot;
		}
	}
	return 0;
}

stock int iGetIdlePlayer(int client)
{
	if (bIsBotSurvivor(client))
	{
		char sClassname[12];
		GetEntityNetClass(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "SurvivorBot") == 0)
		{
			int iIdler = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));			
			if (iIdler > 0 && IsClientInGame(iIdler) && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}
	return 0;
}

stock int iGetInfectedCount()
{
	int iInfectedCount;
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsInfected(iInfected))
		{
			iInfectedCount++;
		}
	}
	return iInfectedCount;
}

stock int iGetNearestSurvivor(int client)
{
	float flDistance = 0.0;
	float flNearest = 0.0;
	float flPlayerPos[3];
	float flTargetPos[3];
	if (bIsValidClient(client))
	{
		GetClientAbsOrigin(client, flPlayerPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				GetClientAbsOrigin(iSurvivor, flTargetPos);
				flDistance = GetVectorDistance(flPlayerPos, flTargetPos);
				if (flNearest == 0.0 || flNearest > flDistance)
				{
					flNearest = flDistance;
				}
			}
		}
	}
	return RoundFloat(flDistance);
}

stock int iGetPlayerCount()
{
	int iPlayerCount;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidHumanClient(iPlayer))
		{
			iPlayerCount++;
		}
	}
	return iPlayerCount;
}

stock int iGetRandomSurvivor(int client, bool different = false)
{
    int iSurvivorCount;
    int iSurvivors[MAXPLAYERS + 1];
    for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
    {
        if (bIsSurvivor(iSurvivor) || (bIsSurvivor(iSurvivor) && different && iSurvivor != client))
        {
            iSurvivors[iSurvivorCount++] = iSurvivor; 
        }
    }
    return iSurvivors[GetRandomInt(0, iSurvivorCount - 1)];
}

stock int iGetRayHitPos(float pos[3], float angle[3], float hitpos[3], int entity = 0, bool offset = false)
{
	int iHit = 0;
	Handle hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, entity);
	if (TR_DidHit(hTrace))
	{
		TR_GetEndPosition(hitpos, hTrace);
		iHit = TR_GetEntityIndex(hTrace);
	}
	delete hTrace;
	if (offset)
	{
		float flVector[3];
		MakeVectorFromPoints(hitpos, pos, flVector);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, 15.0);
		AddVectors(hitpos, flVector, hitpos);
	}
	return iHit;
}

stock int iGetRGBColor(int red, int green, int blue) 
{
	return (blue * 65536) + (green * 256) + red;
}

stock int iGetTankCount()
{
	int iTankCount;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank))
		{
			iTankCount++;
		}
	}
	return iTankCount;
}

stock int iGetWitchCount()
{
	int iWitchCount;
	int iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}
	return iWitchCount;
}

stock int iSetCellLimit(int value, int min, int max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

stock void vApplyBlindness(int client, int amount, UserMsg message)
{
	int iTargets[2];
	iTargets[0] = client;
	int iFlags;
	if (bIsSurvivor(client))
	{
		amount == 0 ? (iFlags = (0x0001|0x0010)) : (iFlags = (0x0002|0x0008));
		int iColor[4] = {0, 0, 0, 0};
		iColor[3] = amount;
		Handle hBlindTarget = StartMessageEx(message, iTargets, 1);
		if (GetUserMessageType() == UM_Protobuf)
		{
			Protobuf pbSet = UserMessageToProtobuf(hBlindTarget);
			pbSet.SetInt("duration", 1536);
			pbSet.SetInt("hold_time", 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", iColor);
		}
		else
		{
			BfWrite bfWrite = UserMessageToBfWrite(hBlindTarget);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(iFlags);
			bfWrite.WriteByte(iColor[0]);
			bfWrite.WriteByte(iColor[1]);
			bfWrite.WriteByte(iColor[2]);
			bfWrite.WriteByte(iColor[3]);
		}
		EndMessage();
	}
}

stock void vApplyDrug(int client, bool toggle, UserMsg message, float angles[20])
{
	float flAngles[3];
	GetClientEyeAngles(client, flAngles);
	flAngles[2] = toggle ? angles[GetRandomInt(0, 100) % 20] : 0.0;
	TeleportEntity(client, NULL_VECTOR, flAngles, NULL_VECTOR);
	int iClients[2];
	iClients[0] = client;
	int iFlags = toggle ? 0x0002 : (0x0001|0x0010);
	int iColor[4] = {0, 0, 0, 128};
	int iColor2[4] = {0, 0, 0, 0};
	if (toggle)
	{
		iColor[0] = GetRandomInt(0, 255);
		iColor[1] = GetRandomInt(0, 255);
		iColor[2] = GetRandomInt(0, 255);
	}
	Handle hDrugTarget = StartMessageEx(message, iClients, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbSet = UserMessageToProtobuf(hDrugTarget);
		pbSet.SetInt("duration", toggle ? 255: 1536);
		pbSet.SetInt("hold_time", toggle ? 255 : 1536);
		pbSet.SetInt("flags", iFlags);
		pbSet.SetColor("clr", toggle ? iColor : iColor2);
	}
	else
	{
		BfWrite bfWrite = UserMessageToBfWrite(hDrugTarget);
		bfWrite.WriteShort(toggle ? 255 : 1536);
		bfWrite.WriteShort(toggle ? 255 : 1536);
		bfWrite.WriteShort(iFlags);
		bfWrite.WriteByte(toggle ? iColor[0] : iColor2[0]);
		bfWrite.WriteByte(toggle ? iColor[1] : iColor2[1]);
		bfWrite.WriteByte(toggle ? iColor[2] : iColor2[2]);
		bfWrite.WriteByte(toggle ? iColor[3] : iColor2[3]);
	}
	EndMessage();
}

stock void vAttachParticle(int client, char[] particlename, float time, float origin)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "Start");
			SetVariantString("!activator");
			AcceptEntityInput(iParticle, "SetParent", client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vBomb(int client, float pos[3])
{
	int iParticle = CreateEntityByName("info_particle_system");
	int iParticle2 = CreateEntityByName("info_particle_system");
	int iParticle3 = CreateEntityByName("info_particle_system");
	int iTrace = CreateEntityByName("info_particle_system");
	int iPhysics = CreateEntityByName("env_physexplosion");
	int iHurt = CreateEntityByName("point_hurt");
	int iExplosion = CreateEntityByName("env_explosion");
	DispatchKeyValue(iParticle, "effect_name", "FluidExplosion_fps");
	TeleportEntity(iParticle, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle);
	ActivateEntity(iParticle);
	DispatchKeyValue(iParticle2, "effect_name", "weapon_grenade_explosion");
	TeleportEntity(iParticle2, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle2);
	ActivateEntity(iParticle2);
	DispatchKeyValue(iParticle3, "effect_name", "explosion_huge_b");
	TeleportEntity(iParticle3, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle3);
	ActivateEntity(iParticle3);
	DispatchKeyValue(iTrace, "effect_name", "gas_explosion_ground_fire");
	TeleportEntity(iTrace, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iTrace);
	ActivateEntity(iTrace);
	SetEntPropEnt(iExplosion, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iExplosion, "fireballsprite", "sprites/muzzleflash4.vmt");
	DispatchKeyValue(iExplosion, "iMagnitude", "150");
	DispatchKeyValue(iExplosion, "iRadiusOverride", "150");
	DispatchKeyValue(iExplosion, "spawnflags", "828");
	TeleportEntity(iExplosion, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iExplosion);
	SetEntPropEnt(iPhysics, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iPhysics, "radius", "150");
	DispatchKeyValue(iPhysics, "magnitude", "150");
	TeleportEntity(iPhysics, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iPhysics);
	SetEntPropEnt(iHurt, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iHurt, "DamageRadius", "150");
	DispatchKeyValue(iHurt, "DamageDelay", "0.5");
	DispatchKeyValue(iHurt, "Damage", "5");
	DispatchKeyValue(iHurt, "DamageType", "8");
	TeleportEntity(iHurt, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iHurt);
	switch (GetRandomInt(1, 3))
	{
		case 1: EmitSoundToAll(SOUND_EXPLOSION2, client);
		case 2: EmitSoundToAll(SOUND_EXPLOSION3, client);
		case 3: EmitSoundToAll(SOUND_EXPLOSION4, client);
	}
	EmitSoundToAll(SOUND_DEBRIS, client);
	AcceptEntityInput(iParticle, "Start");
	AcceptEntityInput(iParticle2, "Start");
	AcceptEntityInput(iParticle3, "Start");
	AcceptEntityInput(iTrace, "Start");
	AcceptEntityInput(iExplosion, "Explode");
	AcceptEntityInput(iPhysics, "Explode");
	AcceptEntityInput(iHurt, "TurnOn");
	iParticle = EntIndexToEntRef(iParticle);
	vDeleteEntity(iParticle, 16.5);
	iParticle2 = EntIndexToEntRef(iParticle2);
	vDeleteEntity(iParticle2, 16.5);
	iParticle3 = EntIndexToEntRef(iParticle3);
	vDeleteEntity(iParticle3, 16.5);
	iTrace = EntIndexToEntRef(iTrace);
	vDeleteEntity(iTrace, 16.5);
	vDeleteParticle(iTrace, 16.5, "Stop");
	iExplosion = EntIndexToEntRef(iExplosion);
	vDeleteEntity(iExplosion, 16.5);
	iPhysics = EntIndexToEntRef(iPhysics);
	vDeleteEntity(iPhysics, 16.5);
	iHurt = EntIndexToEntRef(iHurt);
	vDeleteEntity(iHurt, 16.5);
	vDeleteParticle(iHurt, 15.0, "TurnOff");
}

stock void vCheatCommand(int client, char[] command, char[] arguments = "")
{
	int iCmdFlags = GetCommandFlags(command);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, iCmdFlags | FCVAR_CHEAT);
}

stock void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

stock void vCreateConfigFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "", bool main = false)
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	File fFilename;
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.cfg", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}
	fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		if (main)
		{
			fFilename.WriteLine("\"Super Tanks++\"");
			fFilename.WriteLine("{");
			fFilename.WriteLine("	// These are the general settings.");
			fFilename.WriteLine("	// Note: The following settings will not work in custom config files:");
			fFilename.WriteLine("	// \"Game Mode Types\"");
			fFilename.WriteLine("	// \"Enabled Game Modes\"");
			fFilename.WriteLine("	// \"Disabled Game Modes\"");
			fFilename.WriteLine("	// \"Enable Custom Configs\"");
			fFilename.WriteLine("	// \"Create Config Types\"");
			fFilename.WriteLine("	// \"Execute Config Types\"");
			fFilename.WriteLine("	\"General\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		// Enable Super Tanks++.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Plugin Enabled\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Enable Super Tanks++ in these game mode types.");
			fFilename.WriteLine("		// Add up numbers together for different results.");
			fFilename.WriteLine("		// 0: All game mode types.");
			fFilename.WriteLine("		// 1: Co-Op modes only.");
			fFilename.WriteLine("		// 2: Versus modes only.");
			fFilename.WriteLine("		// 4: Survival modes only.");
			fFilename.WriteLine("		// 8: Scavenge modes only. (Only available in Left 4 Dead 2.)");
			fFilename.WriteLine("		\"Game Mode Types\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Enable Super Tanks++ in these game modes.");
			fFilename.WriteLine("		// Separate game modes with commas.");
			fFilename.WriteLine("		// Game mode limit: 64");
			fFilename.WriteLine("		// Character limit for each game mode: 64");
			fFilename.WriteLine("		// Empty: All");
			fFilename.WriteLine("		// Not empty: Enabled only in these game modes.");
			fFilename.WriteLine("		\"Enabled Game Modes\"			\"\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Disable Super Tanks++ in these game modes.");
			fFilename.WriteLine("		// Separate game modes with commas.");
			fFilename.WriteLine("		// Game mode limit: 64");
			fFilename.WriteLine("		// Character limit for each game mode: 64");
			fFilename.WriteLine("		// Empty: None");
			fFilename.WriteLine("		// Not empty: Disabled only in these game modes.");
			fFilename.WriteLine("		\"Disabled Game Modes\"			\"\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Enable Super Tanks++ custom configuration.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Enable Custom Configs\"			\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The type of custom config that Super Tanks++ creates.");
			fFilename.WriteLine("		// Combine numbers in any order for different results.");
			fFilename.WriteLine("		// Character limit: 5");
			fFilename.WriteLine("		// 1: Difficulties");
			fFilename.WriteLine("		// 2: Maps");
			fFilename.WriteLine("		// 3: Game modes");
			fFilename.WriteLine("		// 4: Days");
			fFilename.WriteLine("		// 5: Player count");
			fFilename.WriteLine("		\"Create Config Types\"			\"12345\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The type of custom config that Super Tanks++ executes.");
			fFilename.WriteLine("		// Combine numbers in any order for different results.");
			fFilename.WriteLine("		// Character limit: 5");
			fFilename.WriteLine("		// 1: Difficulties");
			fFilename.WriteLine("		// 2: Maps");
			fFilename.WriteLine("		// 3: Game modes");
			fFilename.WriteLine("		// 4: Days");
			fFilename.WriteLine("		// 5: Player count");
			fFilename.WriteLine("		\"Execute Config Types\"			\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Announce each Super Tank's arrival.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Announce Arrival\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Display Tanks' names and health.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON, show names only.");
			fFilename.WriteLine("		// 2: ON, show health only.");
			fFilename.WriteLine("		// 3: ON, show both names and health.");
			fFilename.WriteLine("		\"Display Health\"				\"3\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Enable Super Tanks++ in finales only.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Finales Only\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Enable Super Tanks++ for human-controlled Tanks.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Human Super Tanks\"				\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Maximum types of Super Tanks allowed.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 1000");
			fFilename.WriteLine("		\"Maximum Types\"					\"66\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Multiply the Super Tank's health.");
			fFilename.WriteLine("		// 0: No changes to health.");
			fFilename.WriteLine("		// 1: Multiply original health only.");
			fFilename.WriteLine("		// 2: Multiply extra health only.");
			fFilename.WriteLine("		// 3: Multiply both.");
			fFilename.WriteLine("		\"Multiply Health\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Amount of Tanks to spawn for each finale wave.");
			fFilename.WriteLine("		// Separate waves with commas.");
			fFilename.WriteLine("		// Wave limit: 3");
			fFilename.WriteLine("		// Character limit for each wave: 3");
			fFilename.WriteLine("		// 1st number = 1st wave");
			fFilename.WriteLine("		// 2nd number = 2nd wave");
			fFilename.WriteLine("		// 3rd number = 3rd wave");
			fFilename.WriteLine("		\"Tank Waves\"					\"2,3,4\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// This is just an example that contains information for each setting or ability.");
			fFilename.WriteLine("	// This section is not used by the plugin in any way at all.");
			fFilename.WriteLine("	// Feel free to add your own notes here if you wish.");
			fFilename.WriteLine("	\"Example\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		// Name of the Super Tank.");
			fFilename.WriteLine("		// Character limit: 32");
			fFilename.WriteLine("		\"Tank Name\"						\"Tank 1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Enable the Super Tank.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Tank Enabled\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// These are the Super Tank's skin and glow outline colors.");
			fFilename.WriteLine("		// Separate colors with \"|\".");
			fFilename.WriteLine("		// Separate RGBAs with commas.");
			fFilename.WriteLine("		// 1st set = skin color (RGBA)");
			fFilename.WriteLine("		// 2nd set = glow color (RGB)");
			fFilename.WriteLine("		\"Skin-Glow Colors\"				\"255,255,255,255|255,255,255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Props that the Super Tank can spawn with.");
			fFilename.WriteLine("		// Combine numbers in any order for different results.");
			fFilename.WriteLine("		// Character limit: 5");
			fFilename.WriteLine("		// 1: attach lights only.");
			fFilename.WriteLine("		// 2: attach oxygen tanks only.");
			fFilename.WriteLine("		// 3: attach flames to oxygen tanks.");
			fFilename.WriteLine("		// 4: attach rocks only.");
			fFilename.WriteLine("		// 5: attach tires only.");
			fFilename.WriteLine("		\"Props Attached\"				\"12345\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Each prop has 1 of this many chances to appear when the Super Tank appears.");
			fFilename.WriteLine("		// Separate chances with commas.");
			fFilename.WriteLine("		// Chances limit: 5");
			fFilename.WriteLine("		// Character limit for each chance: 3");
			fFilename.WriteLine("		// 1st number = Chance for lights to appear.");
			fFilename.WriteLine("		// 2nd number = Chance for oxygen tanks to appear.");
			fFilename.WriteLine("		// 3rd number = Chance for oxygen tank flames to appear.");
			fFilename.WriteLine("		// 4th number = Chance for rocks to appear.");
			fFilename.WriteLine("		// 5th number = Chance for tires to appear.");
			fFilename.WriteLine("		\"Props Chance\"					\"3,3,3,3,3\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's prop colors.");
			fFilename.WriteLine("		// Separate colors with \"|\".");
			fFilename.WriteLine("		// Separate RGBAs with commas.");
			fFilename.WriteLine("		// 1st set = lights color (RGBA)");
			fFilename.WriteLine("		// 2nd set = oxygen tanks color (RGBA)");
			fFilename.WriteLine("		// 3rd set = oxygen tank flames color (RGBA)");
			fFilename.WriteLine("		// 4th set = rocks color (RGBA)");
			fFilename.WriteLine("		// 5th set = tires color (RGBA)");
			fFilename.WriteLine("		\"Props Colors\"					\"255,255,255,255|255,255,255,255|255,255,255,125|255,255,255,255|255,255,255,255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank will have a glow outline.");
			fFilename.WriteLine("		// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Glow Effect\"					\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank will spawn with a particle effect.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Particle Effect\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The particle effects for the Super Tank.");
			fFilename.WriteLine("		// Combine numbers in any order for different results.");
			fFilename.WriteLine("		// Character limit: 7");
			fFilename.WriteLine("		// 1: Blood Explosion");
			fFilename.WriteLine("		// 2: Electric Jolt");
			fFilename.WriteLine("		// 3: Fire Trail");
			fFilename.WriteLine("		// 4: Ice Steam");
			fFilename.WriteLine("		// 5: Meteor Smoke");
			fFilename.WriteLine("		// 6: Smoker Cloud");
			fFilename.WriteLine("		// 7: Spit Puddle (Only available in Left 4 Dead 2.)");
			fFilename.WriteLine("		\"Particle Effects\"				\"1234567\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank absorbs most of the damage it receives.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Absorb Ability\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to spawn acid puddles underneath survivors.");
			fFilename.WriteLine("		// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Acid Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can spawn acid puddles underneath survivors.");
			fFilename.WriteLine("		// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Acid Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's rock spawns acid puddles when it breaks.");
			fFilename.WriteLine("		// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Acid Rock Break\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to take away survivors' ammunition.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Ammo Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank sets survivors' ammunition to this amount.");
			fFilename.WriteLine("		// Minimum: 0");
			fFilename.WriteLine("		// Maximum: 25");
			fFilename.WriteLine("		\"Ammo Count\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can take away survivors' ammunition.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Ammo Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to blind survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Blind Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's blinding effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Blind Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can blind survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Blind Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The intensity of the Super Tank's blind effect.");
			fFilename.WriteLine("		// Minimum: 0 (No effect)");
			fFilename.WriteLine("		// Maximum: 255 (Fully blind)");
			fFilename.WriteLine("		\"Blind Intensity\"				\"255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to start explosions.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Bomb Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can start explosions.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Bomb Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's rock explodes when it breaks.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Bomb Rock Break\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Give the Super Tank bullet immunity.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Bullet Immunity\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to bury survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Bury Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's buries last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Bury Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank buries survivors this deep into the ground.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Bury Height\"					\"50.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can bury survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Bury Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can throw cars at survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Car Throw Ability\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can spawn common infected.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Common Ability\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank spawns this many common infected at once.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 100");
			fFilename.WriteLine("		\"Common Amount\"					\"10\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to drug survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Drug Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's drug effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Drug Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can drug survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Drug Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Give the Super Tank explosive immunity.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Explosive Immunity\"			\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Extra health given to the Super Tank.");
			fFilename.WriteLine("		// Note: Tank's health limit on any difficulty is 62,400.");
			fFilename.WriteLine("		// Note: Depending on the setting for \"Multiply Health,\" the Super Tank's health will be multiplied based on player count.");
			fFilename.WriteLine("		// Note: Health changes only occur when there are at least 2 alive non-idle human survivors.");
			fFilename.WriteLine("		// Minimum: 0");
			fFilename.WriteLine("		// Maximum: 62400");
			fFilename.WriteLine("		\"Extra Health\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to start fires.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Fire Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can start fires.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Fire Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Give the Super Tank fire immunity.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Fire Immunity\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's rock starts fires when it breaks.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Fire Rock Break\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can run really fast.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Flash Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to run really fast.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Flash Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's special speed.");
			fFilename.WriteLine("		// Minimum: 3.0");
			fFilename.WriteLine("		// Maximum: 8.0");
			fFilename.WriteLine("		\"Flash Speed\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to fling survivors into the air.");
			fFilename.WriteLine("		// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Fling Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can fling survivors into the air.");
			fFilename.WriteLine("		// Only available in Left 4 Dead 2.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Fling Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can cloak itself and other infected.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Ghost Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to disarm survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Ghost Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The limit of the Super Tank's ghost fade effect.");
			fFilename.WriteLine("		// Minimum: 0 (Fully faded)");
			fFilename.WriteLine("		// Maximum: 255 (No effect)");
			fFilename.WriteLine("		\"Ghost Fade Limit\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can disarm survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Ghost Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank disarms the following weapon slots.");
			fFilename.WriteLine("		// Combine numbers in any order for different results.");
			fFilename.WriteLine("		// Character limit: 5");
			fFilename.WriteLine("		// 1: 1st slot only.");
			fFilename.WriteLine("		// 2: 2nd slot only.");
			fFilename.WriteLine("		// 3: 3rd slot only.");
			fFilename.WriteLine("		// 4: 4th slot only.");
			fFilename.WriteLine("		// 5: 5th slot only.");
			fFilename.WriteLine("		\"Ghost Weapon Slots\"			\"12345\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can pull in or push away survivors and infected.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Gravity Ability\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to lower survivors' gravity.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Gravity Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's gravity effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Gravity Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's gravity force.");
			fFilename.WriteLine("		// Positive numbers = Push back");
			fFilename.WriteLine("		// Negative numbers = Pull in");
			fFilename.WriteLine("		// Minimum: -100.0");
			fFilename.WriteLine("		// Maximum: 100.0");
			fFilename.WriteLine("		\"Gravity Force\"					\"-50.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can lower survivors' gravity.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Gravity Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank sets the survivors' gravity to this value.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 0.99");
			fFilename.WriteLine("		\"Gravity Value\"					\"0.3\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can receive health from nearby infected.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Heal Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to set survivors to black and white with temporary health.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Heal Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank receives this much health from nearby common infected.");
			fFilename.WriteLine("		// Minimum: 0");
			fFilename.WriteLine("		// Maximum: 62400");
			fFilename.WriteLine("		\"Health From Commons\"			\"50\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can set survivors to black and white with temporary health.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Heal Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank receives health from nearby infected every time this many seconds passes.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Heal Interval\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank receives this much health from other nearby special infected.");
			fFilename.WriteLine("		// Minimum: 0");
			fFilename.WriteLine("		// Maximum: 62400");
			fFilename.WriteLine("		\"Health From Specials\"			\"100\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank receives this much health from other nearby Tanks.");
			fFilename.WriteLine("		// Minimum: 0");
			fFilename.WriteLine("		// Maximum: 62400");
			fFilename.WriteLine("		\"Health From Tanks\"				\"500\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can constantly hurt survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Hurt Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to constantly hurt survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Hurt Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's constant pain infliction does this much damage.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Hurt Damage\"					\"1\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's painful effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Hurt Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to hypnotize survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Hypno Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's hypnosis effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Hypno Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can hypnotize survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Hypno Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The mode of the Super Tank's hypno ability.");
			fFilename.WriteLine("		// 0: Hypnotized survivors hurt themselves.");
			fFilename.WriteLine("		// 1: Hypnotized survivors can hurt their teammates.");
			fFilename.WriteLine("		\"Hypno Mode\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to freeze survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Ice Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can freeze survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Ice Claw-Rock\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to make survivors go idle.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Idle Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can make survivors go idle.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Idle Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can throw these special infected.");
			fFilename.WriteLine("		// Combine numbers in any order for different results.");
			fFilename.WriteLine("		// Repeat the same number to increase its chance of being chosen.");
			fFilename.WriteLine("		// Character limit: 14");
			fFilename.WriteLine("		// 1: Smoker");
			fFilename.WriteLine("		// 2: Boomer");
			fFilename.WriteLine("		// 3: Hunter");
			fFilename.WriteLine("		// 4: Spitter (Switches to Boomer in L4D1.)");
			fFilename.WriteLine("		// 5: Jockey (Switches to Hunter in L4D1.)");
			fFilename.WriteLine("		// 6: Charger (Switches to Smoker in L4D1.)");
			fFilename.WriteLine("		// 7: Tank");
			fFilename.WriteLine("		\"Infected Options\"				\"1234567\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can throw special infected.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Infected Throw Ability\"		\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to invert survivors' movement keys.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Invert Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's inverted effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Invert Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can invert survivors' movement keys.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Invert Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can jump high into the air.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Jump Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to jump high into the air.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Jump Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Give the Super Tank melee immunity.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Melee Immunity\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can start meteor showers.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Meteor Ability\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to start meteor showers.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Meteor Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's meteorites do this much damage.");
			fFilename.WriteLine("		// Minimum: 1.0");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Meteor Damage\"					\"25.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to nullify survivors' damage.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Nullify Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's nullifier effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Nullify Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can nullify survivors' damage.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Nullify Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to start panic events.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Panic Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can start panic events.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Panic Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to puke on survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Puke Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can puke on survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Puke Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank gains a speed boost when on fire.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Pyro Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's speed boost value when on fire.");
			fFilename.WriteLine("		// Note: This is a speed boost, not the overall speed. (Current speed + Pyro boost)");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 3.0");
			fFilename.WriteLine("		\"Pyro Boost\"					\"1.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to make survivors restart at the spawn area.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Restart Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can make survivors restart at the spawn area.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Restart Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank makes survivors restart with this loadout.");
			fFilename.WriteLine("		// Item limit: 5");
			fFilename.WriteLine("		// Character limit for each item: 64");
			fFilename.WriteLine("		\"Restart Loadout\"				\"smg,pistol,pain_pills\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to send survivors into space.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Rocket Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can send survivors into space.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Rocket Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// Set the Super Tank's run speed.");
			fFilename.WriteLine("		// Note: Default run speed is 1.0.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 3.0");
			fFilename.WriteLine("		\"Run Speed\"						\"1.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can throw itself.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Self Throw Ability\"			\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to shake survivors' screens.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Shake Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's shake effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Shake Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can shake survivors' screens.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Shake Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can spawn with a shield.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Shield Ability\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// This is the Super Tank's shield's color.");
			fFilename.WriteLine("		// 1st number = Red");
			fFilename.WriteLine("		// 2nd number = Green");
			fFilename.WriteLine("		// 3rd number = Blue");
			fFilename.WriteLine("		\"Shield Color\"					\"255,255,255\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's shield reactivates after this many seconds passes.");
			fFilename.WriteLine("		// Minimum: 1.0");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Shield Delay\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to shove survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Shove Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's shove effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Shove Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can shove survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Shove Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to instantly kill survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Slug Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can instantly kill survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Slug Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can spam rocks at survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Spam Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank spams this many rocks at survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 100");
			fFilename.WriteLine("		\"Spam Amount\"					\"5\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's rocks do this much damage.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Spam Damage\"					\"5\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank spams rocks at survivors every time this many seconds passes.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Spam Interval\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to stun survivors.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Stun Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's stun effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Stun Duration\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can stun survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Stun Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank sets the survivors' run speed to this amount.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 0.99");
			fFilename.WriteLine("		\"Stun Speed\"					\"0.25\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's rock throw interval.");
			fFilename.WriteLine("		// Note: Default throw interval is 5.0 seconds.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Throw Interval\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to steal survivors' health.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Vampire Chance\"				\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank receives this much health from hitting survivors.");
			fFilename.WriteLine("		// Note: Tank's health limit on any difficulty is 62,400.");
			fFilename.WriteLine("		// Minimum: 0");
			fFilename.WriteLine("		// Maximum: 62400");
			fFilename.WriteLine("		\"Vampire Health\"				\"100\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can steal survivors' health.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Vampire Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank has 1 out of this many chances to change survivors' fields of view.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 99999");
			fFilename.WriteLine("		\"Vision Chance\"					\"4\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's visual effects last this long.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Vision Duration\"				\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank sets survivors' fields of view to this amount.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 160");
			fFilename.WriteLine("		\"Vision FOV\"					\"160\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can change survivors' fields of view.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Vision Claw-Rock\"				\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can warp to survivors.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Warp Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank warps to a random survivor every time this many seconds passes.");
			fFilename.WriteLine("		// Minimum: 0.1");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Warp Interval\"					\"5.0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can spawn Witch minions.");
			fFilename.WriteLine("		// 0: OFF");
			fFilename.WriteLine("		// 1: ON");
			fFilename.WriteLine("		\"Witch Ability\"					\"0\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank can spawn this many Witches at once.");
			fFilename.WriteLine("		// Minimum: 1");
			fFilename.WriteLine("		// Maximum: 25");
			fFilename.WriteLine("		\"Witch Amount\"					\"3\"");
			fFilename.WriteLine("");
			fFilename.WriteLine("		// The Super Tank's Witch minion causes this much damage per hit.");
			fFilename.WriteLine("		// Minimum: 1.0");
			fFilename.WriteLine("		// Maximum: 99999.0");
			fFilename.WriteLine("		\"Witch Minion Damage\"			\"10.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Super Tanks++ Samples");
			fFilename.WriteLine("	// These Tanks should not be used as-is because they are just meant to showcase each ability.");
			fFilename.WriteLine("	// Some of them may be too overpowered for players and bots.");
			fFilename.WriteLine("	// It is recommended to configure these settings based on your own liking.");
			fFilename.WriteLine("	\"Tank 1\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Absorber Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"50,90,150,255|50,90,150\"");
			fFilename.WriteLine("		\"Props Colors\"				\"10,10,10,255|10,10,10,255|10,10,10,125|10,10,10,255|10,10,10,255\"");
			fFilename.WriteLine("		\"Absorb Ability\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 2\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Acidic Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,255,125,255|0,255,125\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,0,0,255|255,0,0,255|255,0,0,125|255,0,0,255|255,0,0,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"7\"");
			fFilename.WriteLine("		\"Acid Chance\"				\"4\"");
			fFilename.WriteLine("		\"Acid Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Acid Rock Break\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 3\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Ammo Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"170,200,210,255|170,200,210\"");
			fFilename.WriteLine("		\"Props Colors\"				\"5,20,35,255|5,20,35,255|5,20,35,125|5,20,35,255|5,20,35,255\"");
			fFilename.WriteLine("		\"Ammo Chance\"				\"4\"");
			fFilename.WriteLine("		\"Ammo Count\"				\"0\"");
			fFilename.WriteLine("		\"Ammo Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 4\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Blind Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"5,0,105,255|5,0,105\"");
			fFilename.WriteLine("		\"Props Colors\"				\"30,20,0,255|30,20,0,255|30,20,0,125|30,20,0,255|30,20,0,255\"");
			fFilename.WriteLine("		\"Blind Chance\"				\"4\"");
			fFilename.WriteLine("		\"Blind Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Blind Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Blind Intensity\"			\"255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 5\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Bomber Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"100,0,0,255|100,0,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"15,15,15,255|15,15,15,255|15,15,15,125|15,15,15,255|15,15,15,255\"");
			fFilename.WriteLine("		\"Bomb Chance\"				\"4\"");
			fFilename.WriteLine("		\"Bomb Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Bomb Rock Break\"			\"1\"");
			fFilename.WriteLine("		\"Explosive Immunity\"		\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 6\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Bombshell Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,100,0,255|255,100,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,100,125,255|255,100,125,255|255,100,125,125|255,100,125,255|255,100,125,255\"");
			fFilename.WriteLine("		\"Explosive Immunity\"		\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 7\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Boomer Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"65,105,0,255|65,105,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"0,0,65,255|0,0,65,255|0,0,65,125|0,0,65,255|0,0,65,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"2\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 8\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Bulletproof Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"135,0,85,255|135,0,85\"");
			fFilename.WriteLine("		\"Props Colors\"				\"135,255,85,255|135,255,85,255|135,255,85,125|135,255,85,255|135,255,85,255\"");
			fFilename.WriteLine("		\"Bullet Immunity\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 9\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Burier Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,170,0,255|255,170,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"0,170,255,255|0,170,255,255|0,170,255,125|0,170,255,255|0,170,255,255\"");
			fFilename.WriteLine("		\"Bury Chance\"				\"4\"");
			fFilename.WriteLine("		\"Bury Duration\"				\"5.0\"");
			fFilename.WriteLine("		\"Bury Height\"				\"50.0\"");
			fFilename.WriteLine("		\"Bury Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 10\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Car Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,120,75,255|255,120,75\"");
			fFilename.WriteLine("		\"Props Colors\"				\"100,35,0,255|100,35,0,255|100,35,0,125|100,35,0,255|100,35,0,255\"");
			fFilename.WriteLine("		\"Car Throw Ability\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Throw Interval\"			\"10.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 11\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Charger Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"95,140,80,255|95,140,80\"");
			fFilename.WriteLine("		\"Props Colors\"				\"25,255,115,255|25,255,115,255|25,255,115,125|25,255,115,255|25,255,115,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"6\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 12\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Clone Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"10,25,205,255|10,25,205\"");
			fFilename.WriteLine("		\"Props Colors\"				\"140,40,255,255|140,40,255,255|140,40,255,125|140,40,255,255|140,40,255,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"7\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 13\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Common Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"165,205,175,255|165,205,175\"");
			fFilename.WriteLine("		\"Props Colors\"				\"190,255,250,255|190,255,250,255|190,255,250,125|190,255,250,255|190,255,250,255\"");
			fFilename.WriteLine("		\"Common Ability\"			\"1\"");
			fFilename.WriteLine("		\"Common Amount\"				\"10\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 14\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Drug Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,245,0,255|255,245,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"55,205,65,255|55,205,65,255|55,205,65,125|55,205,65,255|55,205,65,255\"");
			fFilename.WriteLine("		\"Drug Chance\"				\"4\"");
			fFilename.WriteLine("		\"Drug Duration\"				\"5.0\"");
			fFilename.WriteLine("		\"Drug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 15\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Fireproof Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"150,0,0,255|150,0,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,135,0,255|255,135,0,255|255,135,0,125|255,135,0,255|255,135,0,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"3\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Chance\"				\"4\"");
			fFilename.WriteLine("		\"Fire Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Fire Rock Break\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 16\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Flash Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,0,0,150|255,255,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,255,0,150|255,255,0,150|255,255,0,125|255,255,0,150|255,255,0,150\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"2\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Flash Ability\"				\"1\"");
			fFilename.WriteLine("		\"Flash Chance\"				\"4\"");
			fFilename.WriteLine("		\"Flash Speed\"				\"5.0\"");
			fFilename.WriteLine("		\"Run Speed\"					\"3.0\"");
			fFilename.WriteLine("		\"Throw Interval\"			\"99999.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 17\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Flinger Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"160,225,65,255|160,225,65\"");
			fFilename.WriteLine("		\"Props Colors\"				\"25,40,130,255|25,40,130,255|25,40,130,125|25,40,130,255|25,40,130,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fling Chance\"				\"4\"");
			fFilename.WriteLine("		\"Fling Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 18\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Ghost Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"50,50,50,150|50,50,50\"");
			fFilename.WriteLine("		\"Props Colors\"				\"150,150,150,150|150,150,150,150|150,150,150,125|150,150,150,150|150,150,150,150\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Ghost Ability\"				\"1\"");
			fFilename.WriteLine("		\"Ghost Chance\"				\"4\"");
			fFilename.WriteLine("		\"Ghost Fade Limit\"			\"0\"");
			fFilename.WriteLine("		\"Ghost Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Ghost Weapon Slots\"		\"12345\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 19\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Gravity Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"25,25,25,255|25,25,25\"");
			fFilename.WriteLine("		\"Props Colors\"				\"200,200,200,255|200,200,200,255|200,200,200,125|200,200,200,255|200,200,200,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Gravity Ability\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Chance\"			\"4\"");
			fFilename.WriteLine("		\"Gravity Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Gravity Force\"				\"-50.0\"");
			fFilename.WriteLine("		\"Gravity Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Value\"				\"0.3\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 20\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Health Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"75,200,75,255|75,200,75\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,255,255,255|255,255,255,255|255,255,255,125|255,255,255,255|255,255,255,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Heal Ability\"				\"1\"");
			fFilename.WriteLine("		\"Heal Chance\"				\"4\"");
			fFilename.WriteLine("		\"Health From Commons\"		\"50\"");
			fFilename.WriteLine("		\"Heal Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Heal Interval\"				\"5.0\"");
			fFilename.WriteLine("		\"Health From Specials\"		\"100\"");
			fFilename.WriteLine("		\"Health From Tanks\"			\"500\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 21\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Hunter Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,80,140,255|0,80,140\"");
			fFilename.WriteLine("		\"Props Colors\"				\"200,200,200,255|200,200,200,255|200,200,200,125|200,200,200,255|200,200,200,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"3\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 22\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Hurtful Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"80,255,255,255|80,255,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"150,150,150,255|150,150,150,255|150,150,150,125|150,150,150,255|150,150,150,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Hurt Ability\"				\"1\"");
			fFilename.WriteLine("		\"Hurt Chance\"				\"1\"");
			fFilename.WriteLine("		\"Hurt Damage\"				\"5\"");
			fFilename.WriteLine("		\"Hurt Duration\"				\"5.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 23\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Hypnotizer Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"110,0,130,255|110,0,130\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,250,45,255|255,250,45,255|255,250,45,125|255,250,45,255|255,250,45,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Hypno Chance\"				\"1\"");
			fFilename.WriteLine("		\"Hypno Duration\"			\"99999.0\"");
			fFilename.WriteLine("		\"Hypno Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Hypno Mode\"				\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 24\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Ice Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,155,255,200|0,155,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"170,240,255,200|170,240,255,200|170,240,255,125|170,240,255,200|170,240,255,200\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"4\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Ice Chance\"				\"4\"");
			fFilename.WriteLine("		\"Ice Claw-Rock\"				\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 25\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Idler Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"225,235,255,255|225,235,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"10,40,15,255|10,40,15,255|10,40,15,125|10,40,15,255|10,40,15,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Idle Chance\"				\"4\"");
			fFilename.WriteLine("		\"Idle Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 26\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Inverter Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,235,220,255|0,235,220\"");
			fFilename.WriteLine("		\"Props Colors\"				\"250,65,255,255|250,65,255,255|250,65,255,125|250,65,255,255|250,65,255,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Invert Chance\"				\"4\"");
			fFilename.WriteLine("		\"Invert Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Invert Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 27\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Jockey Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,235,235,255|255,235,235\"");
			fFilename.WriteLine("		\"Props Colors\"				\"130,0,0,255|130,0,0,255|130,0,0,125|130,0,0,255|130,0,0,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"5\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 28\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Jumper Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"225,215,0,255|225,215,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"225,0,205,255|225,0,205,255|225,0,205,125|225,0,205,255|225,0,205,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Jump Ability\"				\"1\"");
			fFilename.WriteLine("		\"Jump Chance\"				\"4\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 29\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Meteor Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"120,20,10,255|120,20,10\"");
			fFilename.WriteLine("		\"Props Colors\"				\"200,200,200,255|200,200,200,255|200,200,200,125|200,200,200,255|200,200,200,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"5\"");
			fFilename.WriteLine("		\"Explosive Immunity\"		\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Meteor Ability\"			\"1\"");
			fFilename.WriteLine("		\"Meteor Chance\"				\"4\"");
			fFilename.WriteLine("		\"Meteor Damage\"				\"25.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 30\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Nullifier Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,255,140,255|255,255,140\"");
			fFilename.WriteLine("		\"Props Colors\"				\"140,140,255,255|140,140,255,255|140,140,255,125|140,140,255,255|140,140,255,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Nullify Chance\"			\"4\"");
			fFilename.WriteLine("		\"Nullify Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Nullify Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 31\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Panic Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,0,255,255|255,100,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,100,0,255|255,100,0,255|255,100,0,125|255,100,0,255|255,100,0,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Panic Chance\"				\"4\"");
			fFilename.WriteLine("		\"Panic Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 32\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Platinum Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"110,175,255,255|110,50,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"110,50,255,255|110,50,255,255|110,50,255,125|110,50,255,255|110,50,255,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Melee Immunity\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 33\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Puke Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"170,180,45,255|170,180,45\"");
			fFilename.WriteLine("		\"Props Colors\"				\"140,0,0,255|140,0,0,255|140,0,0,125|140,0,0,255|140,0,0,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Puke Chance\"				\"4\"");
			fFilename.WriteLine("		\"Puke Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 34\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Pyro Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,35,0,255|255,35,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,180,0,255|255,180,0,255|255,180,0,125|255,180,0,255|255,180,0,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"3\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Pyro Ability\"				\"1\"");
			fFilename.WriteLine("		\"Pyro Boost\"				\"1.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 35\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Restarter Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"10,40,15,255|10,40,15\"");
			fFilename.WriteLine("		\"Props Colors\"				\"225,235,0,255|225,235,0,255|225,235,0,125|225,235,0,255|225,235,0,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Restart Chance\"			\"4\"");
			fFilename.WriteLine("		\"Restart Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Restart Loadout\"			\"smg,pistol,pain_pills\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 36\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Rocketeer Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"250,110,0,255|250,110,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,180,50,255|255,180,50,255|255,180,50,125|255,180,50,255|255,180,50,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Rocket Chance\"				\"4\"");
			fFilename.WriteLine("		\"Rocket Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 37\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Self-sacrificial Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"90,55,25,255|90,55,25\"");
			fFilename.WriteLine("		\"Props Colors\"				\"0,220,125,255|0,220,125,255|0,220,125,125|0,220,125,255|0,220,125,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Self Throw Ability\"		\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 38\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Shaker Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"100,25,25,255|100,25,25\"");
			fFilename.WriteLine("		\"Props Colors\"				\"0,170,255,255|0,170,255,255|0,170,255,125|0,170,255,255|0,170,255,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Shake Chance\"				\"4\"");
			fFilename.WriteLine("		\"Shake Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Shake Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 39\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Shield Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"135,205,255,255|135,205,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"25,125,125,255|25,125,125,255|25,125,125,125|25,125,125,255|25,125,125,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Shield Ability\"			\"1\"");
			fFilename.WriteLine("		\"Shield Color\"				\"25,125,125\"");
			fFilename.WriteLine("		\"Shield Delay\"				\"7.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 40\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Shove Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"10,100,0,255|10,100,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"25,10,0,255|25,10,0,255|25,10,0,125|25,10,0,255|25,10,0,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Shove Chance\"				\"4\"");
			fFilename.WriteLine("		\"Shove Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Shove Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 41\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Slugger Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"100,165,255,255|100,165,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"0,0,50,255|0,0,50,255|0,0,50,125|0,0,50,255|0,0,50,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Run Speed\"					\"0.25\"");
			fFilename.WriteLine("		\"Slug Chance\"				\"4\"");
			fFilename.WriteLine("		\"Slug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 42\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Smoker Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"150,0,150,255|150,0,150\"");
			fFilename.WriteLine("		\"Props Colors\"				\"200,100,145,255|200,100,145,255|200,100,145,125|200,100,145,255|200,100,145,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"6\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"1\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 43\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Spammer Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"130,65,0,255|130,65,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"20,20,20,255|20,20,20,255|20,20,20,125|20,20,20,255|20,20,20,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Spam Ability\"				\"1\"");
			fFilename.WriteLine("		\"Spam Amount\"				\"5\"");
			fFilename.WriteLine("		\"Spam Damage\"				\"5\"");
			fFilename.WriteLine("		\"Spam Interval\"				\"5.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 44\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Special Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,175,125,255|0,175,125\"");
			fFilename.WriteLine("		\"Props Colors\"				\"165,175,125,255|165,175,125,255|165,175,125,125|165,175,125,255|165,175,125,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"123456\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 45\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Spitter Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,200,0,255|0,200,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,80,150,255|255,80,150,255|255,80,150,125|255,80,150,255|255,80,150,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"7\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Infected Options\"			\"4\"");
			fFilename.WriteLine("		\"Infected Throw Ability\"	\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 46\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Stun Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"80,130,255,255|80,130,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,185,45,255|255,185,45,255|255,185,45,125|255,185,45,255|255,185,45,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Stun Chance\"				\"4\"");
			fFilename.WriteLine("		\"Stun Duration\"				\"5.0\"");
			fFilename.WriteLine("		\"Stun Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Stun Speed\"				\"0.25\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 47\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Vampire Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"180,0,70,255|180,0,70\"");
			fFilename.WriteLine("		\"Props Colors\"				\"70,210,70,255|70,210,70,255|70,210,70,125|70,210,70,255|70,210,70,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Vampire Chance\"			\"4\"");
			fFilename.WriteLine("		\"Vampire Health\"			\"100\"");
			fFilename.WriteLine("		\"Vampire Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 48\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Visual Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"175,25,205,255|175,25,205\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,40,10,255|255,40,10,255|255,40,10,125|255,40,10,255|255,40,10,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Vision Chance\"				\"4\"");
			fFilename.WriteLine("		\"Vision Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Vision FOV\"				\"160\"");
			fFilename.WriteLine("		\"Vision Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 49\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Warp Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"130,130,255,255|130,130,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"225,100,0,255|225,100,0,255|225,100,0,125|225,100,0,255|225,100,0,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"2\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Throw Interval\"			\"99999.0\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"5.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 50\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Witch Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,145,255,255|255,145,255\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,210,80,255|255,210,80,255|255,210,80,125|255,210,80,255|255,210,80,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Witch Ability\"				\"1\"");
			fFilename.WriteLine("		\"Witch Amount\"				\"3\"");
			fFilename.WriteLine("		\"Witch Minion Damage\"		\"10.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Super Tanks and Super Tanks+ Tanks");
			fFilename.WriteLine("	// Most of the Tank combos from ST+ are already recreated above.");
			fFilename.WriteLine("	\"Tank 51\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Armageddon Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"75,0,0,255|75,0,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"35,35,35,255|35,35,35,255|35,35,35,125|35,35,35,255|35,35,35,255\"");
			fFilename.WriteLine("		\"Explosive Immunity\"		\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Gravity Ability\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Force\"				\"-50.0\"");
			fFilename.WriteLine("		\"Meteor Ability\"			\"1\"");
			fFilename.WriteLine("		\"Meteor Damage\"				\"25.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 52\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Boss Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,0,50,255|0,0,50\"");
			fFilename.WriteLine("		\"Props Colors\"				\"30,30,30,255|30,30,30,255|30,30,30,125|30,30,30,255|30,30,30,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"1234567\"");
			fFilename.WriteLine("		\"Absorb Ability\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Common Ability\"			\"1\"");
			fFilename.WriteLine("		\"Common Amount\"				\"50\"");
			fFilename.WriteLine("		\"Flash Ability\"				\"1\"");
			fFilename.WriteLine("		\"Flash Speed\"				\"4.5\"");
			fFilename.WriteLine("		\"Ghost Ability\"				\"1\"");
			fFilename.WriteLine("		\"Ghost Chance\"				\"3\"");
			fFilename.WriteLine("		\"Ghost Fade Limit\"			\"0\"");
			fFilename.WriteLine("		\"Ghost Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Ghost Weapon Slots\"		\"123\"");
			fFilename.WriteLine("		\"Gravity Ability\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Chance\"			\"3\"");
			fFilename.WriteLine("		\"Gravity Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Gravity Force\"				\"-75.0\"");
			fFilename.WriteLine("		\"Gravity Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Value\"				\"0.4\"");
			fFilename.WriteLine("		\"Jump Ability\"				\"1\"");
			fFilename.WriteLine("		\"Jump Chance\"				\"6\"");
			fFilename.WriteLine("		\"Meteor Ability\"			\"1\"");
			fFilename.WriteLine("		\"Meteor Damage\"				\"25.0\"");
			fFilename.WriteLine("		\"Shield Ability\"			\"1\"");
			fFilename.WriteLine("		\"Shield Color\"				\"0,0,50\"");
			fFilename.WriteLine("		\"Shield Delay\"				\"4.5\"");
			fFilename.WriteLine("		\"Slug Chance\"				\"5\"");
			fFilename.WriteLine("		\"Slug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Spam Ability\"				\"1\"");
			fFilename.WriteLine("		\"Spam Amount\"				\"10\"");
			fFilename.WriteLine("		\"Spam Damage\"				\"10\"");
			fFilename.WriteLine("		\"Spam Interval\"				\"7.5\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"5.0\"");
			fFilename.WriteLine("		\"Witch Ability\"				\"1\"");
			fFilename.WriteLine("		\"Witch Amount\"				\"10\"");
			fFilename.WriteLine("		\"Witch Minion Damage\"		\"25.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 53\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Distraction Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"225,225,0,255|225,225,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"25,0,0,255|25,0,0,255|25,0,0,125|25,0,0,255|25,0,0,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Jump Ability\"				\"1\"");
			fFilename.WriteLine("		\"Jump Interval\"				\"3\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"3.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 54\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Feedback Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"90,60,90,255|90,60,90\"");
			fFilename.WriteLine("		\"Props Colors\"				\"90,90,60,255|90,90,60,255|90,90,60,125|90,90,60,255|90,90,60,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"2\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Gravity Ability\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Force\"				\"50.0\"");
			fFilename.WriteLine("		\"Stun Speed\"				\"0.5\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 55\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Goliath Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,0,100,255|0,0,100\"");
			fFilename.WriteLine("		\"Props Colors\"				\"25,25,25,255|25,25,25,255|25,25,25,125|25,25,25,255|25,25,25,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Heal Ability\"				\"1\"");
			fFilename.WriteLine("		\"Heal Interval\"				\"3.0\"");
			fFilename.WriteLine("		\"Health From Commons\"		\"250\"");
			fFilename.WriteLine("		\"Health From Specials\"		\"750\"");
			fFilename.WriteLine("		\"Health From Tanks\"			\"1250\"");
			fFilename.WriteLine("		\"Run Speed\"					\"0.5\"");
			fFilename.WriteLine("		\"Shield Ability\"			\"1\"");
			fFilename.WriteLine("		\"Shield Color\"				\"0,0,100\"");
			fFilename.WriteLine("		\"Shield Delay\"				\"7.5\"");
			fFilename.WriteLine("		\"Slug Chance\"				\"4\"");
			fFilename.WriteLine("		\"Slug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 56\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Hallucination Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"50,50,50,0|50,50,50\"");
			fFilename.WriteLine("		\"Props Colors\"				\"50,50,50,0|50,50,50,0|50,50,50,0|50,50,50,0|50,50,50,0\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Ghost Ability\"				\"1\"");
			fFilename.WriteLine("		\"Ghost Chance\"				\"3\"");
			fFilename.WriteLine("		\"Ghost Fade Limit\"			\"0\"");
			fFilename.WriteLine("		\"Ghost Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Ghost Weapon Slots\"		\"123\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"3.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 57\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Meme Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,255,0,255|0,255,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"225,0,255,255|225,0,255,255|225,0,255,125|225,0,255,255|225,0,255,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"1234567\"");
			fFilename.WriteLine("		\"Absorb Ability\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Common Ability\"			\"1\"");
			fFilename.WriteLine("		\"Common Amount\"				\"50\"");
			fFilename.WriteLine("		\"Flash Ability\"				\"1\"");
			fFilename.WriteLine("		\"Flash Speed\"				\"3.0\"");
			fFilename.WriteLine("		\"Ghost Ability\"				\"1\"");
			fFilename.WriteLine("		\"Ghost Chance\"				\"3\"");
			fFilename.WriteLine("		\"Ghost Fade Limit\"			\"0\"");
			fFilename.WriteLine("		\"Ghost Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Ghost Weapon Slots\"		\"123\"");
			fFilename.WriteLine("		\"Gravity Ability\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Chance\"			\"3\"");
			fFilename.WriteLine("		\"Gravity Duration\"			\"5.0\"");
			fFilename.WriteLine("		\"Gravity Force\"				\"-25.0\"");
			fFilename.WriteLine("		\"Gravity Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Gravity Value\"				\"0.4\"");
			fFilename.WriteLine("		\"Jump Ability\"				\"1\"");
			fFilename.WriteLine("		\"Jump Chance\"				\"3\"");
			fFilename.WriteLine("		\"Meteor Ability\"			\"1\"");
			fFilename.WriteLine("		\"Meteor Damage\"				\"1.0\"");
			fFilename.WriteLine("		\"Slug Chance\"				\"5\"");
			fFilename.WriteLine("		\"Slug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Spam Ability\"				\"1\"");
			fFilename.WriteLine("		\"Spam Amount\"				\"1\"");
			fFilename.WriteLine("		\"Spam Damage\"				\"1\"");
			fFilename.WriteLine("		\"Spam Interval\"				\"1.0\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"3.0\"");
			fFilename.WriteLine("		\"Witch Ability\"				\"1\"");
			fFilename.WriteLine("		\"Witch Amount\"				\"5\"");
			fFilename.WriteLine("		\"Witch Minion Damage\"		\"1.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 58\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Mirage Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"25,40,25,255|25,40,25\"");
			fFilename.WriteLine("		\"Props Colors\"				\"25,40,25,255|25,40,25,255|25,40,25,125|25,40,25,255|25,40,25,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Flash Ability\"				\"1\"");
			fFilename.WriteLine("		\"Flash Chance\"				\"3\"");
			fFilename.WriteLine("		\"Flash Speed\"				\"5.5\"");
			fFilename.WriteLine("		\"Run Speed\"					\"3.0\"");
			fFilename.WriteLine("		\"Throw Interval\"			\"99999.0\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"3.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 59\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Poltergeist Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"100,50,50,255|100,50,50\"");
			fFilename.WriteLine("		\"Props Colors\"				\"50,100,50,255|50,100,50,255|50,100,50,125|50,100,50,255|50,100,50,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Flash Ability\"				\"1\"");
			fFilename.WriteLine("		\"Flash Chance\"				\"3\"");
			fFilename.WriteLine("		\"Flash Speed\"				\"7.0\"");
			fFilename.WriteLine("		\"Ghost Ability\"				\"1\"");
			fFilename.WriteLine("		\"Ghost Chance\"				\"3\"");
			fFilename.WriteLine("		\"Ghost Fade Limit\"			\"0\"");
			fFilename.WriteLine("		\"Ghost Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Ghost Weapon Slots\"		\"123\"");
			fFilename.WriteLine("		\"Run Speed\"					\"3.0\"");
			fFilename.WriteLine("		\"Throw Interval\"			\"99999.0\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"3.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 60\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Psychotic Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"0,0,0,255|255,0,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,0,0,255|255,0,0,255|255,0,0,125|255,0,0,255|255,0,0,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"12\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Heal Ability\"				\"1\"");
			fFilename.WriteLine("		\"Heal Interval\"				\"5.0\"");
			fFilename.WriteLine("		\"Health From Commons\"		\"100\"");
			fFilename.WriteLine("		\"Health From Specials\"		\"500\"");
			fFilename.WriteLine("		\"Health From Tanks\"			\"1000\"");
			fFilename.WriteLine("		\"Jump Ability\"				\"1\"");
			fFilename.WriteLine("		\"Jump Chance\"				\"3\"");
			fFilename.WriteLine("		\"Meteor Ability\"			\"1\"");
			fFilename.WriteLine("		\"Meteor Damage\"				\"25.0\"");
			fFilename.WriteLine("		\"Shield Ability\"			\"1\"");
			fFilename.WriteLine("		\"Shield Color\"				\"255,0,0\"");
			fFilename.WriteLine("		\"Shield Delay\"				\"8.0\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"8.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 61\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Reverse Flash Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"255,255,0,150|255,0,0\"");
			fFilename.WriteLine("		\"Props Colors\"				\"255,0,0,150|255,0,0,150|255,0,0,125|255,0,0,150|255,0,0,150\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"2\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Flash Ability\"				\"1\"");
			fFilename.WriteLine("		\"Flash Chance\"				\"3\"");
			fFilename.WriteLine("		\"Flash Speed\"				\"6.5\"");
			fFilename.WriteLine("		\"Run Speed\"					\"3.0\"");
			fFilename.WriteLine("		\"Throw Interval\"			\"99999.0\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"5.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 62\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Smasher Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"70,80,100,255|70,80,100\"");
			fFilename.WriteLine("		\"Props Colors\"				\"130,65,0,255|130,65,0,255|130,65,0,125|130,65,0,255|130,65,0,255\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Run Speed\"					\"0.65\"");
			fFilename.WriteLine("		\"Slug Chance\"				\"6\"");
			fFilename.WriteLine("		\"Slug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 63\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Spawner Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"75,95,105,255|75,95,105\"");
			fFilename.WriteLine("		\"Props Colors\"				\"100,100,100,255|100,100,100,255|100,100,100,125|100,100,100,255|100,100,100,255\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"6\"");
			fFilename.WriteLine("		\"Common Ability\"			\"1\"");
			fFilename.WriteLine("		\"Common Amount\"				\"25\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 64\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Zoom Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"45,45,45,150|65,135,245\"");
			fFilename.WriteLine("		\"Props Colors\"				\"65,135,245,150|65,135,245,150|65,135,245,125|65,135,245,150|65,135,245,150\"");
			fFilename.WriteLine("		\"Particle Effect\"			\"1\"");
			fFilename.WriteLine("		\"Particle Effects\"			\"2\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Fire Immunity\"				\"1\"");
			fFilename.WriteLine("		\"Flash Ability\"				\"1\"");
			fFilename.WriteLine("		\"Flash Chance\"				\"2\"");
			fFilename.WriteLine("		\"Flash Speed\"				\"7.5\"");
			fFilename.WriteLine("		\"Run Speed\"					\"3.0\"");
			fFilename.WriteLine("		\"Throw Interval\"			\"99999.0\"");
			fFilename.WriteLine("		\"Warp Ability\"				\"1\"");
			fFilename.WriteLine("		\"Warp Interval\"				\"3.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Last Boss Extended Tanks");
			fFilename.WriteLine("	// Most of the Tanks from LBE are already recreated above.");
			fFilename.WriteLine("	\"Tank 65\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Dread Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"90,90,90,255|90,90,90\"");
			fFilename.WriteLine("		\"Props Colors\"				\"165,165,165,255|165,165,165,255|165,165,165,125|165,165,165,255|165,165,165,255\"");
			fFilename.WriteLine("		\"Blind Chance\"				\"1\"");
			fFilename.WriteLine("		\"Blind Duration\"			\"7.5\"");
			fFilename.WriteLine("		\"Blind Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Blind Intensity\"			\"235\"");
			fFilename.WriteLine("		\"Drug Chance\"				\"1\"");
			fFilename.WriteLine("		\"Drug Duration\"				\"2.0\"");
			fFilename.WriteLine("		\"Drug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	\"Tank 66\"");
			fFilename.WriteLine("	{");
			fFilename.WriteLine("		\"Tank Name\"					\"Rabid Tank\"");
			fFilename.WriteLine("		\"Tank Enabled\"				\"1\"");
			fFilename.WriteLine("		\"Skin-Glow Colors\"			\"175,50,95,255|175,50,95\"");
			fFilename.WriteLine("		\"Props Colors\"				\"0,165,165,255|0,165,165,255|0,165,165,125|0,165,165,255|0,165,165,255\"");
			fFilename.WriteLine("		\"Drug Chance\"				\"1\"");
			fFilename.WriteLine("		\"Drug Duration\"				\"5.0\"");
			fFilename.WriteLine("		\"Drug Claw-Rock\"			\"1\"");
			fFilename.WriteLine("		\"Extra Health\"				\"1000\"");
			fFilename.WriteLine("		\"Hurt Ability\"				\"1\"");
			fFilename.WriteLine("		\"Hurt Chance\"				\"1\"");
			fFilename.WriteLine("		\"Hurt Damage\"				\"5\"");
			fFilename.WriteLine("		\"Hurt Duration\"				\"5.0\"");
			fFilename.WriteLine("	}");
			fFilename.WriteLine("	// Create your own Super Tanks below.");
			fFilename.WriteLine("}");
		}
		else
		{
			fFilename.WriteLine("// This config file was auto-generated by Super Tanks++ v%s (%s)", ST_VERSION, ST_URL);
			fFilename.WriteLine("");
			fFilename.WriteLine("");
		}
		delete fFilename;
	}
}

stock void vCreateParticle(int client, char[] particlename, float time, float origin)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Start");
			SetVariantString("!activator");
			AcceptEntityInput(iParticle, "SetParent", client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

stock void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

stock void vDeleteParticle(int entity, float time, char[] input)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, input);
	}
}

stock void vDropWeapon(int client, int slot)
{
	if (bIsSurvivor(client) && GetPlayerWeaponSlot(client, slot) > 0)
	{
		SDKHooks_DropWeapon(client, GetPlayerWeaponSlot(client, slot), NULL_VECTOR, NULL_VECTOR);
	}
}

stock void vFire(int client, float pos[3])
{
	int iFire = CreateEntityByName("prop_physics");
	if (IsValidEntity(iFire))
	{
		DispatchKeyValue(iFire, "disableshadows", "1");
		SetEntityModel(iFire, MODEL_GASCAN);
		pos[2] += 10.0;
		TeleportEntity(iFire, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iFire);
		SetEntPropEnt(iFire, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(iFire, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
		SetEntProp(iFire, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iFire, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iFire, 0, 0, 0, 0);
		AcceptEntityInput(iFire, "Break");
	}
}

public void vGamemode(const char[] output, int caller, int activator, float delay)
{
	if (strcmp(output, "OnCoop") == 0)
	{
		g_iCurrentMode = 1;
	}
	else if (strcmp(output, "OnVersus") == 0)
	{
		g_iCurrentMode = 2;
	}
	else if (strcmp(output, "OnSurvival") == 0)
	{
		g_iCurrentMode = 4;
	}
	else if (strcmp(output, "OnScavenge") == 0)
	{
		g_iCurrentMode = 8;
	}
}

stock void vIdleWarp(int client)
{
	float flCurrentOrigin[3] = {0.0, 0.0, 0.0};
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!bIsSurvivor(iPlayer) || iPlayer == client)
		{
			continue;
		}
		GetClientAbsOrigin(iPlayer, flCurrentOrigin);
		TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
	}
}

stock void vKickFakeClient(int client)
{
	if (IsFakeClient(client))
	{
		KickClient(client);
	}
}

stock void vMultiTargetFilters(int toggle)
{
	switch (toggle)
	{
		case 0:
		{
			RemoveMultiTargetFilter("@smokers", bSmokerFilter);
			RemoveMultiTargetFilter("@boomers", bBoomerFilter);
			RemoveMultiTargetFilter("@hunters", bHunterFilter);
			RemoveMultiTargetFilter("@spitters", bSpitterFilter);
			RemoveMultiTargetFilter("@jockeys", bJockeyFilter);
			RemoveMultiTargetFilter("@chargers", bChargerFilter);
			RemoveMultiTargetFilter("@tanks", bTankFilter);
		}
		case 1:
		{
			AddMultiTargetFilter("@smokers", bSmokerFilter, "all Smokers", false);
			AddMultiTargetFilter("@boomers", bBoomerFilter, "all Boomers", false);
			AddMultiTargetFilter("@hunters", bHunterFilter, "all Hunters", false);
			AddMultiTargetFilter("@spitters", bSpitterFilter, "all Spitters", false);
			AddMultiTargetFilter("@jockeys", bJockeyFilter, "all Jockeys", false);
			AddMultiTargetFilter("@chargers", bChargerFilter, "all Chargers", false);
			AddMultiTargetFilter("@tanks", bTankFilter, "all Tanks", false);
		}
	}
}

stock void vPrecacheParticle(char[] particlename)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(iParticle))
	{
		DispatchKeyValue(iParticle, "effect_name", particlename);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "Start");
		SetVariantString("!activator");
		AcceptEntityInput(iParticle, "SetParent", iParticle);
		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle);
	}
}

stock void vSetVector(float target[3], float x, float y, float z)
{
	target[0] = x;
	target[1] = y;
	target[2] = z;
}

stock void vSpawnInfected(int client, char[] infected, bool auto = true)
{
	ChangeClientTeam(client, 3);
	char sOptions[32];
	Format(sOptions, sizeof(sOptions), "%s%s", infected, (auto ? " auto" : ""));
	bIsL4D2Game() ? vCheatCommand(client, "z_spawn_old", sOptions) : vCheatCommand(client, "z_spawn", sOptions);
	vKickFakeClient(client);
}

stock void vSpawnTank(int wave)
{
	if (iGetTankCount() < wave)
	{
		int iTank = CreateFakeClient("Tank");
		if (iTank > 0)
		{
			vSpawnInfected(iTank, "tank", true);
		}
	}
}

stock void vWarpEntity(int client, bool different = false, bool effect = false)
{
	int iTarget = iGetRandomSurvivor(client, different);
	if (iTarget > 0)
	{
		float flOrigin[3];
		float flAngles[3];
		GetClientAbsOrigin(iTarget, flOrigin);
		GetClientAbsAngles(iTarget, flAngles);
		if (effect)
		{
			vCreateParticle(client, PARTICLE_ELECTRICITY, 1.0, 0.0);
		}
		TeleportEntity(client, flOrigin, flAngles, NULL_VECTOR);
	}
}
