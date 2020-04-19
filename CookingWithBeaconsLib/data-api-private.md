# API description of the CookingWithBeaconsLib, version 0.1.2

This is the description of the private data API; these functions are not intended to be called from other mods.

**number cookingwithbeaconslib.private.to_energy_number(energyString)**

convert a string representation of energy (like "12MJ") to a floating point number (like 12000000)
https://wiki.factorio.com/Types/Energy

|Argument/Return|Description|
|-|-|
|param[in] energyString|a string|
|return|a numeric equivalent, or nil if it couldn't be converted.|

**table cookingwithbeaconslib.private.no_sprite()**

|Argument/Return|Description|
|-|-|
|return|a table which can be used for prototypes that expect a sprite, and contains an invisible image|

**table cookingwithbeaconslib.private.no_anim()**

|Argument/Return|Description|
|-|-|
|return|a table which can be used for prototypes that expect an animation, and contains an invisible image|



**numBits cookingwithbeaconslib.private.get_num_bits_for_module_effects()**

|Argument/Return|Description|
|-|-|
|return|The number of bits that can be used for module effects|

**void cookingwithbeaconslib.private.add_hidden_beacon()**

Adds a prototype for a hidden beacon to the data.raw

**void cookingwithbeaconslib.private.add_unit_module_if_not_existing(effectType, level, bonusMultiplier)**

Adds one hidden module prototype to the data.raw, where the level corresponds to the number of bits in the effect strength.

|Argument/Return|Description|
|-|-|
|param[in] effectType|the effect type, for example "speed"|
|param[in] level|the level, which will be used as the exponent to calculate the strength|
|param[in] bonusMultiplier|a multiplier on the effect strength, to create positive and negative effects|


**void cookingwithbeaconslib.private.add_all_unit_modules()**

Adds hidden module prototypes to the data.raw, which correspond to the bits that are supported, for all 4 module types, in both positive and negative direction.

**void cookingwithbeaconslib.private.add_hidden_beacon_and_unit_modules()**

Convenience function that adds a hidden beacon and all effects

**cookingwithbeaconslib.private.getLocalizedNameAndDescription(uniqueBonusName, entities, groupLocalization, effectType, effectAmount)**

Get the localized name and description for a research bonus

|Argument/Return|Description|
|-|-|
|param[in] uniqueBonusName|the unique bonus name that identifies it|
|param[in] entities|list of entity names which are affected by the research bonus|
|param[in] groupLocalization|a localization string to be used for the group|
|param[in] effectType|The type of the effect|
|param[in] effectAmount|The strength of the research bonus|
|return name, description|The localized name and description|

**cookingwithbeaconslib.private.add_technology(uniqueBonusName, entities, groupLocalization, effectType, effectAmount, level, maxLevel, count_formula, ingredients, timeVal, additionalPrerequisites)**

Adds one technology prototype

|Argument/Return|Description|
|-|-|
|param[in] uniqueBonusName|the unique bonus name that identifies it|
|param[in] entities|list of entity names which are affected by the research bonus|
|param[in] groupLocalization|a localization string to be used for the group|
|param[in] effectType|The type of the effect|
|param[in] effectAmount|The strength of the research bonus|
|param[in] level|The level of the technology|
|param[in] maxLevel|The maximum level of the technology|
|param[in] count_formula|The count_formala to use in the prototype|
|param[in] ingredients|The ingredients that the technology uses|
|param[in] timeVal|The timeVal that the technology uses|
|param[in] additionalPrerequisites|Additional prerequisites that are added as a dependency|