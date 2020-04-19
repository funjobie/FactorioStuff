# API description of the CookingWithBeaconsLib, version 0.1.2

This is the description of the private control API; these functions are not intended to be called from other mods.

**CookingWithBeaconsLib.run_maintainance_script**

This function allows executing any code in the context of the CookingWithBeaconsLib. 
This feature is intended for debugging purposes, and allows:
to inspect the code of inner variables without having to distribute a version with additional logs
expose internals, so that they can be unit tested in a standalone mod
as a last resort to enable version migrations that would otherwise be impossible.
Generally it is recommended to follow normal migration rules, however i am aware that some high-level functions are likely missing to update a mod using this library.
Two examples:
```
determine durability cost of a tool:
/c remote.call("CookingWithBeaconsLib","run_maintainance_script", "game.print(global.human_labor.tool_specification[\"manual-assembler\"].durabilityLosPerLaborUnit)")
set durability cost to new value:
/c remote.call("CookingWithBeaconsLib","run_maintainance_script", "global.human_labor.tool_specification[\"manual-assembler\"].durabilityLosPerLaborUnit = 0.1")
```

**CookingWithBeaconsLib.set_verbose_logging**

This function enables or disables a more verbose logging mode. This is for internal use during development.