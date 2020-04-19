# API description of the CookingWithBeaconsLib, version 0.1.2

This is the description of the private data API; these functions are not intended to be called from other mods.

**number cookingwithbeaconslib.private.to_energy_number(energyString)**

convert a string representation of energy (like "12MJ") to a floating point number (like 12000000)
https://wiki.factorio.com/Types/Energy

|Argument/Return|Description|
|-|-|
|param[in]|energyString a string|
|return|a numeric equivalent, or nil if it couldn't be converted.|

**table cookingwithbeaconslib.no_sprite()**

|Argument/Return|Description|
|-|-|
|return|a table which can be used for prototypes that expect a sprite, and contains an invisible image|

**table cookingwithbeaconslib.no_anim()**

|Argument/Return|Description|
|-|-|
|return|a table which can be used for prototypes that expect an animation, and contains an invisible image|

