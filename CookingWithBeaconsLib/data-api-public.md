# API description of the CookingWithBeaconsLib, version 0.1.2

This is the description of the public API; these functions are permitted to be called from other mods.

**void cookingwithbeaconslib.public.enable_feature_human_powered()**

enables the feature to power entities via human labor.
must be called before any entities can be made human powered.
if multiple mods call this the feature will only be enabled once.
it adds necessary prototypes to the data.raw

Note that you also must call the control script enable_feature_human_powered.

**void cookingwithbeaconslib.public.make_entity_human_powered(entity)**

make an entity human powered.
requires calling cookingwithbeaconslib.public.enable_feature_human_powered beforehand.
this replaces the energy_source property to instead receive energy from human labor, via an artificial fluid.
supported are: "assembling-machine", "furnace", "mining-drill", "lab"
human labor produces a constant 75J, which will be inserted over time as the player stands in front of the device.
you will have to scale the energy_usage property of the entity accordingly to power the device properly. (e.g. energy_usage="75W" would allow running with 100% uptime with a player in front)
the energy buffer of the entity will be quite small, matching the rate at which the scripts insert power.

Note that you also must call the control script enable_feature_human_powered.
You can also optionally call the control script make_human_powered_entity_require_tools if you want.

|Argument/Return|Description|
|-|-|
|param[in] entity|the entity prototype to convert. for example, cookingwithbeaconslib.public.make_entity_human_powered(data.raw["assembling-machine"]["assembling-machine-1"]). allowed entity types are: "assembling-machine", "furnace", "mining-drill", "lab"|

**void cookingwithbeaconslib.public.enable_feature_robot_powered()**

enables the feature to power entities via robots.
It works by drawing robots to the entity using entities to deconstruct, and then drain them of their energy.
must be called before any entities can be made robot powered.
if multiple mods call this the feature will only be enabled once.
it adds necessary prototypes to the data.raw

Note that you also must call the control script enable_feature_robot_powered

**cookingwithbeaconslib.public.make_entity_robot_powered(entity, energy_buffer_in_seconds)**

make an entity robot powered.
requires calling cookingwithbeaconslib.public.enable_feature_robot_powered beforehand.
this replaces the energy_source property to instead receive energy from construction robots, via an artificial fluid.
supported are: "assembling-machine", "furnace", "mining-drill", "inserter", "lab"
the amount of energy that the entity can buffer is derived from the properties that cover energy usage, and defaults to 30s.
"furnace", "assembling-machine", "mining-drill", "lab": the value from energy_usage is used.
"inserter": the values from energy_per_movement, energy_per_rotation, extension_speed and rotation_speed are used. The estimation is overestimating, like the display in the game gui.

Note that you also must call the control script enable_feature_robot_powered
You also must call the control script make_entity_robot_powered for each entity to be powered by robots.

|Argument/Return|Description|
|-|-|
|param[in] entity|the entity prototype to convert. for example, cookingwithbeaconslib.public.make_entity_robot_powered(data.raw["assembling-machine"]["assembling-machine-1"]). allowed entity types are: "assembling-machine", "furnace", "mining-drill", "inserter", "lab"|
|param[in] energy_buffer_in_seconds(optional)|How many seconds of energy to buffer. If not given it defaults to 30s|

