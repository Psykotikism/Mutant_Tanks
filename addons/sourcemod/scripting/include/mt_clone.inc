/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if defined _mutanttankscloneability_included
	#endinput
#endif
#define _mutanttankscloneability_included

/**
 * Returns if the clone can use abilities.
 *
 * @param tank				Client index of the Tank.
 * @return				True if clone can use abilities, false otherwise.
 **/
native bool MT_IsCloneSupported(int tank);

#pragma deprecated Use MT_IsCloneSupported() instead.
stock bool MT_CloneAllowed(int client, bool clone)
{
	return MT_IsCloneSupported(tank) && clone;
}

public SharedPlugin __pl_mutanttankscloneability = 
{
	name = "mt_clone",
	file = "mt_clone.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_mutanttankscloneability_SetNTVOptional()
{
	MarkNativeAsOptional("MT_IsCloneSupported");
}
#endif