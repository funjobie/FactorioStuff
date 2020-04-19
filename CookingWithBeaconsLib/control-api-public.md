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
