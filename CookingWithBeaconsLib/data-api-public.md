# API description of the CookingWithBeaconsLib, version 0.1.2

This is the description of the public API in the data stage; these functions are permitted to be called from other mods. 
In general you must perform actions both in the data and also control phase for it to work.

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

You should balance the energy consumption of the entity together with the energy properties of the construction robots, to make sure it fits well together.

Note that you also must call the control script enable_feature_robot_powered
You also must call the control script make_entity_robot_powered for each entity to be powered by robots.

|Argument/Return|Description|
|-|-|
|param[in] entity|the entity prototype to convert. for example, cookingwithbeaconslib.public.make_entity_robot_powered(data.raw["assembling-machine"]["assembling-machine-1"]). allowed entity types are: "assembling-machine", "furnace", "mining-drill", "inserter", "lab"|
|param[in] energy_buffer_in_seconds(optional)|How many seconds of energy to buffer. If not given it defaults to 30s|

**cookingwithbeaconslib.public.enable_feature_tile_bonus()**

enable the feature to give entities a bonus based on the tile where they are located on.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the tile below the entity.
if multiple mods call this the feature will only be enabled once.
it adds necessary prototypes to the data.raw.

Note that you must also call the control script enable_feature_tile_bonus.
Individual boni are specified in the control scripts with give_tile_bonus_to_entity.

**cookingwithbeaconslib.public.enable_feature_research_bonus()**

enable the feature to give entities a bonus through research.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the research level.
must be called before any concrete research boni are specified.
if multiple mods call this the feature will only be enabled once.
it adds necessary prototypes to the data.raw

Note that you also must call the control script enable_feature_research_bonus.

**void cookingwithbeaconslib.public.add_research_boni(uniqueBonusName, entities, groupLocalization, researchBonusChains, affectedBoni)**

Adds a technology to the game that grants boni to entities (similar to module effects).

Note that you also must call the data script enable_feature_research_bonus before.
You must also call the control script give_research_bonus_to_entities for each bonus group. You can optionally call add_entities_to_research_bonus_group to add additional entities to a group later.

|Argument/Return|Description|
|-|-|
|param[in] uniqueBonusName|the unique bonus name that identifies it|
|param[in] entities|list of entity names which are affected by the research bonus|
|param[in] groupLocalization|a localization string to be used for the group|
|param[in] researchBonusChains|A structure describing the individual levels of the research. It is a list of tables.|
|param[in] researchBonusChains.*.level|The starting level of the technology|
|param[in] researchBonusChains.*.levelMax|The maximum level of the technology|
|param[in] researchBonusChains.*.ingredients|The ingredients that the technology uses. This is itself a table, like also used when specifying technologies normally|
|param[in] researchBonusChains.*.count_formula|The count_formala to use in the prototype. This is a string just like when specifying technologies normally|
|param[in] researchBonusChains.*.time|The time that the technology uses. This is a number just like when specifying technologies normally|
|param[in] researchBonusChains.*.additionalPrerequisites|Additional prerequisites that are added as a dependency|
|param[in] affectedBoni|A structure describing the individual boni to be granted to this group of entities. It is a table and can contain entries for the desired effects, e.g. {productivity={bonus=0.04},speed={bonus=0.05}}. For each effect a separate technology will be added.|

**cookingwithbeaconslib.public.enable_feature_custom_beacon_shapes()**

enable the feature to define custom beacons, which provide features such as complicated shapes and more control how to apply the effects to entities.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the boni of the surrounding custom beacons.
if multiple mods call this the feature will only be enabled once.
it adds necessary prototypes to the data.raw.

Note that you must also call the control script enable_feature_custom_beacon_shapes.

**cookingwithbeaconslib.public.setup_custom_beacon_shapes(beaconPrototype)**

Specify that this prototype is a custom beacon. All this does is set the supply_area_distance to 0 in order to not affect entities twice. The actual logic is in the control scripts.
The details are specified in the control script give_custom_beacon_shape_to_entity.

|Argument/Return|Description|
|-|-|
|param[in] beaconPrototype|the beacon prototype to adapt|

**cookingwithbeaconslib.public.enable_feature_concave_hull_beacon_shapes()**

enable the feature to define beacons which can affect a concave hull formed of other entities. This also gives more control how to apply the effects to entities.
This works by using a hidden beacon behind the entity, in which modules are inserted according to the boni of the encompassing hull beacons.
if multiple mods call this the feature will only be enabled once.
it adds necessary prototypes to the data.raw.

Note that you must also call the control script enable_feature_concave_hull_beacon_shapes.

**cookingwithbeaconslib.public.setup_concave_hull_beacon_shapes(beaconPrototype)**

Specify that this prototype is a custom beacon. All this does is set the supply_area_distance to 0 in order to not affect entities twice. The actual logic is in the control scripts.
The details are specified in the control script set_concave_hull_creating_group and give_concave_hull_beacon_shape_to_entity.
Also a hidden energy receiver will be created which consumes power according to the size of the hull.

|Argument/Return|Description|
|-|-|
|param[in] beaconPrototype|the beacon prototype to adapt|
