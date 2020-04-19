# API description of the CookingWithBeaconsLib, version 0.1.2

This is the description of the public API in the control stage; these functions are permitted to be called from other mods. 
In general you must perform actions both in the data and also control phase for it to work.

## Human powered entities

**CookingWithBeaconsLib.enable_feature_human_powered**

enables the feature to power entities via human labor.
must be called before any entities can be made human powered.
if multiple mods call this the feature will only be enabled once.

Note that you also must call the data function cookingwithbeaconslib.public.enable_feature_human_powered.

**CookingWithBeaconsLib.make_human_powered_entity_require_tools(args)**

Specifies that for the given human powered entity tools are needed. If you don't call it, then no tools are needed.

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.name|The name of the human powered entity|
|param[in] args.listOfTools|The list of tools that are needed. It is structured as a table of tables. For example: {{"a","b"},{"c"}} means that first it will scan if the player has both a and b in its inventory. if yes, their durability is drained. if not it will look for the tool c and drain its durability. if neither is found it won't be powered.|
|param[in] args.durabilityLosPerLaborUnit|How much durability to drain from each tool. Note that you can also specify tools with infinite durabilty if you set "infinite = true" in the tool prototype.|

## Robot powered entities

**CookingWithBeaconsLib.enable_feature_robot_powered**

enables the feature to power entities via construction robots.
It works by drawing robots to the entity using entities to deconstruct, and then drain them of their energy.
The transferred energy depends on the amount of energy stored in the robot.
must be called before any entities can be made robot powered.
if multiple mods call this the feature will only be enabled once.

Note that you also must call the data function cookingwithbeaconslib.public.enable_feature_robot_powered.

**CookingWithBeaconsLib.make_entity_robot_powered**

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.name|The name of the robot powered entity|
|param[in] args.requestThreshold|How soon construction robots should be called to the entity. e.g. 0.75 means when only 75% of the energy is remaing a request will be made.|

## Tile bonus for entities

**CookingWithBeaconsLib.enable_feature_tile_bonus**

enable the feature to give entities a bonus based on the tile where they are located on.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the tile below the entity.
if multiple mods call this the feature will only be enabled once.

Note that you must also call the data script enable_feature_tile_bonus.

**CookingWithBeaconsLib.give_tile_bonus_to_entity**

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.name|The name of the entity which should get a bonus for the tile it is located on|
|param[in] args.mode|Must be "background" or "foreground". Specifies whether this bonus refers to the background or foreground. By default, tiles such as concrete are placed in the foreground while grass would be background.|
|param[in] args.defaultBoni|The boni to use if the current tile is not one of those where a bonus is specified. Boni are specified as a table, e.g. {speed = {bonus = 0.4},consumption = {bonus = -0.4}}|
|param[in] args.tileBoni|The boni to apply to the entity. It is structured as a table. The key is the name of the tile. the value is a boni specification, e.g. {["red-desert-2"] = {speed = {bonus = 0.4},consumption = {bonus = -0.4}}}|

## Research bonus for entities

**CookingWithBeaconsLib.enable_feature_research_bonus**

enable the feature to give entities a bonus through research.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the research level.
must be called before any concrete research boni are specified.
if multiple mods call this the feature will only be enabled once.

Note that you also must call the data script enable_feature_research_bonus.

**CookingWithBeaconsLib.give_research_bonus_to_entities**

Adds a research bonus to entities. This establishes the connection between the technologies in the data stage to the actual effect.

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.uniqueBonusName|The unique name of the boni. Must be the same as also used in the data stage.|
|param[in] args.entities|The list of entity names that get this bonus.|
|param[in] args.boniMultiplier|Specifies how big the bonus should be. This is a table, where the keys must be effect types (e.g. "speed", "consumption". The total boni is level*multiplier+levelZeroOffset|
|param[in] args.boniMultiplier.*.multiplier|The multiplier for each research level. For example 0.04 would be a 4% bonus per level.|
|param[in] args.boniMultiplier.*.levelZeroOffset|An base offset to be used for the boni.|


**CookingWithBeaconsLib.add_entities_to_research_bonus_group**

This interface can be used to add an entity to an already existing bonus group.

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.uniqueBonusName|The unique name of the boni. Must be the same as also used in the data stage.|
|param[in] args.entities|The additional list of entity names that get this bonus.|

## Custom beacons

**CookingWithBeaconsLib.enable_feature_custom_beacon_shapes**

enable the feature to define custom beacons, which provide features such as complicated shapes and more control how to apply the effects to entities.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the boni of the surrounding custom beacons.
if multiple mods call this the feature will only be enabled once.

Note that you must also call the data script enable_feature_custom_beacon_shapes.

**CookingWithBeaconsLib.give_custom_beacon_shape_to_entity**

This function sets up a custom beacon. 

The shape is given as a matrix, for example like this:

```

shape = {
        "OOOOOXOOOOO",
        "OOOOXXXOOOO",
        "OOOXXXXXOOO",
        "OOXXXXXXXOO",
        "OXXXXXXXXXO",
        "XXXXXEXXXXX",
        "OXXXXXXXXXO",
        "OOXXXXXXXOO",
        "OOOXXXXXOOO",
        "OOOOXXXOOOO",
        "OOOOOXOOOOO",
    }

```
    
The following letters are allowed: 'O' means no affect, 'X' means affected by the beacon, and 'E' means the beacon position.
It maps directly to the coordinate system also seen on screen, meaning that the first letter in the first string is to the top-left of the entity while the last letter of the last string is bottom right.
Each letter refers to exactly one tile distance in the game world.
You can define rectangular shapes, but all strings must have the same length. You can put the entity position anywhere you want, but only one 'E' may be specified.
There are two helper functions create_sphere_custom_shape and create_diamond_custom_shape for easy sphere and diamond shapes.

You can specify an entity filter to control which entities are affected.
It is given as a table, e.g. {{type="a",name="b",crafting_category="c"},{type="d"},{name="e"}}. 
Type, name and crafting_category are supported. The example affects entities which are: 

1. all entities which are type a AND have name b AND category c, AND 

2. all entities which have type d, AND 

3. all entities which have name e. 

If not given the beacon affects all entities which allow beacons.

You can can specify the effect calculation that controls how much bonus the affected entities get.
If you don't specify it, it behaves like a normal beacon.
(A normal beacon: Independent of how much the beacon covers the entity, it grants x*y*z where x is the distribution_effectivity and y is the modules effects and z is 1.)
The transmission is a table of tables, e.g.
```
transmission = {
    {speed="a",consumption="b",productivity="c",pollution="d"},
    {speed="e",consumption="f",productivity="g",pollution="h"},
}
```
Each list element refers to a transmission group. Normally you only want one group, but you can use multiple if you want to use time dependent transmissions (see further below).
In this example there are two groups. To calculate how much speed the entity gets, it will kind of "invoke" the function "a". In particular it will need to be specified as in this example:
```
local zeroEffect = "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0 end"
local prodBuff = "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return productivity * distribution_effectivity end"
transmission = {
    {speed=zeroEffect,consumption=zeroEffect,productivity=prodBuff,pollution=zeroEffect}
}
```
The signature "function(speed,consumption,productivity,pollution,distribution_effectivity,strength)" is fixed and required to be provided.
What follows afterwards is code to be executed. Note that you cannot use any variables outside of the scope; it must be a string which will be evaluated by the mod.
The arguments of the functor are:
|Argument/Return|Description|
|-|-|
|param[in] speed|Sum of all speed effects of all modules in the beacon|
|param[in] consumption|Sum of all consumption effects of all modules in the beacon|
|param[in] productivity|Sum of all productivity effects of all modules in the beacon|
|param[in] pollution|Sum of all pollution effects of all modules in the beacon|
|param[in] distribution_effectivity|The distribution_effectivity from the beacon prototype|
|param[in] strength|How much of the entity is covered by the beacon coverage. 1 means fully overlapped. 0 would be not overlapped at all.|

Examples:
```
transmission = {
        {
            speed=       "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0.5 end",
            consumption= "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0 end",
            productivity="function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0 end",
            pollution=   "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return 0.25 end",
        },
    }
```
This beacon grants 50% speed bonus and increases pollution production by 25%, no matter what modules are inside.

```
local transmission = {
    {
        speed=       "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return speed        * distribution_effectivity * strength end",
        consumption= "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return consumption  * distribution_effectivity * strength end",
        productivity="function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return productivity * distribution_effectivity * strength end",
        pollution=   "function(speed,consumption,productivity,pollution,distribution_effectivity,strength) return pollution    * distribution_effectivity * strength end",
    },
}
```
This beacon is like a normal beacon but the strength of the affect depends on how much the beacon coverage overlaps the entity.

You can specify that the bonus of beacons changes over time. If you don't do this then only one transmission group is expected and that one will always be used.
If you want to use this feature, then you define a function which for a certain tick number calculates which of the transmission groups should be used.
For example the following function:
```
local nightOrDay = "function(tick) local mod = tick % 25000 if mod >= 25000*0.25 and mod < 25000*0.75 then return 2 else return 1 end end"
```
Will result in using the transmission group 2 during the night and transmission group 1 during the day.
Note that this is not evaluated every tick, just occasionally. So you cannot make high frequently changing beacons. Also you shouldn't do this as it would impact the performance.
(There is only a performance cost if the group actually changes).

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.name|The name of the beacon entity to convert into a custom beacon.|
|param[in] args.shape|The shape that the beacon shall affect. This is a matrix, given as a table object. each entry is a string, with the allowed letters 'O','X','E'. See above for more details.|
|param[in] args.entityFilter (optional)|Which entities are affected by this beacon. See above for details. |
|param[in] args.transmission (optional)|How the bonus for affected entities is calculated. See above for details.|
|param[in] args.timeDependentTransmission (optional)|Definition for which transmission group to take depending on the current tick. See above for details.|

**CookingWithBeaconsLib.create_sphere_custom_shape**

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.radius|The radius of the beacon entity|
|return|A sphere based shape which can be used as a shape for a custom beacon|

**CookingWithBeaconsLib.create_diamond_custom_shape**

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.radius|The radius of the beacon entity|
|return|A diamond based shape which can be used as a shape for a custom beacon|

## Concave hull beacons

**CookingWithBeaconsLib.enable_feature_concave_hull_beacon_shapes**

enable the feature to define beacons which can affect a concave hull formed of other entities. This also gives more control how to apply the effects to entities.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the boni of the encompassing hull beacons.
if multiple mods call this the feature will only be enabled once.

Note that you must also call the data script enable_feature_concave_hull_beacon_shapes.

**CookingWithBeaconsLib.set_concave_hull_creating_group**

This function defines which entities form a hull. Hull entities are subject to strict checks where they are allowed to be placed.
In general the entities are only allowed to form a line (or circle) but never an intersection; otherwise they will be destroyed.

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.hullName|The unique name of the hull|
|param[in] args.entities|A list of entity names which form the hull. Only "wall" and "gate" entities are allowed.|

**CookingWithBeaconsLib.give_concave_hull_beacon_shape_to_entity**

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.name|The name of the beacon entity|
|param[in] args.hullName|The unique name of the hull|
|param[in] args.entityFilter (optional)|Same rules as for custom beacons in the chapter above.|
|param[in] args.transmission (optional)|Same rules as for custom beacons in the chapter above.|
|param[in] args.timeDependentTransmission (optional)|Same rules as for custom beacons in the chapter above.|
|param[in] args.powerConsumption|How much power shall be consumed, per tile, as a number in Joules|
|param[in] args.powerExponent|The exponent for the power consumption of the number of tiles, as a number. 1 would be a linear cost, 2 a quadratic cost for tiles.|

## Forbidden beacon overlap

**CookingWithBeaconsLib.enable_feature_forbidden_beacon_overlap**

Enables the feature to define that some beacons shall not overlap.
This works by checking during placement if there are any conflicting beacons.
if multiple mods call this the feature will only be enabled once.

**CookingWithBeaconsLib.set_forbidden_beacon_overlap_for_entity**

Set-up a condition to destroy the beacon upon placement, if there are any conflicting beacons.
Note that this is not inverse:
If you set-up that a is destroyed if b exists, but not that b is destroyed if a exists, it depends on the build order what you get.
You probably want to set-up destruction in both directions.

|Argument/Return|Description|
|-|-|
|param[in] args|All arguments, grouped in a table|
|param[in] args.name|The name of the beacon entity for which to define the conditions when it should be destroyed|
|param[in] args.forbidden|A list of beacon entity names. When the beacon with the args.name is placed, the surrounding area will be checked. if there are any beacons in the "forbidden" list, it will be destroyed.|

