// Super Tanks++: Clone Ability
#if defined _supertankspluspluscloneability_included
	#endinput
#endif
#define _supertankspluspluscloneability_included

#include <sourcemod>

/* Returns whether the clone can use abilities.
 *
 * @param tank				Client index of the Tank.
 * @param clone				Checks whether "st_clone.smx"
 *								is installed.
 * @return					True on success, false if
 *								clone is not allowed
 *								to have abilities.
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