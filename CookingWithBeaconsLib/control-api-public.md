# API description of the CookingWithBeaconsLib, version 0.1.2

This is the description of the public API in the control stage; these functions are permitted to be called from other mods. 
In general you must perform actions both in the data and also control phase for it to work.

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
