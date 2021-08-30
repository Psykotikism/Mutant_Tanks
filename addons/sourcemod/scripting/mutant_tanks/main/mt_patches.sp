/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2021  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if !defined MT_CORE_MAIN
	#error This file must be inside "scripting/mutant_tanks/main" while compiling "mutant_tanks.sp" to work.
#endif

Address g_adPatchAddress[MT_PATCH_LIMIT];

bool g_bPatchInstalled[MT_PATCH_LIMIT], g_bPatchLog[MT_PATCH_LIMIT], g_bPermanentPatch[MT_PATCH_LIMIT], g_bUpdateMemAccess[MT_PATCH_LIMIT] = {true, ...}, g_bUpdateMemAccess2 = true;

char g_sPatchName[MT_PATCH_LIMIT][128];

int g_iOriginalBytes[MT_PATCH_LIMIT][MT_PATCH_MAXLEN], g_iPatchBytes[MT_PATCH_LIMIT][MT_PATCH_MAXLEN], g_iPatchCount = 0, g_iPatchLength[MT_PATCH_LIMIT], g_iPatchOffset[MT_PATCH_LIMIT];

void vInstallPermanentPatches()
{
	for (int iPos = 0; iPos < g_iPatchCount; iPos++)
	{
		if (g_sPatchName[iPos][0] != '\0' && g_bPermanentPatch[iPos] && !g_bPatchInstalled[iPos])
		{
			bInstallPatch(iPos, true);
		}
	}
}

void vRemovePermanentPatches()
{
	for (int iPos = 0; iPos < g_iPatchCount; iPos++)
	{
		if (g_sPatchName[iPos][0] != '\0' && g_bPermanentPatch[iPos] && g_bPatchInstalled[iPos])
		{
			bRemovePatch(iPos, true);
		}
	}
}

void vRegisterPatches(GameData dataHandle)
{
	g_iPatchCount = 0;

	char sFilePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sFilePath, sizeof sFilePath, "%smutant_tanks_patches.cfg", MT_CONFIG_PATH);
	if (!MT_FileExists(MT_CONFIG_PATH, "mutant_tanks_patches.cfg", sFilePath, sFilePath, sizeof sFilePath))
	{
		LogError("%s Unable to load the \"%s\" config file.", MT_TAG, sFilePath);

		return;
	}

	KeyValues kvPatches = new KeyValues("MTPatches");
	if (!kvPatches.ImportFromFile(sFilePath))
	{
		LogError("%s Unable to read the \"%s\" config file.", MT_TAG, sFilePath);

		delete kvPatches;
		return;
	}

	if (g_bSecondGame)
	{
		if (!kvPatches.JumpToKey("left4dead2"))
		{
			delete kvPatches;
			return;
		}
	}
	else
	{
		if (!kvPatches.JumpToKey("left4dead"))
		{
			delete kvPatches;
			return;
		}
	}

	if (!kvPatches.GotoFirstSubKey())
	{
		LogError("%s The \"%s\" config file contains invalid data.", MT_TAG, sFilePath);

		delete kvPatches;
		return;
	}

	bool bPlatform = false;
	char sOS[8], sName[128], sSignature[128], sOffset[128], sVerify[192], sSet[MT_PATCH_MAXLEN][2], sPatch[192], sSet2[MT_PATCH_MAXLEN][2], sLog[4], sCvar[320], sCvarSet[10][32], sType[10];
	int iVerify[MT_PATCH_MAXLEN], iVLength = 0, iPatch[MT_PATCH_MAXLEN], iPLength = 0;
	do
	{
		kvPatches.GetSectionName(sName, sizeof sName);
		kvPatches.GetString("log", sLog, sizeof sLog);
		kvPatches.GetString("cvarcheck", sCvar, sizeof sCvar);
		kvPatches.GetString("type", sType, sizeof sType);
		kvPatches.GetString("signature", sSignature, sizeof sSignature);
		kvPatches.GetString("offset", sOffset, sizeof sOffset);

		switch (g_esGeneral.g_bLinux)
		{
			case true: sOS = "Linux";
			case false: sOS = "Windows";
		}

		if (kvPatches.JumpToKey(sOS))
		{
			bPlatform = true;

			kvPatches.GetString("verify", sVerify, sizeof sVerify);
			kvPatches.GetString("patch", sPatch, sizeof sPatch);
			kvPatches.GoBack();
		}

		if (sName[0] == '\0' || (!StrEqual(sLog, "yes") && !StrEqual(sLog, "no")) || (!StrEqual(sType, "permanent") && !StrEqual(sType, "ondemand") && !StrEqual(sType, "unused")) || sSignature[0] == '\0' || (bPlatform && (sVerify[0] == '\0' || sPatch[0] == '\0')))
		{
			LogError("%s The \"%s\" config file contains invalid data.", MT_TAG, sFilePath);

			continue;
		}

		if ((!bPlatform && (sOffset[0] != '\0' || sVerify[0] == '\0' || sPatch[0] == '\0')) || StrEqual(sType, "unused"))
		{
			if (sLog[0] == 'y')
			{
				vLogMessage(-1, _, "%s No patch for \"%s\" on %s was found.", MT_TAG, sName, sOS);
			}

			continue;
		}

		bPlatform = false;

		if (sCvar[0] != '\0')
		{
			ExplodeString(sCvar, ",", sCvarSet, sizeof sCvarSet, sizeof sCvarSet[]);
			for (int iPos = 0; iPos < sizeof sCvarSet; iPos++)
			{
				if (sCvarSet[iPos][0] != '\0')
				{
					g_esGeneral.g_cvMTTempSetting = FindConVar(sCvarSet[iPos]);
					if (g_esGeneral.g_cvMTTempSetting != null)
					{
						if (sLog[0] == 'y')
						{
							vLogMessage(-1, _, "%s The \"%s\" convar was found; skipping \"%s\".", MT_TAG, sCvarSet[iPos], sName);
						}

						break;
					}
				}
			}

			if (g_esGeneral.g_cvMTTempSetting != null)
			{
				g_esGeneral.g_cvMTTempSetting = null;

				continue;
			}
		}

		if (sLog[0] == 'y')
		{
			vLogMessage(-1, _, "%s Reading bytes for \"%s\": %s - %s", MT_TAG, sName, sVerify, sPatch);
		}

		ReplaceString(sVerify, sizeof sVerify, "\\x", " ", false);
		TrimString(sVerify);
		iVLength = ExplodeString(sVerify, " ", sSet, sizeof sSet, sizeof sSet[]);

		ReplaceString(sPatch, sizeof sPatch, "\\x", " ", false);
		TrimString(sPatch);
		iPLength = ExplodeString(sPatch, " ", sSet2, sizeof sSet2, sizeof sSet2[]);

		if (sLog[0] == 'y')
		{
			vLogMessage(-1, _, "%s Storing bytes for \"%s\": %s - %s", MT_TAG, sName, sVerify, sPatch);
		}

		for (int iPos = 0; iPos < MT_PATCH_MAXLEN; iPos++)
		{
			switch (iPos < iVLength)
			{
				case true: iVerify[iPos] = (iGetDecimalFromHex(sVerify[iPos * 3]) << 4) + iGetDecimalFromHex(sVerify[(iPos * 3) + 1]);
				case false: iVerify[iPos] = 0;
			}
		}

		for (int iPos = 0; iPos < MT_PATCH_MAXLEN; iPos++)
		{
			switch (iPos < iPLength)
			{
				case true: iPatch[iPos] = (iGetDecimalFromHex(sPatch[iPos * 3]) << 4) + iGetDecimalFromHex(sPatch[(iPos * 3) + 1]);
				case false: iPatch[iPos] = 0;
			}
		}

		bRegisterPatch(dataHandle, sName, sSignature, sOffset, iVerify, iVLength, iPatch, iPLength, (sLog[0] == 'y'), (sType[0] == 'p'));
	}
	while (kvPatches.GotoNextKey());

	vLogMessage(-1, _, "%s Registered %i patches.", MT_TAG, g_iPatchCount);

	delete kvPatches;
}

bool bInstallPatch(int index, bool override = false)
{
	if (index >= g_iPatchCount)
	{
		LogError("%s Patch #%i out of range when installing patch. (Maximum: %i)", MT_TAG, index, (g_iPatchCount - 1));

		return false;
	}

	if ((g_bPermanentPatch[index] && !override) || g_bPatchInstalled[index])
	{
		return false;
	}

	for (int iPos = 0; iPos < g_iPatchLength[index]; iPos++)
	{
		g_iOriginalBytes[index][iPos] = LoadFromAddress((g_adPatchAddress[index] + view_as<Address>(g_iPatchOffset[index] + iPos)), NumberType_Int8);
		StoreToAddress((g_adPatchAddress[index] + view_as<Address>(g_iPatchOffset[index] + iPos)), g_iPatchBytes[index][iPos], NumberType_Int8, g_bUpdateMemAccess[index]);
	}

	g_bPatchInstalled[index] = true;
	g_bUpdateMemAccess[index] = false;

	if (g_bPermanentPatch[index] && g_bPatchLog[index])
	{
		vLogMessage(-1, _, "%s Enabled the \"%s\" patch.", MT_TAG, g_sPatchName[index]);
	}

	return true;
}

bool bRegisterPatch(GameData dataHandle, const char[] name, const char[] sigName, const char[] offsetName, int[] verify, int vlength, int[] patch, int plength, bool log = false, bool permanent = false)
{
	if (iGetPatchIndex(name) >= 0)
	{
		LogError("%s The \"%s\" patch has already been registered.", MT_TAG, name);

		return false;
	}

	Address adPatch = dataHandle.GetAddress(sigName);
	if (adPatch == Address_Null)
	{
		LogError("%s Failed to find address: %s", MT_TAG, sigName);

		return false;
	}

	int iOffset = 0;
	if (offsetName[0] != '\0')
	{
		iOffset = dataHandle.GetOffset(offsetName);
		if (iOffset == -1)
		{
			LogError("%s Failed to load offset: %s", MT_TAG, offsetName);

			return false;
		}
	}

	int iActualByte = 0;
	for (int iPos = 0; iPos < vlength; iPos++)
	{
		if (verify[iPos] < 0 || verify[iPos] > 255)
		{
			LogError("%s Invalid check byte for %s (%i)", MT_TAG, name, verify[iPos]);

			return false;
		}

		if (verify[iPos] != 0x2A)
		{
			iActualByte = LoadFromAddress((adPatch + view_as<Address>(iOffset + iPos)), NumberType_Int8);
			if (iActualByte != verify[iPos])
			{
				LogError("%s Failed to locate patch: %s (%s) [Expected: %02X | Found: %02X]", MT_TAG, name, offsetName, verify[iPos], iActualByte);

				return false;
			}
		}
	}

	strcopy(g_sPatchName[g_iPatchCount], sizeof g_sPatchName, name);

	g_adPatchAddress[g_iPatchCount] = adPatch;
	g_bPatchInstalled[g_iPatchCount] = false;
	g_bPatchLog[g_iPatchCount] = log;
	g_bPermanentPatch[g_iPatchCount] = permanent;
	g_iPatchOffset[g_iPatchCount] = iOffset;
	g_iPatchLength[g_iPatchCount] = plength;

	for (int iPos = 0; iPos < plength; iPos++)
	{
		g_iPatchBytes[g_iPatchCount][iPos] = patch[iPos];
		g_iOriginalBytes[g_iPatchCount][iPos] = 0x00;
	}

	g_iPatchCount++;

	if (log)
	{
		vLogMessage(-1, _, "%s Registered the \"%s\" patch.", MT_TAG, name);
	}

	return true;
}

bool bRemovePatch(int index, bool override = false)
{
	if (index >= g_iPatchCount)
	{
		LogError("%s Patch #%i out of range when removing patch. (Maximum: %i)", MT_TAG, index, (g_iPatchCount - 1));

		return false;
	}

	if ((g_bPermanentPatch[index] && !override) || !g_bPatchInstalled[index])
	{
		return false;
	}

	for (int iPos = 0; iPos < g_iPatchLength[index]; iPos++)
	{
		StoreToAddress((g_adPatchAddress[index] + view_as<Address>(g_iPatchOffset[index] + iPos)), g_iOriginalBytes[index][iPos], NumberType_Int8, g_bUpdateMemAccess[index]);
	}

	g_bPatchInstalled[index] = false;

	if (g_bPermanentPatch[index] && g_bPatchLog[index])
	{
		vLogMessage(-1, _, "%s Disabled the \"%s\" patch.", MT_TAG, g_sPatchName[index]);
	}

	return true;
}

int iGetPatchIndex(const char[] name)
{
	for (int iPos = 0; iPos < g_iPatchCount; iPos++)
	{
		if (StrEqual(name, g_sPatchName[iPos]))
		{
			return iPos;
		}
	}

	return -1;
}