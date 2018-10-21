/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

// Super Tanks++: Clone Ability
#if defined _supertankspluspluscloneability_included
	#endinput
#endif
#define _supertankspluspluscloneability_included

/* Returns whether the clone can use abilities.
 *
 * @param tank				Client index of the Tank.
 * @param clone				Checks whether "st_clone.smx" is installed.
 * @return					True if clone can use abilities, false otherwise.
 */
native bool ST_CloneAllowed(int tank, bool clone);

public SharedPlugin __pl_supertankspluspluscloneability = 
{
	name = "st_clone",
	file = "st_clone.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_supertankspluspluscloneability_SetNTVOptional()
{
	MarkNativeAsOptional("ST_CloneAllowed");
}
#endif