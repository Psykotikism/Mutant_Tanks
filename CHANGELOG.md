# Changelog

## Version 8.12 (TBA)

Bug fixes:

1. Fixed the st_gamemodetypes returning Survival for 2 and Versus for 4, instead of vice-versa.

Changes:

1. Optimized code a bit more.

Files:

1. Updated gamedata file.
2. Updated include file.

## Version 8.11 (June 22, 2018)

Bug fixes:

1. Fixed the Witch Tank not spawning Witches. (Thanks ReCreator!)
2. Fixed the Shield Tank not propelling its propane tanks forward. (Thanks ReCreator!)

Changes:

1. Added the convar st_gamemodetypes to determine what game mode types to enable/disable the plugin in. (0: All, 1: coop modes only, 2: versus modes only, 4: survival modes only, 8: scavenge modes only.)
2. Removed the "@witches" target filter for not working properly.
3. Optimized code a bit more.

Files:

1. Updated include file.

## Version 8.10 (June 22, 2018)

Changes:

1. Any extra health given to a Super Tank is now multiplied by the number of alive non-idle human survivors present when the Tank spawns. (Thanks emsit!)
2. Added the target filters "@smokers", "@boomers", "@hunters", "@spitters", "@jockeys", "@chargers", "@witches" for developers/testers to use.
3. Added the sm_tank "type 1-36" command to spawn each Tank for developing/testing purposes.
4. Added oxygen tank (jetpack) props to Tanks.
5. Modified the attachprops convars to now support multiple number combinations.
6. Removed unnecessary code.
7. Optimized code a bit.

Files:

1. Updated include file.

## Version 8.9 (June 21, 2018)

Changes:

1. Added a randomizer for Tanks spawning with props to add more variety.
2. Added the target filter "@tanks" for developers/testers to use.

Files:

1. Updated include file.

## Version 8.8 (June 21, 2018)

Bug fixes:

1. Fixed the Shove and Smoker Tanks' attachprops convars not working properly.

Files:

1. Updated include file.

## Version 8.7 (June 21, 2018)

Bug fixes:

1. Fixed the Ghost Tank and Gravity Tank convars being switched.

Changes:

1. Added options for the st_displayhealth convar. (1: show names only, 2: show health only, 3: show both names and health.)
2. Added a convar for each Tank type to decide what props to attach to it. (1: attach lights only, 2: attach rocks only, 3: attach tires only, 4: attach all 3.)

Files:

1. Updated include file.

## Version 8.6 (June 21, 2018)

Bug fixes:

1. Fixed the proper amount of Tanks not spawning on the 2nd wave during finales.
2. Fixed the props attached to the Tanks not disappearing right away when they die.

Files:

1. Updated include file.

## Version 8.5 (June 20, 2018)

Bug fixes:

1. Fixed the Tank's effects not going away right after the Tank dies.

## Version 8.4 (June 20, 2018)

Bug fixes:

1. Fixed the infected thrower Tanks not throwing special infected directly from their rocks.

## Version 8.3 (June 20, 2018)

Bug fixes:

1. Fixed the Meteor Tank's meteor shower not working after a certain amount of time.

Changes:

1. Added a check to destroy all effects when a Tank dies.
2. Added a check for Bomber Tank's explosion to not damage any infected including the Bomber Tank.
3. Added a check for Fire Tank's fires to not damage any infected including the Fire Tank.
4. Added a check for Meteor Tank's meteor showers to not damage any infected including the Meteor Tank.
5. Converted some code to new syntax.
6. Removed unnecessary code.
7. Optimized some code.

Files:

1. Updated include file.

## Version 8.2 (June 19, 2018)

Bug fixes:

1. Fixed the Tank's rocks not doing anything when survivors are hit.

## Version 8.1 (June 19, 2018)

Bug fixes:

1. Fixed the Common Tank not spawning any common infected.
2. Fixed the Gravity Tank's gravity force not stopping upon death.
3. Fixed the Hypno Tank's effect instantly killing survivors (Now it sets survivors to 1 HP).
4. Fixed the Meteor Tank's meteor shower not working.
5. Fixed the special infected thrower Tanks not throwing any special infected.

## Version 8.0 (June 18, 2018)

1. Major code overhaul.
2. 36 (31 for L4D1) unique types.
3. Now requires a gamedata file.
4. Now requires an include file.

## Version 7.0 (November 24, 2017)

1. Disabled Ice Tank for L4D version.
2. Only 28/40 are available for the L4D version now.
3. Fixed Shield Tank and other Tank types with shields not having their shields shattered by explosions.

## Version 6.5 (November 24, 2017)

1. Fixed the SetConVarInt errors reported by KasperH here.

## Version 6.0 (November 24, 2017)

1. Added support for L4D.
2. L4D version only includes 29/40 Tank types.
3. L4D version excludes prop attachments (concrete chunk and beam spotlight).
4. L4D version excludes glow outlines.
5. Changed the l4d2_ prefix to l4d_ for the plugin and config files.

## Version 5.5 (October 23, 2017)

1. Applied another fix for the negative HP bug for Boss, Goliath, Psychotic, and Psykotik Tanks.

## Version 5.0 (October 22, 2017)

1. Applied a fix for a speed bug that was also in the original Super Tanks.

## Version 4.5 (October 21, 2017)

1. Fixed a bug that caused Boss, Goliath, Psychotic, and Psykotik Tanks to have negative HP.

## Version 4.0 (October 21, 2017)

1. Added 8 new combinations of Super Tanks.
- Boss Tank
- Meme Tank
- Mirage Tank
- Poltergeist Tank
- Psykotik Tank
- Sipow Tank
- Spykotik Tank
- Spypsy Tank
2. Fixed some bugs due to missing code.

## Version 3.0 (October 20, 2017)

1. Fixed the Flash and Reverse Flash special speed cvars not working.

## Version 2.0 (October 19, 2017)

1. Removed the screen color effect when getting hit by certain Super Tank types.
2. Redesigned and recolored Trap Tank.
3. Recolored Bitch Tank, Distraction Tank, and Minion Tank.

## Version 1.0 (October 18, 2017)

Initial Release.